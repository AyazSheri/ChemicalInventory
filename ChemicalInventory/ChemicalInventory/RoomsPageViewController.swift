//
//  RoomsPageViewController.swift
//  ChemicalInventory
//
//  Created by Alex Vasiliev on 12/1/24.
//

import UIKit
import SCLAlertView

class RoomsPageViewController: BaseViewController {
    // MARK: - Properties
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var piButton: UIButton!
    
    private var piList: [String] = []
    private var roomList: [(room: String, building: String, roomID: Int)] = []
    private var selectedPIIndex: Int = 0
    
    private var labRoomsTableView: UITableView!
    private var piDropdownView: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()
        setPageTitle("Rooms Page")
        
        // Set user's name
        nameLabel.text = "Name: \(UserSession.shared.userName ?? "Unknown User")"
        
        // Load PI data
        loadPIData()
        restoreSelections()
        
        // Setup UI
        setupUI()
        
        // Load Room Data
        loadRoomData(for: selectedPIIndex)
        
        
    }
    
    private func restoreSelections() {
        selectedPIIndex = UserDefaults.standard.integer(forKey: "selectedPIIndex")
        print("DEBUG: Restored selectedPIIndex:", selectedPIIndex)
    }

    // MARK: - Setup UI
    private func setupUI() {
        // Create PI label
        let piLabel = UILabel()
        piLabel.text = "PI:"
        piLabel.font = nameLabel.font
        piLabel.textAlignment = .left
        piLabel.translatesAutoresizingMaskIntoConstraints = false
        piLabel.layer.zPosition = -1
        view.addSubview(piLabel)

        // Style PI button
        setupButton(button: piButton, initialTitle: piList.isEmpty ? "No PIs Available" : piList[selectedPIIndex])

        // Setup Table View
        labRoomsTableView = UITableView()
        labRoomsTableView.delegate = self
        labRoomsTableView.dataSource = self
        labRoomsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "LabRoomCell")
        labRoomsTableView.translatesAutoresizingMaskIntoConstraints = false
        labRoomsTableView.layer.zPosition = -1
        view.addSubview(labRoomsTableView)

        // Add Constraints
        NSLayoutConstraint.activate([
            // Name Label
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            
            // PI Label
            piLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            piLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 20),
            
            // PI Button
            piButton.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            piButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            piButton.topAnchor.constraint(equalTo: piLabel.bottomAnchor, constant: 10),
            piButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Table View
            labRoomsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            labRoomsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            labRoomsTableView.topAnchor.constraint(equalTo: piButton.bottomAnchor, constant: 20),
            labRoomsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupButton(button: UIButton, initialTitle: String) {
        // Clear previous subviews to avoid overlap
        button.subviews.forEach { $0.removeFromSuperview() }
        
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.gray.cgColor
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.zPosition = -1
        button.addTarget(self, action: #selector(togglePiDropdown), for: .touchUpInside)

        // Add text label
        let textLabel = UILabel()
        textLabel.text = initialTitle
        textLabel.font = button.titleLabel?.font
        textLabel.textColor = button.titleColor(for: .normal) ?? .blue
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        button.addSubview(textLabel)

        // Add chevron
        let chevronLabel = UILabel()
        chevronLabel.text = "▼"
        chevronLabel.font = button.titleLabel?.font
        chevronLabel.textColor = .gray
        chevronLabel.translatesAutoresizingMaskIntoConstraints = false
        button.addSubview(chevronLabel)

        NSLayoutConstraint.activate([
            textLabel.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 10),
            textLabel.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            chevronLabel.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -10),
            chevronLabel.centerYAnchor.constraint(equalTo: button.centerYAnchor)
        ])
    }

    // MARK: - Load Data
    private func loadPIData() {
        piList = UserSession.shared.pis.map { $0["pi_name"] as? String ?? "Unknown PI" }
        print("DEBUG: Loaded PI List:", piList)
    }

    private func loadRoomData(for piIndex: Int) {
        guard piIndex < UserSession.shared.pis.count,
              let rooms = UserSession.shared.pis[piIndex]["rooms"] as? [[String: Any]] else {
            roomList = []
            print("DEBUG: No rooms found for PI index:", piIndex)
            labRoomsTableView.reloadData()
            return
        }

        roomList = rooms.compactMap {
            guard let room = $0["room_number"] as? String,
                  let building = $0["building_name"] as? String,
                  let roomID = $0["room_id"] as? Int else { return nil }
            return (room: room, building: building, roomID: roomID)
        }
        print("DEBUG: Updated room list:", roomList)
        labRoomsTableView.reloadData()
    }

    // MARK: - Dropdown Handling
    @objc private func togglePiDropdown() {
        toggleDropdown(
            dropdownView: &piDropdownView,
            button: piButton,
            options: piList
        ) { [weak self] selectedOption, selectedIndex in
            guard let self = self else { return }
            self.selectedPIIndex = selectedIndex
            self.setupButton(button: self.piButton, initialTitle: selectedOption)
            self.loadRoomData(for: selectedIndex)

            // Save selection
            UserDefaults.standard.set(self.selectedPIIndex, forKey: "selectedPIIndex")
        }
    }

    private func toggleDropdown(
        dropdownView: inout UIView?,
        button: UIButton,
        options: [String],
        onSelect: @escaping (String, Int) -> Void
    ) {
        dropdownView?.removeFromSuperview()
        dropdownView = nil

        let dropdown = UIView()
        dropdown.layer.borderWidth = 1
        dropdown.layer.borderColor = UIColor.gray.cgColor
        dropdown.layer.cornerRadius = 8
        dropdown.backgroundColor = .white
        view.addSubview(dropdown)
        dropdownView = dropdown

        dropdown.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dropdown.leadingAnchor.constraint(equalTo: button.leadingAnchor),
            dropdown.trailingAnchor.constraint(equalTo: button.trailingAnchor),
            dropdown.topAnchor.constraint(equalTo: button.bottomAnchor)
        ])

        var previousButton: UIButton?
        for (index, option) in options.enumerated() {
            let optionButton = UIButton(type: .system)
            optionButton.setTitle(option, for: .normal)
            optionButton.contentHorizontalAlignment = .left
            optionButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
            optionButton.tag = index
            optionButton.addTarget(self, action: #selector(optionSelected(_:)), for: .touchUpInside)
            dropdown.addSubview(optionButton)

            optionButton.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                optionButton.leadingAnchor.constraint(equalTo: dropdown.leadingAnchor),
                optionButton.trailingAnchor.constraint(equalTo: dropdown.trailingAnchor),
                optionButton.topAnchor.constraint(equalTo: previousButton?.bottomAnchor ?? dropdown.topAnchor),
                optionButton.heightAnchor.constraint(equalToConstant: 44)
            ])
            previousButton = optionButton
        }

        if let previousButton = previousButton {
            dropdown.bottomAnchor.constraint(equalTo: previousButton.bottomAnchor).isActive = true
        }
    }

    @objc private func optionSelected(_ sender: UIButton) {
        let selectedOption = piList[sender.tag]
        selectedPIIndex = sender.tag
        setupButton(button: piButton, initialTitle: selectedOption)
        loadRoomData(for: selectedPIIndex)
        piDropdownView?.removeFromSuperview()
    }

    private func getSelectedPIID() -> String? {
        print("DEBUG: Retrieving PI ID for selected index:", selectedPIIndex)
        
        // Ensure the selectedPIIndex is within bounds of the piList
        guard selectedPIIndex >= 0, selectedPIIndex < UserSession.shared.pis.count else {
            print("DEBUG: Invalid PI index:", selectedPIIndex)
            return nil
        }
        
        // Access the PI data
        let piData = UserSession.shared.pis[selectedPIIndex]
        print("DEBUG: PI Data:", piData)
        
        // Retrieve the PI ID as an Int and convert to String
        if let piID = piData["pi_id"] as? Int {
            let piIDString = String(piID)
            print("DEBUG: Retrieved PI ID:", piIDString)
            return piIDString
        } else {
            print("DEBUG: PI ID not found or invalid type")
            return nil
        }
    }
    
    private func showAddRoomPopup() {
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false, // No close button
            buttonsLayout: .vertical
        )
        let alert = SCLAlertView(appearance: appearance)

        let roomNumberField = alert.addTextField("Enter Room Number")
        let contactNameField = alert.addTextField("Enter Contact Name")
        let contactPhoneField = alert.addTextField("Enter Contact Phone")
        
        // Shared variables for building selection
        var selectedBuilding: [String: String?] = [:]
        let buildingTextField = alert.addTextField("Select Building")
        buildingTextField.isUserInteractionEnabled = true // Allow interaction
        buildingTextField.textColor = .gray
        buildingTextField.delegate = self // Prevent typing
        buildingTextField.tag = 0 // Initialize with a default value of 0 (no building selected)

        // Add tap gesture recognizer to the building text field
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(buildingFieldTapped(_:)))
        buildingTextField.addGestureRecognizer(tapGesture)


        alert.addButton("Save") {
            print("DEBUG: Save Room triggered.")
            print("DEBUG: Entered Room Number:", roomNumberField.text ?? "nil")
            print("DEBUG: Entered Contact Name:", contactNameField.text ?? "nil")
            print("DEBUG: Entered Contact Phone:", contactPhoneField.text ?? "nil")
            print("DEBUG: Building ID in text field tag:", buildingTextField.tag)

            // Validation
            guard let roomNumber = roomNumberField.text, !roomNumber.isEmpty,
                  buildingTextField.tag > 0, // Check the tag for a valid building ID
                  let contactName = contactNameField.text, !contactName.isEmpty,
                  let contactPhone = contactPhoneField.text, !contactPhone.isEmpty else {
                print("DEBUG: Missing required fields for adding room.")
                
                // Show UIAlertController for validation
                let validationAlert = UIAlertController(title: "Missing Fields",
                                                        message: "Please fill out all fields.",
                                                        preferredStyle: .alert)
                validationAlert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(validationAlert, animated: true)
                return // Do not proceed with saving
            }

            print("DEBUG: All fields are valid. Building ID:", buildingTextField.tag)

            let newRoomData: [String: Any] = [
                "pi_id": self.getSelectedPIID() ?? "", // Ensure this returns a valid value
                "room_number": roomNumber,
                "building_id": buildingTextField.tag, // Use the tag to get the building ID
                "contact_name": contactName,
                "contact_phone": contactPhone
            ]
            print("DEBUG: Data being sent to backend:", newRoomData)

            // Send data to backend
            NetworkManager.shared.addRoom(newRoomData: newRoomData) { success, message in
                if success {
                    print("DEBUG: Room added successfully. Message: \(message ?? "No message")")
                    DispatchQueue.main.async {
                        self.loadRoomData(for: self.selectedPIIndex) // Refresh room list
                    }
                } else {
                    print("DEBUG: Failed to add room. Error: \(message ?? "Unknown error")")
                    let errorAlert = SCLAlertView()
                    errorAlert.showError("Error", subTitle: message ?? "Failed to add room.")
                }
            }
        }

        alert.addButton("Cancel") {
            print("DEBUG: Add Room canceled.")
        }

        alert.showEdit("Add Room", subTitle: "Enter room details.")
    }
    
    

    @objc private func buildingFieldTapped(_ sender: UITapGestureRecognizer) {
        guard let textField = sender.view as? UITextField else {
            print("DEBUG: No text field associated with tap gesture.")
            return
        }

        // Present the action sheet for building selection
        showBuildingActionSheet { selectedBuilding in
            print("DEBUG: Selected Building:", selectedBuilding)
            textField.text = selectedBuilding["name"] ?? "Select Building"
            if let buildingIDString = selectedBuilding["id"] ?? nil, let buildingID = Int(buildingIDString) {
                textField.tag = buildingID // Assign the building ID to the tag
            } else {
                textField.tag = 0 // Default value if unwrapping fails
            }
        }
    }
    


    private func showBuildingActionSheet(completion: @escaping ([String: String?]) -> Void) {
        NetworkManager.shared.fetchBuildings { buildings, error in
            guard let buildings = buildings else {
                print("DEBUG: Failed to fetch buildings:", error ?? "Unknown error")
                return
            }

            DispatchQueue.main.async {
                let actionSheet = UIAlertController(title: "Select Building", message: nil, preferredStyle: .actionSheet)

                for building in buildings {
                    guard let buildingID = building["id"] as? Int,
                          let buildingName = building["name"] as? String else {
                        continue
                    }

                    actionSheet.addAction(UIAlertAction(title: buildingName, style: .default) { _ in
                        print("DEBUG: Selected Building: \(buildingName) with ID \(buildingID)")
                        completion(["id": "\(buildingID)", "name": buildingName])
                    })
                }

                actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                self.present(actionSheet, animated: true)
            }
        }
    }


}

