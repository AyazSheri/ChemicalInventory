import UIKit
import AVFoundation

class BarcodeScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var onBarcodeScanned: ((String) -> Void)?
    private let cutoutRect = CGRect(
        x: (UIScreen.main.bounds.width - 300) / 2,
        y: (UIScreen.main.bounds.height - 100) / 2,
        width: 300,
        height: 100
    )
    private var flashlightTimer: Timer? // Timer to handle flashlight enabling

    override func viewDidLoad() {
        super.viewDidLoad()

        print("DEBUG: Initializing BarcodeScannerViewController...")

        // Setup camera session
        DispatchQueue.global(qos: .userInitiated).async {
            self.setupCameraSession()
            DispatchQueue.main.async {
                // Setup camera preview
                self.setupPreview()
                // Add overlay and cancel button
                self.addOverlay(cutoutRect: self.cutoutRect)
                self.addCancelButton(below: self.cutoutRect)

                // Ensure rectOfInterest is configured after previewLayer is initialized
                self.configureRectOfInterest()

                // Start the camera session
                print("DEBUG: Starting camera session...")
                self.captureSession.startRunning()

                // Start flashlight timer
                self.startFlashlightTimer()
            }
        }
    }

    private func setupCameraSession() {
        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            print("DEBUG: No camera available.")
            return
        }

        guard let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice) else {
            print("DEBUG: Cannot access camera.")
            return
        }

        if captureSession.canSetSessionPreset(.hd1920x1080) {
            captureSession.sessionPreset = .hd1920x1080
        }

        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            print("DEBUG: Cannot add camera input to session.")
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.code128]
        } else {
            print("DEBUG: Cannot add metadata output to session.")
            return
        }
    }

    private func setupPreview() {
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
    }

    private func configureRectOfInterest() {
        guard let metadataOutput = captureSession.outputs.compactMap({ $0 as? AVCaptureMetadataOutput }).first else {
            print("DEBUG: Metadata output not found.")
            return
        }

        // Convert the cutoutRect to normalized coordinates
        let normalizedRect = previewLayer.metadataOutputRectConverted(fromLayerRect: cutoutRect)
        metadataOutput.rectOfInterest = normalizedRect
        print("DEBUG: rectOfInterest set to \(normalizedRect)")
    }

    private func addOverlay(cutoutRect: CGRect) {
        let overlayLayer = CAShapeLayer()
        let path = UIBezierPath(rect: view.bounds)
        let cutoutPath = UIBezierPath(roundedRect: cutoutRect, cornerRadius: 10)
        path.append(cutoutPath.reversing())
        overlayLayer.path = path.cgPath
        overlayLayer.fillColor = UIColor.black.withAlphaComponent(0.5).cgColor
        view.layer.addSublayer(overlayLayer)

        // Add visual border around the cutout
        let borderLayer = CAShapeLayer()
        borderLayer.path = cutoutPath.cgPath
        borderLayer.strokeColor = UIColor.white.cgColor
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.lineWidth = 2
        view.layer.addSublayer(borderLayer)
    }

    private func addCancelButton(below cutoutRect: CGRect) {
        let cancelButton = UIButton()
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.backgroundColor = .red
        cancelButton.layer.cornerRadius = 8
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        view.addSubview(cancelButton)

        NSLayoutConstraint.activate([
            cancelButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cancelButton.topAnchor.constraint(equalTo: view.topAnchor, constant: cutoutRect.maxY + 20),
            cancelButton.widthAnchor.constraint(equalToConstant: 100),
            cancelButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    private func enableTorch(_ enabled: Bool) {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
        do {
            try device.lockForConfiguration()
            device.torchMode = enabled ? .on : .off
            device.unlockForConfiguration()
        } catch {
            print("DEBUG: Could not configure torch: \(error)")
        }
    }

    private func startFlashlightTimer() {
        flashlightTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
            print("DEBUG: Enabling flashlight due to timeout.")
            self?.enableTorch(true)
        }
    }

    private func stopFlashlightTimer() {
        flashlightTimer?.invalidate()
        flashlightTimer = nil
    }

    @objc func cancelTapped() {
        print("DEBUG: Cancel button tapped.")
        stopFlashlightTimer() // Stop the timer if user cancels
        enableTorch(false) // Turn off torch when canceling
        captureSession.stopRunning()
        dismiss(animated: true)
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let metadataObject = metadataObjects.first,
              let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
              let stringValue = readableObject.stringValue else { return }

        print("DEBUG: Scanned barcode: \(stringValue)")

        // Stop the session once a barcode is detected
        captureSession.stopRunning()

        // Notify the parent view controller
        onBarcodeScanned?(stringValue)

        // Close the scanner
        stopFlashlightTimer() // Stop the timer on successful scan
        enableTorch(false) // Turn off torch when a barcode is detected
        dismiss(animated: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopFlashlightTimer() // Stop the timer if view disappears
        enableTorch(false) // Turn off torch when the view disappears
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
}
