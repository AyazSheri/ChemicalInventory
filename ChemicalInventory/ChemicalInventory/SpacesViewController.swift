//
//  SpacesViewController.swift
//  ChemicalInventory
//
//  Created by Alex Vasiliev on 12/1/24.
//


import UIKit
import SCLAlertView
//ver1
class SpacesViewController: BaseViewController, UITextFieldDelegate {
    // MARK: - Properties
    var roomID: Int!
    private var roomNumber: String = ""
    private var buildingName: String = ""
    private var contactName: String = ""
    private var contactPhone: String = ""
    private var spaces: [[String: String?]] = []
    
    private var roomDetailsLabel: UILabel!
    private var contactNameField: UITextField!
    private var contactPhoneField: UITextField!
    private var spacesTableView: UITableView!
    
    // Tracking Changes
    private var modifiedSpaces: [[String: String?]] = []
    private var isContactChanged: Bool = false
    private var isPhoneChanged: Bool = false
    
    // Original entries to text fields
    private var originalContactName: String = ""
    private var originalContactPhone: String = ""

    
    // MARK: - Initialization
    init(roomID: Int) {
        super.init(nibName: nil, bundle: nil)
        self.roomID = roomID
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        print("DEBUG: SpacesViewController initialized with roomID: \(String(describing: roomID))")
    }

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("DEBUG: SpacesViewController loaded with Room ID:", roomID)
        setPageTitle("Spaces")
        setupUI()
        fetchRoomDetails()
        addKeyboardDismissGesture()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .systemBackground

        // Room Details Label
        roomDetailsLabel = UILabel()
        roomDetailsLabel.text = ""
        roomDetailsLabel.font = UIFont.boldSystemFont(ofSize: 16)
        roomDetailsLabel.translatesAutoresizingMaskIntoConstraints = false
        roomDetailsLabel.layer.zPosition = -1
        view.addSubview(roomDetailsLabel)

        // Contact Name Field
        let contactLabel = UILabel()
        contactLabel.text = "Contact:"
        contactLabel.font = UIFont.systemFont(ofSize: 14)
        contactLabel.translatesAutoresizingMaskIntoConstraints = false
        contactLabel.layer.zPosition = -1
        view.addSubview(contactLabel)

        contactNameField = UITextField()
        contactNameField.placeholder = "Enter Contact Name"
        contactNameField.borderStyle = .roundedRect
        contactNameField.translatesAutoresizingMaskIntoConstraints = false
        contactNameField.layer.zPosition = -1
        //contactNameField.addTarget(self, action: #selector(contactFieldChanged), for: .editingChanged)
        contactNameField.delegate = self
        view.addSubview(contactNameField)

        // Contact Phone Field
        let phoneLabel = UILabel()
        phoneLabel.text = "Phone:"
        phoneLabel.font = UIFont.systemFont(ofSize: 14)
        phoneLabel.translatesAutoresizingMaskIntoConstraints = false
        phoneLabel.layer.zPosition = -1
        view.addSubview(phoneLabel)

        contactPhoneField = UITextField()
        contactPhoneField.placeholder = "Enter Contact Phone"
        contactPhoneField.keyboardType = .phonePad
        contactPhoneField.borderStyle = .roundedRect
        contactPhoneField.translatesAutoresizingMaskIntoConstraints = false
        contactPhoneField.layer.zPosition = -1
        //contactPhoneField.addTarget(self, action: #selector(phoneFieldChanged), for: .editingChanged)
        contactPhoneField.delegate = self
        view.addSubview(contactPhoneField)

        // Spaces Label
        let spacesLabel = UILabel()
        spacesLabel.text = "Spaces:"
        spacesLabel.font = UIFont.boldSystemFont(ofSize: 16)
        spacesLabel.translatesAutoresizingMaskIntoConstraints = false
        spacesLabel.layer.zPosition = -1
        view.addSubview(spacesLabel)

