//
//  PIProfilePageViewController.swift
//  ChemicalInventory
//
//  Created by Siyona Mistry on 11/18/24.
//

import UIKit

class PIProfilePageViewController: BaseViewController {
    // MARK: - Properties
    private var piLabel: UILabel!
    private var piDropdownButton: UIButton!
    private var piDropdownView: UIView?
    private var labRoomsTableView: UITableView!
    private var piList: [String] = []
    private var selectedPIIndex: Int = 0
    private var roomList: [(room: String, building: String, roomID: Int)] = [] // Room info with ID

    override func viewDidLoad() {
        super.viewDidLoad()

        setPageTitle("PI Profile")
        loadPIData()
        setupUI()
        loadRoomData(for: selectedPIIndex)
    }

    // MARK: - Setup UI
    private func setupUI() {
        // Setup PI Label
        piLabel = UILabel()
        piLabel.text = "PI:"
        piLabel.font = UIFont.systemFont(ofSize: 16)
        piLabel.translatesAutoresizingMaskIntoConstraints = false
        piLabel.layer.zPosition = -1
        view.addSubview(piLabel)

        // Setup Dropdown Button for PI
        piDropdownButton = UIButton(type: .system)
        piDropdownButton.setTitle(piList.isEmpty ? "No PIs Available" : piList[selectedPIIndex], for: .normal)
        piDropdownButton.setTitleColor(.blue, for: .normal)
        piDropdownButton.layer.borderWidth = 1
        piDropdownButton.layer.borderColor = UIColor.gray.cgColor
        piDropdownButton.layer.cornerRadius = 8
        piDropdownButton.translatesAutoresizingMaskIntoConstraints = false
        piDropdownButton.layer.zPosition = -1
        piDropdownButton.addTarget(self, action: #selector(togglePiDropdown), for: .touchUpInside)
        view.addSubview(piDropdownButton)

        // Setup Table View
        labRoomsTableView = UITableView()
        labRoomsTableView.delegate = self
        labRoomsTableView.dataSource = self
        labRoomsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "LabRoomCell")
        labRoomsTableView.translatesAutoresizingMaskIntoConstraints = false
        labRoomsTableView.layer.zPosition = -1
        view.addSubview(labRoomsTableView)

        // Constraints
        NSLayoutConstraint.activate([
            // PI Label
            piLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            piLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),

            // PI Dropdown Button
            piDropdownButton.leadingAnchor.constraint(equalTo: piLabel.leadingAnchor),
            piDropdownButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            piDropdownButton.topAnchor.constraint(equalTo: piLabel.bottomAnchor, constant: 10),
            piDropdownButton.heightAnchor.constraint(equalToConstant: 44),

            // Table View
            labRoomsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            labRoomsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            labRoomsTableView.topAnchor.constraint(equalTo: piDropdownButton.bottomAnchor, constant: 20),
            labRoomsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - Load Data
    private func loadPIData() {
        piList = UserSession.shared.pis.map { $0["pi_name"] as? String ?? "Unknown PI" }
        selectedPIIndex = UserDefaults.standard.integer(forKey: "selectedPIIndex")
    }

    private func loadRoomData(for piIndex: Int) {
        guard piIndex < UserSession.shared.pis.count,
              let rooms = UserSession.shared.pis[piIndex]["rooms"] as? [[String: Any]] else {
            roomList = []
            labRoomsTableView.reloadData()
            return
        }

        roomList = rooms.compactMap {
            guard let room = $0["room_number"] as? String,
                  let building = $0["building_name"] as? String,
                  let roomID = $0["room_id"] as? Int else { return nil }
            return (room: room, building: building, roomID: roomID)
        }
        labRoomsTableView.reloadData()
    }

    // MARK: - Dropdown Handling
    @objc private func togglePiDropdown() {
        toggleDropdown(
            dropdownView: &piDropdownView,
            button: piDropdownButton,
            options: piList
        ) { [weak self] selectedOption, selectedIndex in
            guard let self = self else { return }
            self.selectedPIIndex = selectedIndex
            self.piDropdownButton.setTitle(selectedOption, for: .normal)
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

        // Create dropdown view
        let dropdown = UIView()
        dropdown.layer.borderWidth = 1
        dropdown.layer.borderColor = UIColor.gray.cgColor
        dropdown.layer.cornerRadius = 8
        dropdown.backgroundColor = .white
        view.addSubview(dropdown)
        dropdownView = dropdown

        // Layout dropdown view
        dropdown.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dropdown.leadingAnchor.constraint(equalTo: button.leadingAnchor),
            dropdown.trailingAnchor.constraint(equalTo: button.trailingAnchor),
            dropdown.topAnchor.constraint(equalTo: button.bottomAnchor),
        ])

        // Add options as buttons
        var previousButton: UIButton?
        for (index, option) in options.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(option, for: .normal)
            button.contentHorizontalAlignment = .left
            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
            button.tag = index
            button.addTarget(self, action: #selector(optionSelected(_:)), for: .touchUpInside)
            dropdown.addSubview(button)

            button.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                button.leadingAnchor.constraint(equalTo: dropdown.leadingAnchor),
                button.trailingAnchor.constraint(equalTo: dropdown.trailingAnchor),
                button.topAnchor.constraint(equalTo: previousButton?.bottomAnchor ?? dropdown.topAnchor),
                button.heightAnchor.constraint(equalToConstant: 44),
            ])

            previousButton = button
        }

        // Adjust dropdown height
        if let previousButton = previousButton {
            dropdown.bottomAnchor.constraint(equalTo: previousButton.bottomAnchor).isActive = true
        }
    }

    @objc private func optionSelected(_ sender: UIButton) {
        let selectedOption = piList[sender.tag]
        piDropdownButton.setTitle(selectedOption, for: .normal)
        selectedPIIndex = sender.tag

        // Save selection
        UserDefaults.standard.set(selectedPIIndex, forKey: "selectedPIIndex")

        // Load room data for the selected PI
        loadRoomData(for: selectedPIIndex)

        // Remove dropdown
        piDropdownView?.removeFromSuperview()
        piDropdownView = nil
    }

    // MARK: - Get PI ID
    private func getSelectedPIID() -> String? {
        return UserSession.shared.pis[selectedPIIndex]["pi_id"] as? String
    }
}

// MARK: - Table View Delegate and DataSource
extension PIProfilePageViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return roomList.count + 1 // Include "Add Room" option
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LabRoomCell", for: indexPath)

        if indexPath.row < roomList.count {
            let room = roomList[indexPath.row]
            cell.textLabel?.text = "\(room.room), \(room.building)"
            cell.textLabel?.textColor = .blue // Consistent blue color
            cell.accessoryType = .disclosureIndicator
        } else {
            cell.textLabel?.text = "Add Room"
            cell.textLabel?.textColor = .blue // Consistent blue color
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < roomList.count {
            let room = roomList[indexPath.row]
            print("DEBUG: Navigate to spaces for Room: \(room.roomID)")
        } else {
            // Print PI ID for Add Room
            if let piID = getSelectedPIID() {
                print("DEBUG: Add room to PI: \(piID)")
            } else {
                print("DEBUG: PI ID not found")
            }
        }
    }
}
