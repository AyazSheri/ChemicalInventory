//
//  AddChemicalViewController.swift
//  ChemicalInventory
//
//  Created by Alex Vasiliev on 11/21/24.
//

import UIKit
import SCLAlertView

class AddChemicalViewController: BaseViewController {
    // Outlets for UI Elements
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var piButton: UIButton!
    @IBOutlet weak var roomButton: UIButton!
    @IBOutlet weak var scanLabelButton: UIButton!
    
    
    // Data for Dropdowns
    var piList: [String] = []
    var roomList: [String] = []
    var selectedPIIndex: Int = 0 // Track selected PI
    var selectedRoomIndex: Int = 0 // Track selected Room
    
    
    // Dropdown Views
    var piDropdownView: UIView?
    var roomDropdownView: UIView?
    
    // New UI Elements
    private var barcodeTextField: UITextField!
    private var nameTextField: UITextField!
    private var casNumberTextField: UITextField!
    private var amountTextField: UITextField!
    private var expirationDateTextField: UITextField!
    private var spaceTextField: UITextField!
    private var spaceData: [(name: String, id: Int)] = []
    private var addChemicalButton: UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setPageTitle("Add Chemical")
        
        // Debugging
        print("Initializing ScanPageViewController...")
        
        // Set User's Name
        nameLabel.text = "Name: \(UserSession.shared.userName ?? "Unknown User")"
        
        // Load PI and Room Dropdowns
        loadDropdownData()
        print("Loaded PI List:", piList)
        
        // Restore last selected PI and Room
        restoreSelections()
        
        // Set PI and Room Button Titles
        updateButtonTitle(button: piButton, newTitle: piList[selectedPIIndex])
        updateRoomList(for: selectedPIIndex)
        if selectedRoomIndex < roomList.count {
            updateButtonTitle(button: roomButton, newTitle: roomList[selectedRoomIndex])
        }
        
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
        
        piLabel.layer.zPosition = -1
        roomLabel.layer.zPosition = -1

    

        
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
        setupButton(button: piButton, initialTitle: piList[selectedPIIndex])
        setupButton(button: roomButton, initialTitle: roomList[selectedRoomIndex])
        
