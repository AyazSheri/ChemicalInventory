//
//  ChemicalPopupManager.swift
//  ChemicalInventory
//
//  Created by Alex Vasiliev on 11/20/24.
//

import UIKit
import SCLAlertView

class ChemicalPopupManager {
    static let shared = ChemicalPopupManager()

    private init() {}

    // MARK: - Show Chemical Info Popup
    func showChemicalInfoPopup(chemicalInfo: [String: Any], in viewController: UIViewController) {
            print("DEBUG: showChemicalInfoPopup called with chemicalInfo: \(chemicalInfo)")
            print("DEBUG: Using viewController: \(viewController)")
            guard let name = chemicalInfo["name"] as? String,
                  let casNumber = chemicalInfo["cas_number"] as? String,
                  let amount = chemicalInfo["amount"] as? Double,
                  let unit = chemicalInfo["unit"] as? String,
                  let room = chemicalInfo["room"] as? String,
                  let expirationDate = chemicalInfo["expiration_date"] as? String else {
                print("ERROR: Missing required chemical information")
                return
            }

            let space = chemicalInfo["space"] as? String  // Optional field for space

            DispatchQueue.main.async {
                let appearance = SCLAlertView.SCLAppearance(
                    showCloseButton: false,
                    buttonsLayout: .vertical
                )
                let alert = SCLAlertView(appearance: appearance)

                let message = """
                Name: \(name)
                CAS: \(casNumber)
                Remaining: \(amount) \(unit)
                Room: \(room)
                \(space != nil ? "Space: \(space!)\n" : "")Expiration: \(expirationDate)
                """
                print("DEBUG: Popup message: \(message)")
                alert.addButton("Use") {
                    ChemicalPopupManager.shared.showChangeAmountPopup(currentAmount: amount, currentUnit: unit, in: viewController)
                }
                alert.addButton("Edit") {
                    ChemicalPopupManager.shared.showEditChemicalPopup(chemicalInfo: chemicalInfo, in: viewController)
                }
                alert.addButton("Cancel", action: {})

                alert.showInfo(message, subTitle: "")
            }
        }

    // MARK: - Show Change Amount Popup
    func showChangeAmountPopup(currentAmount: Double, currentUnit: String, in viewController: UIViewController) {
        DispatchQueue.main.async {
            let appearance = SCLAlertView.SCLAppearance(
                showCloseButton: false,
                buttonsLayout: .horizontal
            )
            let alert = SCLAlertView(appearance: appearance)

            let amountField = alert.addTextField("Enter Amount")
            amountField.keyboardType = .decimalPad

            let unitOptions = currentUnit == "mL" ? ["mL", "L", "uL"] : ["g", "kg", "mg"]
            let containerWidth: CGFloat = 240
            let container = UIView(frame: CGRect(x: 0, y: 0, width: containerWidth, height: 80))
            let unitSegmentedControl = UISegmentedControl(items: unitOptions)
            unitSegmentedControl.frame = CGRect(x: 20, y: 25, width: 200, height: 30)
            unitSegmentedControl.selectedSegmentIndex = 0
            container.addSubview(unitSegmentedControl)

            alert.customSubview = container
            amountField.becomeFirstResponder()

            alert.addButton("Save") {
                guard let enteredAmount = Double(amountField.text ?? ""),
                      unitSegmentedControl.selectedSegmentIndex >= 0 else {
                    print("Invalid input")
                    return
                }
                let selectedUnit = unitOptions[unitSegmentedControl.selectedSegmentIndex]
                print("Entered Amount: \(enteredAmount), Selected Unit: \(selectedUnit)")
            }
            alert.addButton("Cancel", action: {})

            alert.showEdit("Change Amount", subTitle: "Enter used amount and select units")
        }
    }

