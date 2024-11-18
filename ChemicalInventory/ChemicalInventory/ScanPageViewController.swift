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
        
        // Set Default Values for Buttons
        piButton.setTitle("\(piList[0]) ▼", for: .normal)
        roomButton.setTitle("\(roomList[0]) ▼", for: .normal)
        
        // Align button text to the center
        piButton.contentHorizontalAlignment = .center
        roomButton.contentHorizontalAlignment = .center
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
        
        // Create dropdown if it doesn't exist
        if dropdownView == nil {
            let dropdown = UIView(frame: CGRect(
                x: button.frame.origin.x,
                y: button.frame.origin.y + button.frame.height,
                width: button.frame.width,
                height: CGFloat(options.count * 44)
            ))
            dropdown.layer.borderColor = UIColor.gray.cgColor
            dropdown.layer.borderWidth = 1
            dropdown.layer.cornerRadius = 8
            dropdown.backgroundColor = .white
            
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
            
            self.view.addSubview(dropdown)
            dropdownView = dropdown
        } else {
            // Hide dropdown if already visible
            dropdownView?.removeFromSuperview()
            dropdownView = nil
        }
    }
    
    @objc private func optionSelected(_ sender: UIButton) {
        guard let title = sender.currentTitle else { return }
        if sender.superview == piDropdownView {
            piButton.setTitle("\(title) ▼", for: .normal)
            piDropdownView?.removeFromSuperview()
        } else if sender.superview == roomDropdownView {
            roomButton.setTitle("\(title) ▼", for: .normal)
            roomDropdownView?.removeFromSuperview()
        }
    }
}
