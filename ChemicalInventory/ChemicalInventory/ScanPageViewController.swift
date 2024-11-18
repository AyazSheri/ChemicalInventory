//
//  ScanPageViewController.swift
//  ChemicalInventory
//
//  Created by Alex Vasiliev on 11/17/24.
//

import UIKit

class ScanPageViewController: UIViewController {
    // Outlets for UI Elements
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var piButton: UIButton!
    @IBOutlet weak var roomButton: UIButton!
    @IBOutlet weak var barcodeLabel: UILabel!
    
    // Hardcoded Data
    let userName = "John Doe"
    let piList = ["PI 1", "PI 2", "PI 3"]
    let roomList = ["Room 101", "Room 102", "Room 103"]
    
    // Dropdown Views
    var piDropdownView: UIView?
    var roomDropdownView: UIView?
    
    override func viewDidLoad() {
            super.viewDidLoad()

            // Set User's Name
            nameLabel.text = "Name: \(userName)"

            // Style buttons and set initial titles
            setupButton(button: piButton, initialTitle: piList[0])
            setupButton(button: roomButton, initialTitle: roomList[0])
        }

        private func setupButton(button: UIButton, initialTitle: String) {
            // Clear any existing title to avoid overlap
            button.setTitle("", for: .normal)

            // Add a label for the button's text
            let textLabel = UILabel()
            textLabel.text = initialTitle
            textLabel.font = button.titleLabel?.font
            textLabel.textColor = button.titleColor(for: .normal) ?? .blue
            textLabel.translatesAutoresizingMaskIntoConstraints = false
            button.addSubview(textLabel)

            // Add a label for the chevron symbol
            let chevronLabel = UILabel()
            chevronLabel.text = "▼"
            chevronLabel.font = button.titleLabel?.font
            chevronLabel.textColor = .gray
            chevronLabel.translatesAutoresizingMaskIntoConstraints = false
            button.addSubview(chevronLabel)

            // Align the text label to the left and center vertically
            NSLayoutConstraint.activate([
                textLabel.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 10),
                textLabel.centerYAnchor.constraint(equalTo: button.centerYAnchor),

                // Align the chevron label to the right and center vertically
                chevronLabel.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -10),
                chevronLabel.centerYAnchor.constraint(equalTo: button.centerYAnchor)
            ])

            // Style the button appearance
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.gray.cgColor
            button.layer.cornerRadius = 8

            // Keep the button's touchable functionality intact
            button.bringSubviewToFront(textLabel)
            button.bringSubviewToFront(chevronLabel)
        }

        @objc private func optionSelected(_ sender: UIButton) {
            guard let selectedOption = sender.currentTitle else { return }
            if sender.superview == piDropdownView {
                updateButtonTitle(button: piButton, newTitle: selectedOption)
                piDropdownView?.removeFromSuperview()
            } else if sender.superview == roomDropdownView {
                updateButtonTitle(button: roomButton, newTitle: selectedOption)
                roomDropdownView?.removeFromSuperview()
            }
        }

        private func updateButtonTitle(button: UIButton, newTitle: String) {
            // Find the text label inside the button and update its text
            if let textLabel = button.subviews.compactMap({ $0 as? UILabel }).first {
                textLabel.text = newTitle
            }
        }


    
    // MARK: - Dropdown Handling
    @IBAction func togglePiDropdown(_ sender: UIButton) {
        toggleDropdown(
            dropdownView: &piDropdownView,
            button: piButton,
            options: piList
        ) { selectedOption in
            self.piButton.setTitle("\(selectedOption) ▼", for: .normal)
        }
    }
    
    @IBAction func toggleRoomDropdown(_ sender: UIButton) {
        toggleDropdown(
            dropdownView: &roomDropdownView,
            button: roomButton,
            options: roomList
        ) { selectedOption in
            self.roomButton.setTitle("\(selectedOption) ▼", for: .normal)
        }
    }
    
    private func toggleDropdown(
        dropdownView: inout UIView?,
        button: UIButton,
        options: [String],
        onSelect: @escaping (String) -> Void
    ) {
        // Remove existing dropdown
        dropdownView?.removeFromSuperview()
        dropdownView = nil

        // Create dropdown if it doesn’t exist
        if dropdownView == nil {
            // Calculate the dropdown's frame based on the button's text alignment
            let dropdownXOffset: CGFloat = 3 // Adjust to align with text
            let dropdownWidth = button.frame.width - dropdownXOffset

            let dropdown = UIView(frame: CGRect(
                x: button.frame.origin.x + dropdownXOffset, // Offset to align with text
                y: button.frame.origin.y + button.frame.height,
                width: dropdownWidth,
                height: CGFloat(options.count * 44)
            ))
            dropdown.layer.borderColor = UIColor.gray.cgColor
            dropdown.layer.borderWidth = 1
            dropdown.layer.cornerRadius = 8
            dropdown.backgroundColor = .white

            // Add options as buttons inside the dropdown
            for (index, option) in options.enumerated() {
                let optionButton = UIButton(frame: CGRect(
                    x: 0,
                    y: CGFloat(index) * 44,
                    width: dropdown.frame.width,
                    height: 44
                ))
                optionButton.setTitle(option, for: .normal)
                optionButton.setTitleColor(.black, for: .normal)
                optionButton.contentHorizontalAlignment = .left
                optionButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
                optionButton.addTarget(self, action: #selector(optionSelected(_:)), for: .touchUpInside)
                dropdown.addSubview(optionButton)
            }

            // Add dropdown to the view
            self.view.addSubview(dropdown)
            dropdownView = dropdown
        } else {
            // Hide dropdown if already visible
            dropdownView?.removeFromSuperview()
            dropdownView = nil
        }
    }
    
    @IBAction func openBarcodeScanner(_ sender: UIButton) {
        let scannerVC = BarcodeScannerViewController()
        scannerVC.modalPresentationStyle = .fullScreen
        scannerVC.onBarcodeScanned = { [weak self] barcode in
            // Log the scanned barcode to the console
            print("Scanned Barcode: \(barcode)")
            
        }
        present(scannerVC, animated: true)
    }
    
}