    // MARK: - Show Edit Chemical Popup
    func showEditChemicalPopup(chemicalInfo: [String: Any], in viewController: UIViewController) {
        guard let name = chemicalInfo["name"] as? String,
              let casNumber = chemicalInfo["cas_number"] as? String,
              let amount = chemicalInfo["amount"] as? Double,
              let unit = chemicalInfo["unit"] as? String,
              let expirationDate = chemicalInfo["expiration_date"] as? String,
              let id = chemicalInfo["id"] as? Int,
              let roomId = chemicalInfo["room_id"] as? Int else {
            print("Error: Missing fields in chemicalInfo.")
            return
        }

        let spaceName = (chemicalInfo["space"] as? String)?.components(separatedBy: " ").first ?? ""

        var spaces: [(name: String, id: Int)] = []  // To store spaces and their IDs

        // Fetch spaces for the given room ID
        NetworkManager.shared.fetchSpaces(for: roomId) { fetchedSpaces in
            spaces = fetchedSpaces.map { ($0.name, $0.id) }  // Convert [Space] to [(name: String, id: Int)]

            DispatchQueue.main.async {
                let appearance = SCLAlertView.SCLAppearance(
                    showCloseButton: false,
                    buttonsLayout: .vertical
                )
                let alert = SCLAlertView(appearance: appearance)

                let nameField = alert.addTextField("Name")
                nameField.text = name

                let casNumberField = alert.addTextField("CAS Number")
                casNumberField.text = casNumber

                let amountField = alert.addTextField("Amount")
                amountField.text = "\(amount)"
                amountField.keyboardType = .decimalPad

                let expirationDateField = alert.addTextField("Expiration Date")
                expirationDateField.text = expirationDate

                let unitField = alert.addTextField("Unit")
                unitField.text = unit
                unitField.addTarget(self, action: #selector(self.unitFieldTapped(_:)), for: .editingDidBegin)
                unitField.inputView = UIView()

                let spaceField = alert.addTextField("Space")
                spaceField.text = spaceName
                spaceField.accessibilityElements = spaces  // Pass pre-fetched spaces
                spaceField.addTarget(self, action: #selector(self.spaceFieldTapped(_:)), for: .editingDidBegin)
                spaceField.inputView = UIView()

                alert.addButton("Save") {
                    guard let editedName = nameField.text,
                          let editedCASNumber = casNumberField.text,
                          let editedAmount = Double(amountField.text ?? ""),
                          let editedExpirationDate = expirationDateField.text else {
                        print("Invalid input")
                        return
                    }

                    let selectedSpaceName = spaceField.text ?? ""
                    let selectedSpaceId = spaces.first(where: { $0.name == selectedSpaceName })?.id ?? -1

                    let updatedChemical = [
                        "id": id,
                        "name": editedName,
                        "cas_number": editedCASNumber,
                        "amount": editedAmount,
                        "unit": unitField.text ?? unit,
                        "expiration_date": editedExpirationDate,
                        "space_id": selectedSpaceId
                    ]

                    NetworkManager.shared.updateChemical(chemicalInfo: updatedChemical) { success in
                        if success {
                            print("Chemical updated successfully")
                        } else {
                            print("Failed to update chemical")
                        }
                    }
                }

                alert.addButton("Cancel", action: {})
                alert.showEdit("Edit Chemical", subTitle: "Modify details below")
            }
        }

    }

    
    // MARK: - Dropdown Handlers
    @objc private func unitFieldTapped(_ sender: UITextField) {
        guard let viewController = sender.window?.rootViewController else {
            print("Error: Unable to find the root view controller.")
            return
        }
        ChemicalPopupManager.shared.showUnitDropdown(from: viewController) { selectedValue in
            sender.text = selectedValue // Update the text field
        }
    }


    @objc private func spaceFieldTapped(_ sender: UITextField) {
        guard let viewController = sender.window?.rootViewController else {
            print("Error: Unable to find the root view controller.")
            return
        }

        // Assume spaces are pre-fetched in showEditChemicalPopup and passed to this method
        guard let spaces = sender.accessibilityElements as? [(name: String, id: Int)] else {
            print("Error: Spaces data not available")
            return
        }
        print("DEBUG: Spaces for dropdown: \(spaces)")  // Debug the spaces passed to dropdown

        ChemicalPopupManager.shared.showSpaceDropdown(from: viewController, spaces: spaces) { selectedValue in
            sender.text = selectedValue // Update the text field
        }
    }


    
    // MARK: - Dropdown Logic
    func showUnitDropdown(from viewController: UIViewController, completion: @escaping (String) -> Void) {
        let alert = UIAlertController(title: "Select Unit", message: nil, preferredStyle: .actionSheet)
        let units = ["kg", "g", "mg", "L", "mL", "uL"]

        for unit in units {
            alert.addAction(UIAlertAction(title: unit, style: .default, handler: { _ in
                completion(unit)
            }))
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        viewController.present(alert, animated: true)
    }

    func showSpaceDropdown(from viewController: UIViewController, spaces: [(name: String, id: Int)], completion: @escaping (String) -> Void) {
        print("DEBUG: Received spaces: \(spaces)")  // Debug the spaces array

        
        let alert = UIAlertController(title: "Select Space", message: nil, preferredStyle: .actionSheet)

        for space in spaces {
            alert.addAction(UIAlertAction(title: space.name, style: .default, handler: { _ in
                completion(space.name)
            }))
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        viewController.present(alert, animated: true)
    }

}
