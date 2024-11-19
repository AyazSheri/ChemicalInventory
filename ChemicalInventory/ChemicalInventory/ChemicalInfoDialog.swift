//
//  ChemicalInfoDialog.swift
//  ChemicalInventory
//
//  Created by Alex Vasiliev on 11/18/24.
//
import UIKit

class ChemicalInfoDialog: UIViewController {
    // Properties for Chemical Info
    var chemicalName: String = ""
    var casNumber: String = ""
    var amount: Double = 0.0
    var unit: String = "g"
    var expirationDate: String = ""

    var onEditTapped: (() -> Void)?
    var onEnterUsedAmountTapped: ((Double, String) -> Void)?

    private var amountTextField: UITextField!
    private var unitPicker: UIPickerView!
    private let units = ["g", "kg", "mg", "L", "mL", "uL"]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupDialogView()
    }

    private func setupDialogView() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6) // Semi-transparent background
        let dialogView = UIView()
        dialogView.backgroundColor = .white
        dialogView.layer.cornerRadius = 12
        dialogView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dialogView)

        // Labels for chemical info
        let nameLabel = createLabel(text: "Name: \(chemicalName)")
        let casLabel = createLabel(text: "CAS: \(casNumber)")
        let amountLabel = createLabel(text: "Remaining: \(amount) \(unit)")
        let expirationLabel = createLabel(text: "Expires on: \(expirationDate)")

        // Text field for entering amount
        amountTextField = UITextField()
        amountTextField.placeholder = "Enter amount used"
        amountTextField.borderStyle = .roundedRect
        amountTextField.keyboardType = .decimalPad

        // Picker for unit selection
        unitPicker = UIPickerView()
        unitPicker.dataSource = self
        unitPicker.delegate = self
        unitPicker.selectRow(units.firstIndex(of: unit) ?? 0, inComponent: 0, animated: false)

        // Buttons
        let submitButton = createButton(title: "Submit", action: #selector(submitAmount))
        let editButton = createButton(title: "Edit", action: #selector(editChemical))
        let cancelButton = createButton(title: "Cancel", action: #selector(closeDialog))

        // Arrange elements in a stack view
        let stackView = UIStackView(arrangedSubviews: [
            nameLabel, casLabel, amountLabel, expirationLabel, amountTextField, unitPicker, submitButton, editButton, cancelButton
        ])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        dialogView.addSubview(stackView)

        // Layout constraints
        NSLayoutConstraint.activate([
            dialogView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dialogView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            dialogView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),

            stackView.leadingAnchor.constraint(equalTo: dialogView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: dialogView.trailingAnchor, constant: -20),
            stackView.topAnchor.constraint(equalTo: dialogView.topAnchor, constant: 20),
            stackView.bottomAnchor.constraint(equalTo: dialogView.bottomAnchor, constant: -20)
        ])
    }

    private func createLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        return label
    }

    private func createButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        button.layer.cornerRadius = 8
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return button
    }

    @objc private func submitAmount() {
        guard let text = amountTextField.text, let usedAmount = Double(text) else { return }
        let selectedUnit = units[unitPicker.selectedRow(inComponent: 0)]
        onEnterUsedAmountTapped?(usedAmount, selectedUnit)
        dismiss(animated: true)
    }

    @objc private func editChemical() {
        onEditTapped?()
        dismiss(animated: true)
    }

    @objc private func closeDialog() {
        dismiss(animated: true)
    }
}

// MARK: - UIPickerView Data Source & Delegate
extension ChemicalInfoDialog: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return units.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return units[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // No action needed for now; selection is handled on submit
    }
}

