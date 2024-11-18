//
//  ScanPageViewController.swift
//  ChemicalInventory
//
//  Created by Alex Vasiliev on 11/17/24.
//

import UIKit

class ScanPageViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    // Outlets for UI Elements
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var piButton: UIButton!
    @IBOutlet weak var roomButton: UIButton!
    @IBOutlet weak var piPicker: UIPickerView!
    @IBOutlet weak var roomPicker: UIPickerView!
    
    // Hardcoded Data
    let userName = "John Doe"
    let piList = ["PI 1", "PI 2", "PI 3"]
    let roomList = ["Room 101", "Room 102", "Room 103"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set User's Name
        nameLabel.text = "Name: \(userName)"
        
        // Set Default Values for Buttons
        piButton.setTitle("\(piList[0]) ▼", for: .normal)
        roomButton.setTitle("\(roomList[0]) ▼", for: .normal)
        
        // Align button text to the left
        piButton.contentHorizontalAlignment = .center
        roomButton.contentHorizontalAlignment = .center
        
        // Hide Pickers Initially
        piPicker.isHidden = true
        roomPicker.isHidden = true
        
        // Set Picker Delegates and DataSources
        piPicker.delegate = self
        piPicker.dataSource = self
        
        roomPicker.delegate = self
        roomPicker.dataSource = self
    }
    
    // MARK: - Button Actions
    @IBAction func togglePiPicker(_ sender: UIButton) {
        let isVisible = !piPicker.isHidden
        piPicker.isHidden = isVisible
        roomPicker.isHidden = true // Hide the other picker
        
        // Toggle button and label visibility
        piButton.isHidden = !isVisible
    }
    
    @IBAction func toggleRoomPicker(_ sender: UIButton) {
        // Toggle picker visibility
        let isVisible = !roomPicker.isHidden
        roomPicker.isHidden = isVisible
        piPicker.isHidden = true // Hide the other picker
        
        // Toggle button and label visibility
        roomButton.isHidden = !isVisible
    }
    
    // MARK: - UIPickerView Data Source
    @objc func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    @objc func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == piPicker {
            return piList.count
        } else {
            return roomList.count
        }
    }
    
    // MARK: - UIPickerView Delegate
    @objc func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == piPicker {
            return piList[row]
        } else {
            return roomList[row]
        }
    }
    
    @objc func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == piPicker {
            let selectedPI = piList[row]
            piButton.setTitle("\(selectedPI) ▼", for: .normal)
            piPicker.isHidden = true
            piButton.isHidden = false
        } else {
            let selectedRoom = roomList[row]
            roomButton.setTitle("\(selectedRoom) ▼", for: .normal)
            roomPicker.isHidden = true
            roomButton.isHidden = false
        }
    }
}
