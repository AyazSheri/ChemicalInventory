import UIKit

class Barcode: UIViewController {
    
    @IBOutlet weak var barcodeImageView: UIImageView!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var bottomLabel: UILabel!
        let barcodeGenerator = BarcodeGenerator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set initial states for labels and image view
        topLabel.text = ""
        bottomLabel.text = ""
        barcodeImageView.image = nil
    }
    
    @IBAction func generateBarcodeTapped(_ sender: UIButton) {
        let barcodeString = "1234567890"
        let topLabelText = "Sample Top Label"
        let bottomLabelText = barcodeString
        
        // Generate the composite barcode image
        if let compositeImage = barcodeGenerator.generateCompositeBarcodeImage(
            barcodeString: barcodeString,
            topLabel: topLabelText,
            bottomLabel: bottomLabelText,
            size: CGSize(width: 400, height: 600)
        ) {
            // Display the composite image in the image view
            barcodeImageView.image = compositeImage
        }
    }
    
    @IBAction func printBarcodeTapped(_ sender: UIButton) {
        let barcodeString = "1234567890"
        let topLabelText = "Sample Top Label"
        let bottomLabelText = barcodeString
        
        // Print the composite barcode image
        barcodeGenerator.printBarcode(
            barcodeString: barcodeString,
            topLabel: topLabelText,
            bottomLabel: bottomLabelText,
            size: CGSize(width: 400, height: 600)
        )
    }
}
