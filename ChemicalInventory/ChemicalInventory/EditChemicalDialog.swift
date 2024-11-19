//
//  EditChemicalDialog.swift
//  ChemicalInventory
//
//  Created by Alex Vasiliev on 11/18/24.
//
import UIKit

class EditChemicalDialog: UIViewController {
    // Properties
    var spaces: [String] = [] // List of spaces
    var selectedSpace: String = "" // Currently selected space

    var onSaveTapped: ((String) -> Void)?
    var onDeleteTapped: (() -> Void)?

    // UI Elements
    private let spaceLabel = UILabel()
    private let spacePicker = UIPickerView()
    private let saveButton = UIButton(type: .system)
    private let deleteButton = UIButton(type: .system)
    private let cancelButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    private func setupUI() {
        // Configure the view
        view.backgroundColor = .white
        view.layer.cornerRadius = 12

        // Configure space label
        spaceLabel.text = "Select Space"
        spaceLabel.font = .boldSystemFont(ofSize: 18)
        spaceLabel.textAlignment = .center
        spaceLabel.translatesAutoresizingMaskIntoConstraints = false

        // Configure space picker
        spacePicker.dataSource = self
        spacePicker.delegate = self
        spacePicker.translatesAutoresizingMaskIntoConstraints = false

        // Configure buttons
        configureButton(saveButton, title: "Save", action: #selector(saveChanges))
        configureButton(deleteButton, title: "Delete", action: #selector(deleteChemical))
        configureButton(cancelButton, title: "Cancel", action: #selector(closeDialog))

        // Create a stack view for buttons
        let buttonStackView = UIStackView(arrangedSubviews: [saveButton, deleteButton, cancelButton])
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 10
        buttonStackView.distribution = .fillEqually
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false

        // Add elements to the view
        view.addSubview(spaceLabel)
        view.addSubview(spacePicker)
        view.addSubview(buttonStackView)

        // Add constraints
        NSLayoutConstraint.activate([
            // Space label constraints
            spaceLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            spaceLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            // Space picker constraints
            spacePicker.topAnchor.constraint(equalTo: spaceLabel.bottomAnchor, constant: 20),
            spacePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            spacePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // Button stack view constraints
            buttonStackView.topAnchor.constraint(equalTo: spacePicker.bottomAnchor, constant: 20),
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            buttonStackView.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    private func configureButton(_ button: UIButton, title: String, action: Selector) {
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        button.layer.cornerRadius = 8
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
    }

    // MARK: - Button Actions
    @objc private func saveChanges() {
        onSaveTapped?(selectedSpace)
        dismiss(animated: true)
    }

    @objc private func deleteChemical() {
        onDeleteTapped?()
        dismiss(animated: true)
    }

    @objc private func closeDialog() {
        dismiss(animated: true)
    }
}

// MARK: - UIPickerView Data Source and Delegate
extension EditChemicalDialog: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return spaces.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return spaces[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedSpace = spaces[row]
    }
}