        // Spaces Description Label
        let spacesDescriptionLabel = UILabel()
        spacesDescriptionLabel.text = "Description, Type, ID"
        spacesDescriptionLabel.font = UIFont.systemFont(ofSize: 14)
        spacesDescriptionLabel.textColor = .secondaryLabel
        spacesDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        spacesDescriptionLabel.layer.zPosition = -1
        view.addSubview(spacesDescriptionLabel)

        // Table View for Spaces
        spacesTableView = UITableView()
        spacesTableView.delegate = self
        spacesTableView.dataSource = self
        spacesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "SpaceCell")
        spacesTableView.translatesAutoresizingMaskIntoConstraints = false
        spacesTableView.layer.zPosition = -1
        view.addSubview(spacesTableView)


        // Constraints
        NSLayoutConstraint.activate([
            roomDetailsLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            roomDetailsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            roomDetailsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            contactLabel.topAnchor.constraint(equalTo: roomDetailsLabel.bottomAnchor, constant: 20),
            contactLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            contactNameField.topAnchor.constraint(equalTo: contactLabel.bottomAnchor, constant: 5),
            contactNameField.leadingAnchor.constraint(equalTo: contactLabel.leadingAnchor),
            contactNameField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            contactNameField.heightAnchor.constraint(equalToConstant: 44),

            phoneLabel.topAnchor.constraint(equalTo: contactNameField.bottomAnchor, constant: 10),
            phoneLabel.leadingAnchor.constraint(equalTo: contactNameField.leadingAnchor),

            contactPhoneField.topAnchor.constraint(equalTo: phoneLabel.bottomAnchor, constant: 5),
            contactPhoneField.leadingAnchor.constraint(equalTo: phoneLabel.leadingAnchor),
            contactPhoneField.trailingAnchor.constraint(equalTo: contactNameField.trailingAnchor),
            contactPhoneField.heightAnchor.constraint(equalToConstant: 44),

            spacesLabel.topAnchor.constraint(equalTo: contactPhoneField.bottomAnchor, constant: 20),
            spacesLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            spacesDescriptionLabel.topAnchor.constraint(equalTo: spacesLabel.bottomAnchor, constant: 5),
            spacesDescriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            spacesTableView.topAnchor.constraint(equalTo: spacesDescriptionLabel.bottomAnchor, constant: 10),
            spacesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            spacesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            spacesTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)

        ])
    }


    private func fetchRoomDetails() {
        print("DEBUG: Fetching room details for room ID:", roomID)
        NetworkManager.shared.fetchRoomDetails(roomID: roomID) { [weak self] success, roomData, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if success, let roomData = roomData {
                    print("DEBUG: Successfully retrieved room data:", roomData)
                    self.roomNumber = roomData["room_number"] as? String ?? "Unknown"
                    self.buildingName = roomData["building_name"] as? String ?? "Unknown"
                    self.contactName = roomData["contact_name"] as? String ?? ""
                    self.contactPhone = roomData["contact_phone"] as? String ?? ""
                    self.originalContactName = self.contactName
                    self.originalContactPhone = self.contactPhone

                    // Parse spaces data with all fields
                    self.spaces = (roomData["spaces"] as? [[String: Any]])?.map { space in
                        return [
                            "id": space["id"] as? Int != nil ? "\(space["id"]!)" : nil,
                            "description": space["description"] as? String,
                            "space_type": space["space_type"] as? String,
                            "space_id": space["space_id"] as? String
                        ]
                    } ?? []

                    // Debug spaces data
                    print("DEBUG: Spaces data retrieved:", self.spaces)

                    // Update UI
                    self.roomDetailsLabel.text = "Room: \(self.roomNumber), Building: \(self.buildingName)"
                    self.contactNameField.text = self.contactName
                    self.contactPhoneField.text = self.contactPhone
                    self.spacesTableView.reloadData()
                } else {
                    print("DEBUG: Error fetching room details:", error ?? "Unknown error")
                }
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == contactNameField, contactNameField.text != originalContactName {
            showConfirmationAlert(
                field: "Contact",
                newValue: contactNameField.text ?? "",
                originalValue: originalContactName,
                fieldKey: "contact_name" // Field key for backend
            ) { confirmed in
                if confirmed {
                    print("DEBUG: Contact name changed to: \(self.contactNameField.text ?? "") for roomID: \(self.roomID ?? 0)")
                    self.updateRoomField(fieldKey: "contact_name", newValue: self.contactNameField.text ?? "")
                    self.originalContactName = self.contactNameField.text ?? ""
                } else {
                    self.contactNameField.text = self.originalContactName
                }
            }
        } else if textField == contactPhoneField, contactPhoneField.text != originalContactPhone {
            showConfirmationAlert(
                field: "Phone",
                newValue: contactPhoneField.text ?? "",
                originalValue: originalContactPhone,
                fieldKey: "contact_phone" // Field key for backend
            ) { confirmed in
                if confirmed {
                    print("DEBUG: Contact phone changed to: \(self.contactPhoneField.text ?? "") for roomID: \(self.roomID ?? 0)")
                    self.updateRoomField(fieldKey: "contact_phone", newValue: self.contactPhoneField.text ?? "")
                    self.originalContactPhone = self.contactPhoneField.text ?? ""
                } else {
                    self.contactPhoneField.text = self.originalContactPhone
                }
            }
        }
    }

    
    private func showConfirmationAlert(field: String, newValue: String, originalValue: String, fieldKey: String, completion: @escaping (Bool) -> Void) {
        let appearance = SCLAlertView.SCLAppearance(showCloseButton: false)
        let alert = SCLAlertView(appearance: appearance)
        
        alert.addButton("Yes") {
            print("DEBUG: User confirmed changing \(field) to \(newValue).")
            self.updateRoomField(fieldKey: fieldKey, newValue: newValue)
            completion(true)
        }
        alert.addButton("No") {
            print("DEBUG: User canceled changing \(field).")
            completion(false)
        }
        alert.showNotice("Change \(field)?", subTitle: "Do you want to change \(field) to: \(newValue)?")
    }


    private func updateRoomField(fieldKey: String, newValue: String) {
        let updateData: [String: String] = [
            "room_id": "\(roomID ?? -1)",
            fieldKey: newValue
        ]
        
        print("DEBUG: Preparing to update \(fieldKey) to \(newValue) for room ID \(roomID ?? -1). Data: \(updateData)")
        
        NetworkManager.shared.updateRoomField(updateData: updateData) { success, errorMessage in
            DispatchQueue.main.async {
                if success {
                    print("DEBUG: Successfully updated \(fieldKey) to \(newValue) for room ID \(self.roomID ?? -1).")
                    if fieldKey == "contact_name" {
                        self.contactName = newValue
                    } else if fieldKey == "contact_phone" {
                        self.contactPhone = newValue
                    }
                } else {
                    print("DEBUG: Failed to update \(fieldKey): \(errorMessage ?? "Unknown error").")
                }
            }
        }
    }

    // MARK: - Save and Cancel Actions
    @objc private func saveChanges() {
        print("DEBUG: Save changes triggered.")
        print("DEBUG: New Contact Name:", contactNameField.text ?? "")
        print("DEBUG: New Contact Phone:", contactPhoneField.text ?? "")
        print("DEBUG: Modified Spaces:", modifiedSpaces)
    }
    
    @objc private func cancelChanges() {
        print("DEBUG: Cancel changes triggered. Reverting to original data.")
        contactNameField.text = contactName
        contactPhoneField.text = contactPhone
        spacesTableView.reloadData()
        modifiedSpaces = []
    }
    
    @objc private func contactFieldChanged() {
        isContactChanged = true
        print("DEBUG: Contact name changed to:", contactNameField.text ?? "")
    }
    
    @objc private func phoneFieldChanged() {
        isPhoneChanged = true
        print("DEBUG: Contact phone changed to:", contactPhoneField.text ?? "")
    }
}

