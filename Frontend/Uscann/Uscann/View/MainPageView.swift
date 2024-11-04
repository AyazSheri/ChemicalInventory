//
//  MainPageView.swift
//  Uscann
//
//


import SwiftUI
import AVFoundation

struct MainPageView: View {
    @State private var isShowingScanner = false
    
    var body: some View {
        VStack {
            Text("Scan Your Chemical's Barcode")
                .font(.title)
                .padding()
            
            Spacer()
            
            Button(action: {
                isShowingScanner = true
            }) {
                Image(systemName: "barcode.viewfinder")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .padding()
            }
            .sheet(isPresented: $isShowingScanner) {
                BarcodeScannerView()
            }
            
            Spacer()
        }
    }
}

struct BarcodeScannerView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> BarcodeScannerViewController {
        let viewController = BarcodeScannerViewController()
        viewController.dismissScanner = {
            presentationMode.wrappedValue.dismiss()
        }
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: BarcodeScannerViewController, context: Context) {
        // No need to update UI Controller
    }
}

class BarcodeScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession!
    var dismissScanner: (() -> Void)?  // Closure to trigger dismissing
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.ean13, .ean8, .qr] // Add barcode types here
        } else {
            return
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        // Add the back button with safe area handling
        let backButton = UIButton(type: .system)
        backButton.setTitle("Back", for: .normal)
        backButton.setTitleColor(.white, for: .normal)
        backButton.backgroundColor = UIColor(white: 0.1, alpha: 0.7)  // Dark background for visibility
        backButton.layer.cornerRadius = 5
        backButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(backButton)
        
        // Constraints for proper positioning (using safe area)
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            backButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            backButton.widthAnchor.constraint(equalToConstant: 80),
            backButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        backButton.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        
        captureSession.startRunning()
    }
    
    @objc func backButtonPressed() {
        dismissScanner?()  // Trigger the dismiss closure
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        }
        
        dismiss(animated: true)
    }
    
    func found(code: String) {
        print("Scanned Barcode: \(code)")
        // Handle the scanned barcode value here
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
}
