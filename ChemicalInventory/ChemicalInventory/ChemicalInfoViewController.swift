import UIKit

class ChemicalInfoViewController: UIViewController {
    // Properties for Chemical Info
    var chemicalName: String = ""
    var casNumber: String = ""
    var amount: Double = 0.0
    var unit: String = "g"
    var expirationDate: String = ""

    var onEnterUsedAmountTapped: ((Double, String) -> Void)?
    var onEditTapped: (() -> Void)?

    private var stackView: UIStackView!

    override func viewDidLoad() {
        super.viewDidLoad()
        print("ChemicalInfoViewController loaded with:")
        print("Name: \(chemicalName), CAS: \(casNumber), Amount: \(amount), Unit: \(unit), Expiration: \(expirationDate)")

        setupView()
    }

    private func setupView() {
        view.backgroundColor = .white
        view.layer.cornerRadius = 12

        // Create labels
        let nameLabel = createLabel(text: "Name: \(chemicalName)")
        let casLabel = createLabel(text: "CAS: \(casNumber)")
        let amountLabel = createLabel(text: "Remaining: \(amount) \(unit)")
        let expirationLabel = createLabel(text: "Expires on: \(expirationDate)")

        // Create buttons
        let enterButton = createButton(title: "Enter Used Amount", action: #selector(enterUsedAmount))
        let editButton = createButton(title: "Edit", action: #selector(editChemical))
        let cancelButton = createButton(title: "Cancel", action: #selector(closeDialog))

        // Stack view setup
        stackView = UIStackView(arrangedSubviews: [nameLabel, casLabel, amountLabel, expirationLabel, enterButton, editButton, cancelButton])
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)

        // Apply constraints
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    private func createLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.textColor = .black
        return label
    }

    private func createButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return button
    }

    @objc private func enterUsedAmount() {
        print("Enter Used Amount tapped")
        
        let alertController = UIAlertController(title: "Enter Used Amount", message: nil, preferredStyle: .alert)

        // Add text field for amount input
        alertController.addTextField { textField in
            textField.placeholder = "Amount"
            textField.keyboardType = .decimalPad
        }

        // Add unit selection using UISegmentedControl
        let unitOptions: [String] = unit == "g" || unit == "kg" || unit == "mg"
            ? ["g", "kg", "mg"]
            : ["mL", "L", "uL"]

        let segmentedControl = UISegmentedControl(items: unitOptions)
        segmentedControl.selectedSegmentIndex = unitOptions.firstIndex(of: unit) ?? 0
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false

        // Wrap UISegmentedControl in a container view
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: 250, height: 40))
        customView.addSubview(segmentedControl)

        NSLayoutConstraint.activate([
            segmentedControl.centerXAnchor.constraint(equalTo: customView.centerXAnchor),
            segmentedControl.centerYAnchor.constraint(equalTo: customView.centerYAnchor)
        ])

        // Add the container view as a subview of the alert
        alertController.view.addSubview(customView)

        NSLayoutConstraint.activate([
            customView.leadingAnchor.constraint(equalTo: alertController.view.leadingAnchor, constant: 16),
            customView.trailingAnchor.constraint(equalTo: alertController.view.trailingAnchor, constant: -16),
            customView.topAnchor.constraint(equalTo: alertController.view.bottomAnchor, constant: -60), // Adjust for spacing
            customView.heightAnchor.constraint(equalToConstant: 50)
        ])

        // Save action
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let textField = alertController.textFields?.first,
                  let inputText = textField.text,
                  let usedAmount = Double(inputText) else { return }

            let selectedUnit = unitOptions[segmentedControl.selectedSegmentIndex]
            print("Entered Amount: \(usedAmount) \(selectedUnit)")
            self.onEnterUsedAmountTapped?(usedAmount, selectedUnit)
        }

        // Cancel action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true)
    }


    @objc private func unitChanged(_ sender: UISegmentedControl) {
        print("Unit changed to \(sender.titleForSegment(at: sender.selectedSegmentIndex) ?? "")")
    }

    @objc private func editChemical() {
        print("Edit tapped")
        onEditTapped?()
        dismiss(animated: true)
    }

    @objc private func closeDialog() {
        print("Cancel tapped")
        dismiss(animated: true)
    }
}