        addDynamicFields()
        setupAddChemicalButton()
        addKeyboardDismissGesture()

    }
    
    private func setupScanLabelButtonLayout() {
        guard let spaceTextField = spaceTextField else {
            print("DEBUG: spaceTextField is not initialized yet.")
            return
        }

        // Remove existing constraints (if any)
        scanLabelButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            scanLabelButton.topAnchor.constraint(equalTo: spaceTextField.bottomAnchor, constant: 20),
            scanLabelButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scanLabelButton.widthAnchor.constraint(equalToConstant: 200),
            scanLabelButton.heightAnchor.constraint(equalToConstant: 44)
        ])
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
    
    private func setupAddChemicalButton() {
        addChemicalButton = UIButton(type: .system)
        addChemicalButton.setTitle("Add Chemical", for: .normal)
        addChemicalButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        addChemicalButton.setTitleColor(.white, for: .normal)
        addChemicalButton.backgroundColor = .systemBlue
        addChemicalButton.layer.cornerRadius = 8
        addChemicalButton.translatesAutoresizingMaskIntoConstraints = false
        addChemicalButton.addTarget(self, action: #selector(addChemicalButtonTapped), for: .touchUpInside)

        view.addSubview(addChemicalButton)

        // Set constraints
        NSLayoutConstraint.activate([
            addChemicalButton.topAnchor.constraint(equalTo: scanLabelButton.bottomAnchor, constant: 20),
            addChemicalButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addChemicalButton.widthAnchor.constraint(equalToConstant: 200),
            addChemicalButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    @objc private func addChemicalButtonTapped() {
        print("DEBUG: Add Chemical button tapped.")

        guard let name = nameTextField.text, !name.isEmpty, name != "N/A",
              let casNumber = casNumberTextField.text, !casNumber.isEmpty,
              let barcode = barcodeTextField.text, !barcode.isEmpty,
              let roomIndex = roomList.indices.contains(selectedRoomIndex) ? selectedRoomIndex : nil,
              let roomID = getRoomID(for: piList[selectedPIIndex], roomNumber: roomList[roomIndex].split(separator: ",").first?.trimmingCharacters(in: .whitespaces) ?? "") else {
            print("DEBUG: Validation failed. Missing or invalid fields.")
            showAlert(title: "Validation Error", message: "Please fill in all required fields correctly.")
            return
        }

        // Parse amount and extract unit
        guard let amountText = amountTextField.text, !amountText.isEmpty else {
            print("DEBUG: Amount field is empty.")
            showAlert(title: "Validation Error", message: "Amount is required.")
            return
        }

        let amountPattern = "^([0-9]*\\.?[0-9]+)([a-zA-Z]*)$"
        let regex = try? NSRegularExpression(pattern: amountPattern)
        if let match = regex?.firstMatch(in: amountText, range: NSRange(location: 0, length: amountText.count)),
           let amountRange = Range(match.range(at: 1), in: amountText),
           let unitRange = Range(match.range(at: 2), in: amountText) {
            let amount = Float(amountText[amountRange]) ?? 0
            let unit = String(amountText[unitRange])

            if amount <= 0 || unit.isEmpty {
                print("DEBUG: Invalid amount or unit.")
                showAlert(title: "Validation Error", message: "Amount must be greater than zero and include a valid unit.")
                return
            }

            // Optional fields
            let expirationDate = expirationDateTextField.text?.isEmpty == false ? expirationDateTextField.text : nil
            let spaceID = spaceTextField.tag > 0 ? spaceTextField.tag : nil

            // Print collected data
            print("DEBUG: Collected Data:")
            print("Name:", name)
            print("CAS Number:", casNumber)
            print("Barcode:", barcode)
            print("Room ID:", roomID)
            print("Space ID:", spaceID ?? "N/A")
            print("Amount:", amount)
            print("Unit:", unit)
            print("Expiration Date:", expirationDate ?? "N/A")

            // Create chemicalData
            let chemicalData: [String: Any] = [
                "name": name,
                "cas_number": casNumber,
                "barcode": barcode,
                "room_id": roomID,
                "space_id": spaceID ?? NSNull(),
                "amount": amount,
                "unit": unit,
                "expiration_date": expirationDate ?? NSNull()
            ]

            print("DEBUG: Prepared chemical data:", chemicalData)

            // Call backend API to add chemical
            NetworkManager.shared.addChemical(chemicalData: chemicalData) { success, errorMessage in
                DispatchQueue.main.async {
                    if success {
                        self.showAlert(title: "Success", message: "Chemical added successfully.")
                    } else {
                        self.showAlert(title: "Error", message: errorMessage ?? "Failed to add chemical.")
                    }
                }
            }
        } else {
            print("DEBUG: Failed to parse amount or unit.")
            showAlert(title: "Validation Error", message: "Amount must include a numeric value followed by a unit (e.g., '10kg').")
        }
    }
    
    private func addDynamicFields() {
        let labels = ["Barcode:", "Name:", "Cas Number:", "Amount:", "Expiration Date:", "Space:"]
        var previousView: UIView = roomButton // Start below roomButton

        for labelText in labels {
            let label = UILabel()
            label.text = labelText
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = UIFont.systemFont(ofSize: 16)
            label.textAlignment = .left
            label.layer.zPosition = -1
            view.addSubview(label)

            let textField = UITextField()
            textField.borderStyle = .roundedRect
            textField.translatesAutoresizingMaskIntoConstraints = false
            textField.font = UIFont.systemFont(ofSize: 16)
            textField.layer.zPosition = -1
            view.addSubview(textField)

            switch labelText {
            case "Barcode:":
                barcodeTextField = textField
            case "Name:":
                nameTextField = textField
            case "Cas Number:":
                casNumberTextField = textField
            case "Amount:":
                amountTextField = textField
            case "Expiration Date:":
                expirationDateTextField = textField
            case "Space:":
                spaceTextField = textField
                // Disable keyboard input
                spaceTextField.delegate = self
                spaceTextField.tag = 0
            default:
                break
            }

            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                label.topAnchor.constraint(equalTo: previousView.bottomAnchor, constant: 20),
                label.widthAnchor.constraint(lessThanOrEqualToConstant: 100),

                textField.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 10),
                textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                textField.centerYAnchor.constraint(equalTo: label.centerYAnchor),
                textField.heightAnchor.constraint(equalToConstant: 40)
            ])

            previousView = label
        }
        setupScanLabelButtonLayout()
    }
    
//    @objc private func openBarcodeScannerFromTextField() {
//        let scannerVC = BarcodeScannerViewController()
//        scannerVC.modalPresentationStyle = .fullScreen
//        scannerVC.onBarcodeScanned = { [weak self] barcode in
//            guard let self = self else { return }
//            scannerVC.dismiss(animated: true) {
//                // Debug log for scanned barcode
//                print("DEBUG: Scanned barcode: \(barcode)")
//
//                // Set the barcode in the text field
//                self.barcodeTextField.text = barcode
//            }
//        }
//        present(scannerVC, animated: true)
//    }

    
    @objc private func spaceFieldTapped() {
        // Ensure selectedRoomIndex is within bounds of the roomList array
        guard selectedRoomIndex >= 0 && selectedRoomIndex < roomList.count else {
            print("No room selected")
            return
        }

        // Retrieve the selected room based on the index
        let selectedRoomName = roomList[selectedRoomIndex] // E.g., "3329, Harris, Rangel and Martinez"
        let selectedRoomNumber = selectedRoomName.split(separator: ",").first?.trimmingCharacters(in: .whitespaces) ?? ""

        // Get the room ID for the selected PI and room
        let roomId = getRoomID(for: piList[selectedPIIndex], roomNumber: selectedRoomNumber)
        guard let validRoomId = roomId else {
            print("Room ID not found for the selected room")
            return
        }

        // Fetch spaces for the valid room ID
        NetworkManager.shared.fetchSpaces(for: validRoomId) { spaces in
            DispatchQueue.main.async {
                self.spaceData = spaces.map { ($0.name, $0.id) }

                if self.spaceData.isEmpty {
                    // Show alert if no spaces are available
                    let alert = UIAlertController(title: "No Spaces Available", message: "No spaces are associated with this room.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true)
                } else {
                    // Show dropdown if spaces exist
                    self.showSpaceDropdown()
                }
            }
        }
    }

    
    private func showSpaceDropdown() {
        guard !spaceData.isEmpty else {
            print("No spaces available for dropdown")
            return
        }

        let alert = UIAlertController(title: "Select Space", message: nil, preferredStyle: .actionSheet)
        for space in spaceData {
            alert.addAction(UIAlertAction(title: space.name, style: .default, handler: { _ in
                self.spaceTextField.text = space.name
                self.spaceTextField.tag = space.id
                print("DEBUG: Selected space ID: \(space.id)")
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true)
    }



    
    @objc private func optionSelected(_ sender: UIButton) {
        guard let dropdownView = sender.superview else { return }
        if dropdownView == piDropdownView {
            let selectedIndex = sender.tag
            let selectedOption = piList[selectedIndex]
            updateButtonTitle(button: piButton, newTitle: selectedOption)
            // Update the selected PI index
            selectedPIIndex = selectedIndex
            print("Updated selectedPIIndex:", selectedPIIndex)
            
            piDropdownView?.removeFromSuperview()

            // Update Room list based on the selected PI
            updateRoomList(for: selectedIndex)
            
            // Reset the Room index for the new PI
            selectedRoomIndex = 0
            if let firstRoom = roomList.first {
                updateButtonTitle(button: roomButton, newTitle: firstRoom)
            } else {
                updateButtonTitle(button: roomButton, newTitle: "No Rooms")
            }

            // Save selection
            print("save at if of optionselcted")
            saveSelections()
        } else if dropdownView == roomDropdownView {
            let selectedIndex = sender.tag
            let selectedOption = roomList[selectedIndex]
            updateButtonTitle(button: roomButton, newTitle: selectedOption)
            // Update the selected Room index
            selectedRoomIndex = selectedIndex
            print("Updated selectedRoomIndex:", selectedRoomIndex)
            
            roomDropdownView?.removeFromSuperview()

            // Save selection
            print("save at else of optionselcted")
            saveSelections()
        }
    }
    
    private func updateButtonTitle(button: UIButton, newTitle: String) {
        // Clear all subviews (text labels) inside the button
        button.subviews.forEach { $0.removeFromSuperview() }

        // Create a label for the new title
        let textLabel = UILabel()
        textLabel.text = newTitle
        textLabel.font = button.titleLabel?.font
        textLabel.textColor = button.titleColor(for: .normal) ?? .blue
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        button.addSubview(textLabel)

        // Create a label for the chevron symbol
        let chevronLabel = UILabel()
        chevronLabel.text = "▼"
        chevronLabel.font = button.titleLabel?.font
        chevronLabel.textColor = .gray
        chevronLabel.translatesAutoresizingMaskIntoConstraints = false
        button.addSubview(chevronLabel)

        // Add constraints to align the text and chevron
        NSLayoutConstraint.activate([
            // Align the text label to the left
            textLabel.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 10),
            textLabel.centerYAnchor.constraint(equalTo: button.centerYAnchor),

            // Align the chevron label to the right
            chevronLabel.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -10),
            chevronLabel.centerYAnchor.constraint(equalTo: button.centerYAnchor)
        ])
    }

    
    private func loadDropdownData() {
        // Load PI data from UserSession
        piList = UserSession.shared.pis.map { $0["pi_name"] as? String ?? "Unknown PI" }
    }
    
    // Updating Room List
    private func updateRoomList(for piIndex: Int) {
        print("Updating room list for PI index:", piIndex)

        guard piIndex < UserSession.shared.pis.count,
              let rooms = UserSession.shared.pis[piIndex]["rooms"] as? [[String: Any]] else {
            roomList = []
            print("No rooms found for PI index:", piIndex)
            return
        }

        roomList = rooms.map { room in
            let roomNumber = room["room_number"] as? String ?? "Unknown Room"
            let buildingName = room["building_name"] as? String ?? "Unknown Building"
            return "\(roomNumber), \(buildingName)"
        }

        // Debugging
        print("Updated room list:", roomList)

        // If restoring, keep selectedRoomIndex valid
        if selectedRoomIndex >= roomList.count {
            selectedRoomIndex = 0
        }

        if selectedRoomIndex < roomList.count {
            let selectedRoom = roomList[selectedRoomIndex]
            updateButtonTitle(button: roomButton, newTitle: selectedRoom)
        } else {
            updateButtonTitle(button: roomButton, newTitle: "No Rooms")
        }

    }

    // Saving selections to UserDefaults
    private func saveSelections() {
        print("Saving selections: PI: \(selectedPIIndex), Room: \(selectedRoomIndex)")
        UserDefaults.standard.setValue(selectedPIIndex, forKey: "selectedPIIndex")
        UserDefaults.standard.setValue(selectedRoomIndex, forKey: "selectedRoomIndex")
    }




    
    // Restoring selections from UserDefaults
    private func restoreSelections() {
        selectedPIIndex = UserDefaults.standard.integer(forKey: "selectedPIIndex")
        selectedRoomIndex = UserDefaults.standard.integer(forKey: "selectedRoomIndex")

        // Debugging
        print("Restored selectedPIIndex:", selectedPIIndex)
        print("Restored selectedRoomIndex:", selectedRoomIndex)
    }

    
    // Handling PI Dropdown Toggle
    @IBAction func togglePiDropdown(_ sender: UIButton) {
        toggleDropdown(
            dropdownView: &piDropdownView, // Pass the `piDropdownView` variable
            button: piButton,
            options: piList
        ) { [weak self] selectedOption, selectedIndex in
            guard let self = self else { return }
            self.selectedPIIndex = selectedIndex
            print("PI selected:", selectedOption, "at index:", selectedIndex)
            
            self.updateButtonTitle(button: self.piButton, newTitle: selectedOption)

            // Update Room List for Selected PI
            self.updateRoomList(for: selectedIndex)

            // Reset Room Index to 0 for New PI
            self.selectedRoomIndex = 0
            if let firstRoom = self.roomList.first {
                self.updateButtonTitle(button: self.roomButton, newTitle: firstRoom)
            } else {
                self.updateButtonTitle(button: self.roomButton, newTitle: "No Rooms")
            }

            // Save Selection
            print("saveselection at pidropdown")
            self.saveSelections()
        }
    }


    // Handling Room Dropdown Toggle
    @IBAction func toggleRoomDropdown(_ sender: UIButton) {
        toggleDropdown(
            dropdownView: &roomDropdownView, // Pass the `roomDropdownView` variable
            button: roomButton,
            options: roomList
        ) { [weak self] selectedOption, selectedIndex in
            guard let self = self else { return }
            self.selectedRoomIndex = selectedIndex
            print("Room selected:", selectedOption, "at index:", selectedIndex)
            
            self.updateButtonTitle(button: self.roomButton, newTitle: selectedOption)

            // Save Selection
            print("saveselection at roomdropdown")
            self.saveSelections()
        }
    }


    private func toggleDropdown(
        dropdownView: inout UIView?,
        button: UIButton,
        options: [String],
        onSelect: @escaping (String, Int) -> Void
    ) {
        // Remove existing dropdown if already visible
        dropdownView?.removeFromSuperview()
        dropdownView = nil

        // Create a new dropdown view
        let dropdown = UIView()
        dropdown.layer.borderColor = UIColor.gray.cgColor
        dropdown.layer.borderWidth = 1
        dropdown.layer.cornerRadius = 8
        dropdown.backgroundColor = .white

        // Calculate dropdown size and position
        dropdown.frame = CGRect(
            x: button.frame.origin.x,
            y: button.frame.origin.y + button.frame.height,
            width: button.frame.width,
            height: CGFloat(options.count * 44)
        )

        // Add options as buttons to the dropdown
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
            optionButton.tag = index // Save the index for selection
            optionButton.addTarget(self, action: #selector(optionSelected(_:)), for: .touchUpInside)
            dropdown.addSubview(optionButton)
        }

        // Add the dropdown view to the parent view
        self.view.addSubview(dropdown)
        dropdownView = dropdown
    }

    func getRoomID(for piName: String, roomNumber: String) -> Int? {
        print("DEBUG: Searching for room ID")
        print("DEBUG: Provided PI Name: \(piName)")
        print("DEBUG: Provided Room Number: \(roomNumber)")
        
        // Search UserSession for the PI
        guard let pi = UserSession.shared.pis.first(where: { $0["pi_name"] as? String == piName }) else {
            print("DEBUG: PI not found in UserSession.pis")
            return nil
        }
        print("DEBUG: Found PI: \(pi)")
        
        // Retrieve rooms associated with the PI
        guard let rooms = pi["rooms"] as? [[String: Any]] else {
            print("DEBUG: No rooms found for PI: \(piName)")
            return nil
        }
        print("DEBUG: Found Rooms: \(rooms)")

        // Search for the room with the matching room number
        let room = rooms.first(where: { $0["room_number"] as? String == roomNumber })
        if let room = room {
            print("DEBUG: Found Room: \(room)")
        } else {
            print("DEBUG: Room with number \(roomNumber) not found in rooms")
        }

        // Return the room ID
        let roomID = room?["room_id"] as? Int
        if let roomID = roomID {
            print("DEBUG: Returning Room ID: \(roomID)")
        } else {
            print("DEBUG: Room ID not found for room number \(roomNumber)")
        }
        return roomID
    }
    
    @IBAction func scanLabelButtonTapped(_ sender: UIButton) {
        let ocrScannerVC = OCRScannerViewController()
        ocrScannerVC.onTextRecognized = { [weak self] casNumber, amount, barcode in
            guard let self = self else { return }
            
            print("DEBUG: Received CAS: \(casNumber ?? "N/A"), Amount: \(amount ?? "N/A"), Barcode: \(barcode ?? "N/A")")
            
            if let cas = casNumber {
                self.casNumberTextField.text = cas
                
                // Use CAS API to fetch CAS name
                NetworkManager.shared.casAPI(casNumber: cas) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let casName):
                            // Strip HTML tags and set the cleaned name
                            let cleanedName = self.stripHTMLTags(from: casName)
                            print("DEBUG: Cleaned CAS Name: \(cleanedName)")
                            self.nameTextField.text = cleanedName
                        case .failure(let error):
                            print("DEBUG: Failed to fetch CAS name: \(error.errorMessage)")
                            self.nameTextField.text = "N/A"
                        }
                    }
                }
            } else {
                self.nameTextField.text = "N/A"
            }
            
            if let amt = amount {
                self.amountTextField.text = amt
            }
            if let bc = barcode {
                self.barcodeTextField.text = bc
            }
        }
        present(ocrScannerVC, animated: true)
    }
    
    private func stripHTMLTags(from string: String) -> String {
        let regex = try? NSRegularExpression(pattern: "<.*?>", options: [])
        let range = NSRange(location: 0, length: string.utf16.count)
        let cleanString = regex?.stringByReplacingMatches(in: string, options: [], range: range, withTemplate: "") ?? string
        return cleanString
    }
    
    private func addKeyboardDismissGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        print("DEBUG: Tap detected, dismissing keyboard.")
        self.view.endEditing(true)
    }

  
}

extension AddChemicalViewController {
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension AddChemicalViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == spaceTextField {
            print("DEBUG: Space field tapped.")
            spaceFieldTapped() // Trigger the tap logic
            return false // Prevent the cursor from appearing
        }
        return true // Allow other text fields to be editable
    }
}
