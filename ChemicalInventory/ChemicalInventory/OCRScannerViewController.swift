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
    
    private var barcodeFrameCounter: Int = 0
    private let maxBarcodeFrames = 10 // Limit for barcode detection after CAS and Amount are found
    private var casNumber: String?
    private var amount: String?
    private var barcode: String?
    
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
        
        // Add overlay
        addOverlay()
        
        // Add a Cancel button
        addCancelButton()
        
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
    
    func addCancelButton() {
        let cancelButton = UIButton()
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.backgroundColor = .red
        cancelButton.layer.cornerRadius = 8
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        view.addSubview(cancelButton)
        
        NSLayoutConstraint.activate([
            cancelButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            cancelButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cancelButton.widthAnchor.constraint(equalToConstant: 100),
            cancelButton.heightAnchor.constraint(equalToConstant: 40)
        ])
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
                    }
                }
                
                // Extract Amount
                if self.amount == nil {
                    self.amount = self.extractAmount(from: text)
                    if let amt = self.amount {
                        print("DEBUG: Found Amount: \(amt)")
                    }
                }
                
                // Extract Barcode (only after CAS and Amount are found)
                if self.casNumber != nil && self.amount != nil {
                    if self.barcode == nil {
                        self.barcode = self.extractBarcode(from: text)
                        if let bc = self.barcode {
                            print("DEBUG: Found Barcode: \(bc)")
                        }
                    }
                }
            }
            
            // Start barcode countdown if CAS and Amount are found
            if self.casNumber != nil && self.amount != nil {
                self.barcodeFrameCounter += 1
                print("DEBUG: Barcode frame count: \(self.barcodeFrameCounter)")
                
                if self.barcode != nil || self.barcodeFrameCounter >= self.maxBarcodeFrames {
                    print("DEBUG: Barcode detection finished. Closing camera.")
                    self.closeCamera(withCAS: self.casNumber, amount: self.amount, andBarcode: self.barcode)
                }
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

    private func closeCamera(withCAS cas: String?, amount: String?, andBarcode barcode: String?) {
        print("DEBUG: Closing camera with CAS: \(cas ?? "N/A"), Amount: \(amount ?? "N/A"), Barcode: \(barcode ?? "None")")
        DispatchQueue.main.async {
            self.captureSession.stopRunning()
            self.onTextRecognized?(cas, amount, barcode)
            self.dismiss(animated: true)
        }
    }

    private func extractCASNumber(from text: String) -> String? {
        let casRegex = #"CAS[:\s]*([\d-]+)"#
        if let match = text.range(of: casRegex, options: .regularExpression) {
            let matchedText = text[match]
            if let casMatch = matchedText.range(of: #"[\d-]+"#, options: .regularExpression) {
                return String(matchedText[casMatch])
            }
        }
        return nil
    }
    
    private func extractAmount(from text: String) -> String? {
        let amountRegex = #"\d+(\.\d+)?\s*(kg|g|L|mL)"#
        if let range = text.range(of: amountRegex, options: .regularExpression) {
            return String(text[range])
        }
        return nil
    }
    
    private func extractBarcode(from text: String) -> String? {
        let barcodeRegex = #"^\d{10}$"#
        if let match = text.range(of: barcodeRegex, options: .regularExpression) {
            return String(text[match])
        }
        return nil
    }
}
