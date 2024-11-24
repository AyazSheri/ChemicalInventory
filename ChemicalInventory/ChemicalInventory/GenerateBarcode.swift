//import UIKit
import CoreImage
import UIKit

class BarcodeGenerator {
    
    /// Generates a single composite image containing the barcode and labels.
    func generateCompositeBarcodeImage(
        barcodeString: String,
        topLabel: String,
        bottomLabel: String,
        size: CGSize
    ) -> UIImage? {
        guard let barcodeImage = createBarcodeImage(from: barcodeString) else {
            print("Failed to create barcode image")
            return nil
        }
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        // Define label attributes
        let labelFontSize: CGFloat = size.height * 0.05 // Dynamic font size
        let labelFont = UIFont.systemFont(ofSize: labelFontSize)
        let labelAttributes: [NSAttributedString.Key: Any] = [
            .font: labelFont,
            .foregroundColor: UIColor.black
        ]
        
        // Calculate positions and sizes
        let topLabelHeight = (topLabel as NSString).size(withAttributes: labelAttributes).height
        let barcodeHeight = size.height * 0.6
        let verticalSpacing = size.height * 0.05
        let barcodeSize = CGSize(width: size.width * 0.8, height: barcodeHeight)
        
        let topLabelPoint = CGPoint(
            x: (size.width - (topLabel as NSString).size(withAttributes: labelAttributes).width) / 2,
            y: verticalSpacing
        )
        
        let barcodePoint = CGPoint(
            x: (size.width - barcodeSize.width) / 2,
            y: topLabelPoint.y + topLabelHeight + verticalSpacing
        )
        
        let bottomLabelPoint = CGPoint(
            x: (size.width - (bottomLabel as NSString).size(withAttributes: labelAttributes).width) / 2,
            y: barcodePoint.y + barcodeHeight + verticalSpacing
        )
        
        // Draw components
        (topLabel as NSString).draw(at: topLabelPoint, withAttributes: labelAttributes)
        barcodeImage.resized(to: barcodeSize).draw(in: CGRect(origin: barcodePoint, size: barcodeSize))
        (bottomLabel as NSString).draw(at: bottomLabelPoint, withAttributes: labelAttributes)
        
        let compositeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return compositeImage
    }

    /// Creates a barcode image from a given string.
    private func createBarcodeImage(from string: String) -> UIImage? {
        guard let data = string.data(using: .ascii) else { return nil }
        if let filter = CIFilter(name: "CICode128BarcodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            filter.setValue(7.0, forKey: "inputQuietSpace")
            if let ciImage = filter.outputImage {
                let transformedImage = ciImage.transformed(by: CGAffineTransform(scaleX: 10, y: 10))
                return UIImage(ciImage: transformedImage)
            }
        }
        return nil
    }

    /// Prints the barcode as a composite image.
    func printBarcode(
        barcodeString: String,
        topLabel: String,
        bottomLabel: String,
        size: CGSize
    ) {
        guard let compositeImage = generateCompositeBarcodeImage(
            barcodeString: barcodeString,
            topLabel: topLabel,
            bottomLabel: bottomLabel,
            size: size
        ) else {
            print("Failed to generate composite image")
            return
        }
        
        guard UIPrintInteractionController.isPrintingAvailable else {
            print("Printing is not available on this device.")
            return
        }
        
        let printController = UIPrintInteractionController.shared
        let printInfo = UIPrintInfo(dictionary: nil)
        printInfo.jobName = "Barcode Print"
        printInfo.outputType = .photo
        printController.printInfo = printInfo
        printController.printingItem = compositeImage
        
        printController.present(animated: true) { _, completed, error in
            if completed {
                print("Print job completed successfully.")
            } else if let error = error {
                print("Print job failed: \(error.localizedDescription)")
            } else {
                print("Print job was canceled.")
            }
        }
    }
}

extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        self.draw(in: CGRect(origin: .zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage ?? self
    }
}