// MARK: - TableView Delegate & DataSource
extension SpacesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return spaces.count + 1 // Include "Add Space" button
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SpaceCell", for: indexPath)
        
        if indexPath.row < spaces.count {
            let space = spaces[indexPath.row]
            
            let description = space["description"] ?? "No Description"
            let type = space["space_type"] ?? "No Type"
            let id = space["space_id"] ?? "No ID"
            
            let unwrappedDescription = (description?.isEmpty ?? true) ? "No Description" : description!
            let unwrappedType = (type?.isEmpty ?? true) ? "No Type" : type!
            let unwrappedID = (id?.isEmpty ?? true) ? "No ID" : id!

            
            let cellText = "\(unwrappedDescription), \(unwrappedType), \(unwrappedID)"
            print("DEBUG: Setting cell text to:", cellText)
            cell.textLabel?.text = cellText
            cell.textLabel?.textColor = .label
        } else {
            cell.textLabel?.text = "Add Space"
            cell.textLabel?.textColor = .systemBlue
        }
        return cell
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < spaces.count {
            // Existing space
            let space = spaces[indexPath.row]
            print("DEBUG: Selected space at index:", indexPath.row, "Data:", space)

            let spaceID = space["id"] ?? nil
            let description = space["description"] ?? nil
            let type = space["space_type"] ?? nil
            let spaceIDText = space["space_id"] ?? nil

            showEditSpacePopup(spaceID: spaceID, description: description, type: type, spaceIDText: spaceIDText)
        } else {
            // Add new space
            print("DEBUG: Add new space triggered.")
            showEditSpacePopup(spaceID: nil, description: nil, type: nil, spaceIDText: nil)
        }
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

