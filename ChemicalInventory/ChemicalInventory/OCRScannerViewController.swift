//
//  OCRScannerViewController.swift
//  ChemicalInventory
//
//  Created by Alex Vasiliev on 11/21/24.
//

import UIKit
import AVFoundation
import Vision

class OCRScannerViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var onTextRecognized: ((String?, String?, String?) -> Void)? // CAS, Amount, Barcode
    
    private var casNumber: String?
    private var amount: String?
    private var barcode: String?
    
    private var casLabel: UILabel!
    private var amountLabel: UILabel!
    private var barcodeLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("DEBUG: Initializing OCRScannerViewController...")
        
        // Setup camera session
        captureSession = AVCaptureSession()
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            print("DEBUG: No camera available.")
            return
        }
        
        guard let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice) else {
            print("DEBUG: Cannot access camera.")
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            print("DEBUG: Cannot add camera input to session.")
            return
        }
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        } else {
            print("DEBUG: Cannot add video output to session.")
            return
        }
        
        // Setup camera preview
        setupPreview()
        
        // Add overlay and labels
        addOverlay()
        setupLabels()
        
        addCancelAndDoneButtons()

        
        // Start the camera session
        print("DEBUG: Starting camera session...")
        captureSession.startRunning()
    }
    
    private func setupPreview() {
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
    }
    
    private func addOverlay() {
        let cutoutRect = CGRect(
            x: (view.frame.width - 300) / 2,
            y: (view.frame.height - 200) / 2,
            width: 300,
            height: 200
        )
        
        let overlayLayer = CAShapeLayer()
        let path = UIBezierPath(rect: view.bounds)
        let cutoutPath = UIBezierPath(roundedRect: cutoutRect, cornerRadius: 10)
        path.append(cutoutPath.reversing())
        overlayLayer.path = path.cgPath
        overlayLayer.fillColor = UIColor.black.withAlphaComponent(0.5).cgColor
        view.layer.addSublayer(overlayLayer)
        
        let borderLayer = CAShapeLayer()
        borderLayer.path = cutoutPath.cgPath
        borderLayer.strokeColor = UIColor.white.cgColor
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.lineWidth = 2
        view.layer.addSublayer(borderLayer)
    }

    private func setupLabels() {
        // Create labels
        casLabel = createLabel(text: "CAS Number:")
        amountLabel = createLabel(text: "Amount:")
        barcodeLabel = createLabel(text: "Barcode:")

        // Stack view for labels
        let stackView = UIStackView(arrangedSubviews: [casLabel, amountLabel, barcodeLabel])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .center // Center the labels
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stackView)

        // Position the stack view above the scanning field
        NSLayoutConstraint.activate([
            stackView.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: -120),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func createLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .center
        return label
    }

    func addCancelAndDoneButtons() {
        // Add Cancel button
        let cancelButton = UIButton()
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.backgroundColor = .red
        cancelButton.layer.cornerRadius = 8
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        view.addSubview(cancelButton)
        
        // Add Done button
        let doneButton = UIButton()
        doneButton.setTitle("Done", for: .normal)
        doneButton.backgroundColor = .green
        doneButton.layer.cornerRadius = 8
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        view.addSubview(doneButton)
        
        // Add constraints
        NSLayoutConstraint.activate([
            // Done button constraints
            doneButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -80),
            doneButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            doneButton.widthAnchor.constraint(equalToConstant: 100),
            doneButton.heightAnchor.constraint(equalToConstant: 40),
            
            // Cancel button constraints
            cancelButton.topAnchor.constraint(equalTo: doneButton.bottomAnchor, constant: 10),
            cancelButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cancelButton.widthAnchor.constraint(equalToConstant: 100),
            cancelButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    @objc func doneTapped() {
        print("DEBUG: Done button tapped. Closing camera with scanned values.")
        closeCamera(withCAS: casNumber, amount: amount, andBarcode: barcode)
    }

    
    @objc func cancelTapped() {
        print("DEBUG: Cancel button tapped. Stopping camera session.")
        captureSession.stopRunning()
        dismiss(animated: true)
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            print("DEBUG: Unable to retrieve pixel buffer.")
            return
        }
        
        let request = VNRecognizeTextRequest { [weak self] (request, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("DEBUG: Text recognition error: \(error)")
                return
            }
            
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                print("DEBUG: No recognized text observations.")
                return
            }
            
            let recognizedText = observations.compactMap { $0.topCandidates(1).first?.string }
            print("DEBUG: Recognized text: \(recognizedText)")
            
            for text in recognizedText {
                // Extract CAS number
                if self.casNumber == nil {
                    self.casNumber = self.extractCASNumber(from: text)
                    if let cas = self.casNumber {
                        print("DEBUG: Found CAS Number: \(cas)")
                        self.updateLabel(self.casLabel, with: cas)
                    }
                }
                
                // Extract Amount
                if self.amount == nil {
                    self.amount = self.extractAmount(from: text)
                    if let amt = self.amount {
                        print("DEBUG: Found Amount: \(amt)")
                        self.updateLabel(self.amountLabel, with: amt)
                    }
                }
                
                // Extract Barcode
                if self.barcode == nil {
                    self.barcode = self.extractBarcode(from: text)
                    if let bc = self.barcode {
                        print("DEBUG: Found Barcode: \(bc)")
                        self.updateLabel(self.barcodeLabel, with: bc)
                    }
                }
            }
            
            // Finish scan only when all elements are found
            if self.casNumber != nil && self.amount != nil && self.barcode != nil {
                print("DEBUG: All elements scanned. Closing camera.")
                self.closeCamera(withCAS: self.casNumber, amount: self.amount, andBarcode: self.barcode)
            }
        }
        
        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["en-US"]
        
        let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
        do {
            try requestHandler.perform([request])
        } catch {
            print("DEBUG: Failed to perform text recognition: \(error)")
        }
    }

    private func updateLabel(_ label: UILabel, with text: String) {
        DispatchQueue.main.async {
            let checkmark = " ✅"
            if !(label.text?.contains(checkmark) ?? false) { // Prevent duplicate checkmarks
                label.text = "\(label.text ?? "") \(text)\(checkmark)"
            }
        }
    }

    private func closeCamera(withCAS cas: String?, amount: String?, andBarcode barcode: String?) {
        print("DEBUG: Closing camera with CAS: \(cas ?? "N/A"), Amount: \(amount ?? "N/A"), Barcode: \(barcode ?? "None")")
        DispatchQueue.main.async {
            self.captureSession.stopRunning()
            self.onTextRecognized?(cas, amount, barcode)
            self.dismiss(animated: true)
        }
    }

    private var casFirstScan: String? = nil
    private var casSecondScan: String? = nil

    private var amountFirstScan: String? = nil
    private var amountSecondScan: String? = nil

    private var barcodeFirstScan: String? = nil
    private var barcodeSecondScan: String? = nil

    private func extractCASNumber(from text: String) -> String? {
        let casRegex = #"CAS[:\s]*([\d-]+)"#
        if let match = text.range(of: casRegex, options: .regularExpression) {
            let matchedText = String(text[match])
            if let casMatch = matchedText.range(of: #"[\d-]+"#, options: .regularExpression) {
                let casValue = String(matchedText[casMatch])
                
                // Two-scan confirmation logic
                if casFirstScan == nil {
                    casFirstScan = casValue
                    print("DEBUG: CAS First Scan: \(casFirstScan ?? "N/A")")
                    return nil
                } else {
                    casSecondScan = casValue
                    if casFirstScan == casSecondScan {
                        print("DEBUG: CAS Confirmed: \(casSecondScan ?? "N/A")")
                        casFirstScan = nil
                        casSecondScan = nil
                        return casValue
                    } else {
                        print("DEBUG: CAS Mismatch. Retrying...")
                        casFirstScan = casSecondScan
                        casSecondScan = nil
                        return nil
                    }
                }
            }
        }
        return nil
    }

    private func extractAmount(from text: String) -> String? {
        let amountRegex = #"\d+(\.\d+)?\s*(kg|g|L|mL)"#
        if let range = text.range(of: amountRegex, options: .regularExpression) {
            let amountValue = String(text[range])
            
            // Two-scan confirmation logic
            if amountFirstScan == nil {
                amountFirstScan = amountValue
                print("DEBUG: Amount First Scan: \(amountFirstScan ?? "N/A")")
                return nil
            } else {
                amountSecondScan = amountValue
                if amountFirstScan == amountSecondScan {
                    print("DEBUG: Amount Confirmed: \(amountSecondScan ?? "N/A")")
                    amountFirstScan = nil
                    amountSecondScan = nil
                    return amountValue
                } else {
                    print("DEBUG: Amount Mismatch. Retrying...")
                    amountFirstScan = amountSecondScan
                    amountSecondScan = nil
                    return nil
                }
            }
        }
        return nil
    }

    private func extractBarcode(from text: String) -> String? {
        let barcodeRegex = #"^\d{10}$"#
        if let match = text.range(of: barcodeRegex, options: .regularExpression) {
            let barcodeValue = String(text[match])
            
            // Two-scan confirmation logic
            if barcodeFirstScan == nil {
                barcodeFirstScan = barcodeValue
                print("DEBUG: Barcode First Scan: \(barcodeFirstScan ?? "N/A")")
                return nil
            } else {
                barcodeSecondScan = barcodeValue
                if barcodeFirstScan == barcodeSecondScan {
                    print("DEBUG: Barcode Confirmed: \(barcodeSecondScan ?? "N/A")")
                    barcodeFirstScan = nil
                    barcodeSecondScan = nil
                    return barcodeValue
                } else {
                    print("DEBUG: Barcode Mismatch. Retrying...")
                    barcodeFirstScan = barcodeSecondScan
                    barcodeSecondScan = nil
                    return nil
                }
            }
        }
        return nil
    }

}