// MARK: - Table View Delegate and DataSource
extension RoomsPageViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return roomList.count + 1 // Include "Add Room" option
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LabRoomCell", for: indexPath)

        if indexPath.row < roomList.count {
            let room = roomList[indexPath.row]
            cell.textLabel?.text = "\(room.room), \(room.building)"
            cell.textLabel?.textColor = .blue
            cell.accessoryType = .disclosureIndicator
        } else {
            cell.textLabel?.text = "Add Room"
            cell.textLabel?.textColor = .blue
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < roomList.count {
            // Selected an existing room
            let room = roomList[indexPath.row]
            print("DEBUG: Navigating to Spaces page for Room:", room.roomID)

            // Instantiate SpacesViewController
            if let spacesVC = storyboard?.instantiateViewController(withIdentifier: "SpacesViewController") as? SpacesViewController {
                // Pass the room ID to SpacesViewController
                spacesVC.roomID = room.roomID

                navigationController?.pushViewController(spacesVC, animated: true)
            } else {
                print("DEBUG: Failed to instantiate SpacesViewController.")
            }
        } else {
            print("DEBUG: Add Room option selected.")
            showAddRoomPopup()
        }
    }


}

extension RoomsPageViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        // Allow only interaction with the "buildingTextField" through tapping
        if textField.placeholder == "Select Building" {
            return false
        }
        return true
    }
}
