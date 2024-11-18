//
//  BarcodeScannerViewController.swift
//  ChemicalInventory
//
//  Created by Alex Vasiliev on 11/18/24.
//

import UIKit
import AVFoundation

class BarcodeScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var onBarcodeScanned: ((String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup camera session
        captureSession = AVCaptureSession()
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            print("No camera available.")
            return
        }
        
        guard let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice) else {
            print("Cannot access camera.")
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            print("Cannot add camera input to session.")
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.code128] // Limit to Code128 barcodes
        } else {
            print("Cannot add metadata output to session.")
            return
        }
        
        // Setup camera preview
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        // Add overlay after setting up the preview layer
        let cutoutRect = CGRect(
            x: (view.frame.width - 300) / 2,
            y: (view.frame.height - 100) / 2,
            width: 300,
            height: 100
        )
        addOverlay(cutoutRect: cutoutRect)

        // Now set the rectOfInterest
        metadataOutput.rectOfInterest = previewLayer.metadataOutputRectConverted(fromLayerRect: cutoutRect)

        // Start the camera session
        captureSession.startRunning()
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
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let metadataObject = metadataObjects.first,
              let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
              let stringValue = readableObject.stringValue else { return }
        
        // Stop the session once a barcode is detected
        captureSession.stopRunning()
        
        // Notify the parent view controller
        onBarcodeScanned?(stringValue)
        
        // Close the scanner
        dismiss(animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
}