extension SpacesViewController {
    func showEditSpacePopup(spaceID: String?, description: String?, type: String?, spaceIDText: String?) {
        let appearance = SCLAlertView.SCLAppearance(showCloseButton: false, buttonsLayout: .vertical)
        let alert = SCLAlertView(appearance: appearance)

        let descriptionField = alert.addTextField("Description")
        descriptionField.text = description

        let typeField = alert.addTextField("Type")
        typeField.text = type

        let spaceIDField = alert.addTextField("Space ID")
        spaceIDField.text = spaceIDText

        alert.addButton("Save") {
            print("DEBUG: Save button pressed.")
            let updatedDescription = descriptionField.text ?? ""
            let updatedType = typeField.text ?? ""
            let updatedSpaceIDText = spaceIDField.text ?? ""

            // Don't allow saving empty fields
            if updatedDescription.isEmpty && updatedType.isEmpty && updatedSpaceIDText.isEmpty {
                print("DEBUG: Cannot save empty fields.")
                return
            }

            // Prepare data for backend
            var spaceData: [String: Any] = [
                "room_id": self.roomID,
                "description": updatedDescription,
                "space_type": updatedType,
                "space_id": updatedSpaceIDText
            ]
            if let id = spaceID {  // Include 'id' if editing
                spaceData["id"] = id
            }
            print("DEBUG: Data to send to backend:", spaceData)

            // Send data to backend
            NetworkManager.shared.manageSpace(spaceData: spaceData) { success, errorMessage in
                DispatchQueue.main.async {
                    if success {
                        print("DEBUG: Space saved successfully.")
                        self.fetchRoomDetails() // Refresh the page
                    } else {
                        print("DEBUG: Failed to save space:", errorMessage ?? "Unknown error")
                    }
                }
            }
        }

        alert.addButton("Cancel") {
            print("DEBUG: Cancel button pressed.")
        }

        alert.showEdit(spaceID == nil ? "Add Space" : "Edit Space", subTitle: "Modify space details.")
    }
}


