import UIKit
import CoreImage

struct StickerDimensions {
    static let stickerWidth: CGFloat = 26 * 2.835 // 26mm in points
    static let stickerHeight: CGFloat = 13 * 2.835 // 13mm in points
    static let barcodeWidth: CGFloat = 22 * 2.835 // 22mm in points
    static let barcodeHeight: CGFloat = 4 * 2.835 // 4mm in points
    static let topLabelFontSize: CGFloat = 2.5 * 2.835 // 2.5mm in points
    static let bottomLabelFontSize: CGFloat = 2 * 2.835 // 2mm in points
}

class BarcodeGenerator {
    
    /// Generates a barcode sticker with a white background, top label, barcode, and bottom label.
    func generateBarcodeSticker(barcodeString: String) -> UIImage? {
        let size = CGSize(width: StickerDimensions.stickerWidth, height: StickerDimensions.stickerHeight)
        
        guard let barcodeImage = createBarcodeImage(from: barcodeString) else {
            print("Failed to create barcode image")
            return nil
        }

        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        // Draw white background
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(UIColor.white.cgColor)
        context?.fill(CGRect(origin: .zero, size: size))
        
        // Draw top label
        let topLabel = "UAB EHS CIS"
        let topLabelFont = UIFont.systemFont(ofSize: StickerDimensions.topLabelFontSize)
        let topLabelAttributes: [NSAttributedString.Key: Any] = [
            .font: topLabelFont,
            .foregroundColor: UIColor.black
        ]
        let topLabelSize = (topLabel as NSString).size(withAttributes: topLabelAttributes)
        let topLabelPoint = CGPoint(
            x: (size.width - topLabelSize.width) / 2,
            y: 2 // Small margin from the top
        )
        (topLabel as NSString).draw(at: topLabelPoint, withAttributes: topLabelAttributes)
        
        // Draw barcode
        let barcodeSize = CGSize(width: StickerDimensions.barcodeWidth, height: StickerDimensions.barcodeHeight)
        let barcodePoint = CGPoint(
            x: (size.width - barcodeSize.width) / 2,
            y: topLabelPoint.y + topLabelSize.height + 2 // Add margin
        )
        barcodeImage.resized(to: barcodeSize).draw(in: CGRect(origin: barcodePoint, size: barcodeSize))
        
        // Draw bottom label (barcode number)
        let bottomLabelFont = UIFont.systemFont(ofSize: StickerDimensions.bottomLabelFontSize)
        let bottomLabelAttributes: [NSAttributedString.Key: Any] = [
            .font: bottomLabelFont,
            .foregroundColor: UIColor.black
        ]
        let bottomLabelSize = (barcodeString as NSString).size(withAttributes: bottomLabelAttributes)
        let bottomLabelPoint = CGPoint(
            x: (size.width - bottomLabelSize.width) / 2,
            y: barcodePoint.y + barcodeSize.height + 2 // Add margin
        )
        (barcodeString as NSString).draw(at: bottomLabelPoint, withAttributes: bottomLabelAttributes)
        
        let compositeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return compositeImage
    }

    /// Creates a barcode image from a given string.
    private func createBarcodeImage(from string: String) -> UIImage? {
        guard let data = string.data(using: .ascii) else {
            print("DEBUG: Failed to convert string to ASCII data.")
            return nil
        }

        if let filter = CIFilter(name: "CICode128BarcodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            filter.setValue(7.0, forKey: "inputQuietSpace")
            print("DEBUG: Input data for barcode:", data) // Debug input data
            if let ciImage = filter.outputImage {
                let transformedImage = ciImage.transformed(by: CGAffineTransform(scaleX: 10, y: 10))
                print("DEBUG: Barcode generated successfully.")
                return UIImage(ciImage: transformedImage)
            } else {
                print("DEBUG: Failed to generate CIImage for barcode.")
            }
        } else {
            print("DEBUG: CICode128BarcodeGenerator filter not found.")
        }
        return nil
    }
    
    /// Displays the barcode sticker in a UIAlertController.
    func showBarcodePopup(barcodeString: String, in viewController: UIViewController) {
        let stickerSize = CGSize(width: StickerDimensions.stickerWidth, height: StickerDimensions.stickerHeight)
        
        guard let barcodeSticker = generateBarcodeSticker(barcodeString: barcodeString) else {
            print("Failed to generate barcode sticker")
            return
        }
        
        let imageView = UIImageView(image: barcodeSticker)
        imageView.contentMode = .scaleAspectFit
        
        let alert = UIAlertController(title: "Barcode", message: nil, preferredStyle: .alert)
        alert.view.addSubview(imageView)
        
        // Adjust alert size
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 60),
            imageView.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: stickerSize.width),
            imageView.heightAnchor.constraint(equalToConstant: stickerSize.height),
            alert.view.heightAnchor.constraint(equalToConstant: stickerSize.height + 120) // Add space for buttons
        ])
        
        alert.addAction(UIAlertAction(title: "Print", style: .default, handler: { _ in
            print("Print button tapped")
            self.printBarcodeImage(barcodeSticker: barcodeSticker)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        viewController.present(alert, animated: true)
    }
    
    private func printBarcodeImage(barcodeSticker: UIImage) {
        let printController = UIPrintInteractionController.shared
        
        let printInfo = UIPrintInfo(dictionary: nil)
        printInfo.outputType = .photo
        printInfo.jobName = "Barcode Sticker"
        printController.printInfo = printInfo
        
        // Set the barcode sticker as the printing item
        printController.printingItem = barcodeSticker
        
        // Present the print interaction controller
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
