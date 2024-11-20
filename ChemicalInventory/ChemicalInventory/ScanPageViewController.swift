//
//  ScanPageViewController.swift
//  ChemicalInventory
//
//  Created by Alex Vasiliev on 11/17/24.
//

import UIKit
import SCLAlertView

class ScanPageViewController: UIViewController {
    // Outlets for UI Elements
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var piButton: UIButton!
    @IBOutlet weak var roomButton: UIButton!
    @IBOutlet weak var scanButton: UIButton!
    
    // Data for Dropdowns
    var piList: [String] = []
    var roomList: [String] = []
    var selectedPIIndex: Int = 0 // Track selected PI
    var selectedRoomIndex: Int = 0 // Track selected Room
    
    
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
        setupButton(button: piButton, initialTitle: piList[selectedPIIndex])
        setupButton(button: roomButton, initialTitle: roomList[selectedRoomIndex])
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


    
    func checkChemical(barcode: String) {
        // Get the selected PI and room number
        let selectedPIName = piList[selectedPIIndex]
        let selectedRoomName = roomList[selectedRoomIndex] // E.g., "101, Building A"
        let selectedRoomNumber = selectedRoomName.split(separator: ",").first?.trimmingCharacters(in: .whitespaces) ?? ""

        // Fetch the room ID
        guard let selectedRoomID = getRoomID(for: selectedPIName, roomNumber: selectedRoomNumber) else {
            print("Room ID not found for the selected room")
            return
        }
        
        print("Selected Room ID: \(selectedRoomID)")

        // Call the NetworkManager to check the chemical
        NetworkManager.shared.checkChemical(barcode: barcode, selectedRoomID: selectedRoomID) { result in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                switch result {
                case .success(let chemicalInfo):
                    print("DEBUG: Successfully fetched chemical info: \(chemicalInfo)")

                    // Use the retrieved chemical information to display the popup
                    ChemicalPopupManager.shared.showChemicalInfoPopup(chemicalInfo: chemicalInfo, in: self)

                case .failure(let error):
                    print("DEBUG: Error received: \(error.errorMessage)")
                    self.showAlert(title: "Error", message: error.errorMessage)
                }
            }
        }
    }



    
    @IBAction func openBarcodeScanner(_ sender: UIButton) {
        let scannerVC = BarcodeScannerViewController()
        scannerVC.modalPresentationStyle = .fullScreen
        scannerVC.onBarcodeScanned = { [weak self] barcode in
            guard let self = self else { return }
            scannerVC.dismiss(animated: true) {
                // Debug log for scanned barcode
                print("DEBUG: Scanned barcode: \(barcode)")

                // Call checkChemical to process the scanned barcode
                self.checkChemical(barcode: barcode)
            }
        }
        present(scannerVC, animated: true)
    }



    
    


    func logout() {
        UserSession.shared.clearSession()
        
        // Navigate back to LoginView
        if let loginVC = storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
            self.navigationController?.setViewControllers([loginVC], animated: true)
        }
    }
    
    @IBAction func logoutTapped(_ sender: UIButton) {
        logout()
    }

    
}

extension ScanPageViewController {
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
