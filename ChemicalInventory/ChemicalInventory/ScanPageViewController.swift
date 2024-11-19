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
    @IBOutlet weak var scanButton: UIButton!
    
    // Hardcoded Data
    let userName = "John Doe"
    let piList = ["PI 1", "PI 2", "PI 3"]
    let roomList = ["Room 101", "Room 102", "Room 103"]
    
    // Dummy data for chemicals
    let chemicalData: [String: [String: Any]] = [
        "123456789012": [
            "name": "Acetone",
            "casNumber": "67-64-1",
            "amount": 500.0,
            "unit": "mL",
            "expirationDate": "2025-12-31",
            "spaces": ["Storage Room 1", "Storage Room 2"]
        ],
        "987654321098": [
            "name": "Ethanol",
            "casNumber": "64-17-5",
            "amount": 250.0,
            "unit": "mL",
            "expirationDate": "2026-06-15",
            "spaces": ["Lab A", "Lab B"]
        ]
    ]

    // Dropdown Views
    var piDropdownView: UIView?
    var roomDropdownView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set User's Name
        nameLabel.text = "Name: \(userName)"
        
        // Remove existing constraints to start fresh
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        piButton.translatesAutoresizingMaskIntoConstraints = false
        roomButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Create labels for "PI:" and "Room:"
        let piLabel = UILabel()
        piLabel.text = "PI:"
        piLabel.font = nameLabel.font
        piLabel.textAlignment = .left
        piLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(piLabel)
        
        let roomLabel = UILabel()
        roomLabel.text = "Room:"
        roomLabel.font = nameLabel.font
        roomLabel.textAlignment = .left
        roomLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(roomLabel)
        
        // Ensure Scan button is centered dynamically
        scanButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scanButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scanButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 50),
            scanButton.widthAnchor.constraint(equalToConstant: 150),
            scanButton.heightAnchor.constraint(equalToConstant: 50)
        ])

        
        // Add constraints for alignment
        NSLayoutConstraint.activate([
            // Name label constraints
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            
            // PI label constraints
            piLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            piLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 20),
            
            // PI button constraints
            piButton.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            piButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            piButton.topAnchor.constraint(equalTo: piLabel.bottomAnchor, constant: 10),
            piButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Room label constraints
            roomLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            roomLabel.topAnchor.constraint(equalTo: piButton.bottomAnchor, constant: 20),
            
            // Room button constraints
            roomButton.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            roomButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            roomButton.topAnchor.constraint(equalTo: roomLabel.bottomAnchor, constant: 10),
            roomButton.heightAnchor.constraint(equalToConstant: 44),
        ])
        
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
        
        // Add constraints to make the button dynamically adjust to screen size
        NSLayoutConstraint.activate([
            // Align the text label to the left with a margin
            textLabel.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 10),
            textLabel.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            
            // Align the chevron label to the right with a margin
            chevronLabel.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -10),
            chevronLabel.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            
            // Set the button's height dynamically
            button.heightAnchor.constraint(equalToConstant: 44), // Standard button height
        ])
        
        // Style the button appearance
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.gray.cgColor
        button.layer.cornerRadius = 8
        
        // Ensure the button resizes correctly on different devices
        button.translatesAutoresizingMaskIntoConstraints = false
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
            guard let self = self else { return }
            print("Scanned Barcode: \(barcode)")

            // Dismiss the scanner first
            scannerVC.dismiss(animated: true) {
                if let chemicalInfo = self.chemicalData[barcode] {
                    self.showChemicalInfoDialog(chemicalInfo: chemicalInfo)
                } else {
                    print("Chemical not found for barcode: \(barcode)")
                }
            }
        }
        present(scannerVC, animated: true)
    }

    
    func showChemicalInfoDialog(chemicalInfo: [String: Any]) {
        guard let name = chemicalInfo["name"] as? String,
              let casNumber = chemicalInfo["casNumber"] as? String,
              let amount = chemicalInfo["amount"] as? Double,
              let unit = chemicalInfo["unit"] as? String,
              let expirationDate = chemicalInfo["expirationDate"] as? String,
              let spaces = chemicalInfo["spaces"] as? [String] else {
            return
        }
        
        let chemicalDialog = ChemicalInfoDialog()
        chemicalDialog.chemicalName = name
        chemicalDialog.casNumber = casNumber
        chemicalDialog.amount = amount
        chemicalDialog.unit = unit
        chemicalDialog.expirationDate = expirationDate

        chemicalDialog.onEditTapped = {
            self.showEditChemicalDialog(chemicalInfo: chemicalInfo)
        }
        
        chemicalDialog.onEnterUsedAmountTapped = { usedAmount, selectedUnit in
            let remainingAmount = max(0, amount - usedAmount)
            print("New amount: \(remainingAmount) \(selectedUnit)")
            // You could update the UI or data here
        }
        
        present(chemicalDialog, animated: true)
    }
    
    func showEditChemicalDialog(chemicalInfo: [String: Any]) {
        guard let spaces = chemicalInfo["spaces"] as? [String] else { return }

        let editDialog = EditChemicalDialog()
        editDialog.spaces = spaces
        editDialog.selectedSpace = spaces.first ?? ""

        editDialog.onSaveTapped = { updatedSpace in
            print("Updated Space: \(updatedSpace)")
        }

        editDialog.onDeleteTapped = {
            print("Chemical deleted!")
        }
        
        present(editDialog, animated: true)
    }


    
}
