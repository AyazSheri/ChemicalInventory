//
//  PIProfilePageViewController.swift
//  ChemicalInventory
//
//  Created by Siyona Mistry on 11/18/24.
//

import UIKit

class PIProfilePageViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var piDetailsLabel: UILabel!
    @IBOutlet weak var labRoomsTableView: UITableView!
    
    // Hardcoded data for PI and lab rooms
    let piName = "Dr. Jane Doe"
    let userId = "PI-12345"
    var labRooms: [LabRoom] = [
        LabRoom(building: "Building A", room: "101", contactName: "John Smith", contactPhone: "555-1234"),
        LabRoom(building: "Building B", room: "202", contactName: "Alice Brown", contactPhone: "555-5678"),
        LabRoom(building: "Building C", room: "303", contactName: "Bob Green", contactPhone: "555-8765")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set PI Details
        piDetailsLabel.text = "PI: \(piName), User ID: \(userId)"
        
        // Table View Setup
        labRoomsTableView.delegate = self
        labRoomsTableView.dataSource = self
        labRoomsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "LabRoomCell")
    }
    
    @IBAction func addNewLabTapped(_ sender: UIButton) {
        presentAddLabPopup()
    }
    
    private func presentAddLabPopup() {
        let alert = UIAlertController(title: "Add New Lab", message: "Enter lab details", preferredStyle: .alert)
        
        // Add text fields
        alert.addTextField { $0.placeholder = "Building" }
        alert.addTextField { $0.placeholder = "Room #" }
        alert.addTextField { $0.placeholder = "Contact Name" }
        alert.addTextField { $0.placeholder = "Contact Phone" }
        
        // Add buttons
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            if let building = alert.textFields?[0].text,
               let room = alert.textFields?[1].text,
               let contactName = alert.textFields?[2].text,
               let contactPhone = alert.textFields?[3].text {
                
                // Add to data source
                let newLab = LabRoom(building: building, room: room, contactName: contactName, contactPhone: contactPhone)
                self.labRooms.append(newLab)
                
                // Reload table
                self.labRoomsTableView.reloadData()
            }
        }))
        
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - Table View DataSource & Delegate
extension PIProfilePageViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return labRooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LabRoomCell", for: indexPath)
        let lab = labRooms[indexPath.row]
        cell.textLabel?.text = "Building: \(lab.building), Room: \(lab.room)"
        cell.detailTextLabel?.text = "Contact: \(lab.contactName), Phone: \(lab.contactPhone)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Navigate to Inventory Page (placeholder for now)
        print("Navigating to inventory for lab: \(labRooms[indexPath.row].room)")
    }
}

// MARK: - Data Model
struct LabRoom {
    var building: String
    var room: String
    var contactName: String
    var contactPhone: String
}

