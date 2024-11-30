//
//  SearchViewController.swift
//  ChemicalInventory
//
//  Created by Alex Vasiliev on 11/28/24.
//

import UIKit

class SearchViewController: UIViewController, UISearchBarDelegate {

    private var searchBar: UISearchBar!
    private var filterSelector: UISegmentedControl!
    private var resultsScrollView: UIScrollView!
    private var resultsStackView: UIStackView!
    private var noResultsLabel: UILabel!
    private var exitButton: UIButton!

    private var results: [[String: Any]] = [] // Stores search results
    private var selectedFilter: String = "Current Room" // Default filter

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        setupSearchBar()
        setupFilterSelector()
        setupResultsView()
        setupExitButton()
        setupDismissKeyboardGesture()

        print("DEBUG: SearchViewController loaded successfully.")
    }

    private func setupSearchBar() {
        searchBar = UISearchBar()
        searchBar.placeholder = "Search by Barcode, CAS, or Name"
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        print("DEBUG: Search bar setup completed.")
    }

    private func setupFilterSelector() {
        filterSelector = UISegmentedControl(items: ["Current Room", "Current PI", "All PIs"])
        filterSelector.selectedSegmentIndex = 0
        filterSelector.addTarget(self, action: #selector(filterChanged), for: .valueChanged)
        filterSelector.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(filterSelector)

        NSLayoutConstraint.activate([
            filterSelector.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10),
            filterSelector.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            filterSelector.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
        ])

        print("DEBUG: Filter selector setup completed with default filter: \(selectedFilter).")
    }

    private func setupResultsView() {
        resultsScrollView = UIScrollView()
        resultsScrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(resultsScrollView)

        resultsStackView = UIStackView()
        resultsStackView.axis = .vertical
        resultsStackView.spacing = 10
        resultsStackView.alignment = .fill
        resultsStackView.distribution = .fill
        resultsStackView.translatesAutoresizingMaskIntoConstraints = false
        resultsScrollView.addSubview(resultsStackView)

        noResultsLabel = UILabel() // Ensure initialization
        noResultsLabel.text = "No results found."
        noResultsLabel.textAlignment = .center
        noResultsLabel.isHidden = true
        noResultsLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(noResultsLabel) // Add to the view hierarchy

        NSLayoutConstraint.activate([
            resultsScrollView.topAnchor.constraint(equalTo: filterSelector.bottomAnchor, constant: 10),
            resultsScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            resultsScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            resultsScrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80),

            resultsStackView.topAnchor.constraint(equalTo: resultsScrollView.topAnchor),
            resultsStackView.leadingAnchor.constraint(equalTo: resultsScrollView.leadingAnchor),
            resultsStackView.trailingAnchor.constraint(equalTo: resultsScrollView.trailingAnchor),
            resultsStackView.widthAnchor.constraint(equalTo: resultsScrollView.widthAnchor),
            resultsStackView.bottomAnchor.constraint(equalTo: resultsScrollView.bottomAnchor),

            noResultsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noResultsLabel.topAnchor.constraint(equalTo: filterSelector.bottomAnchor, constant: 20)
        ])
    }



    private func setupExitButton() {
        exitButton = UIButton(type: .system)
        exitButton.setTitle("Exit Search", for: .normal)
        exitButton.addTarget(self, action: #selector(exitSearch), for: .touchUpInside)
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(exitButton)

        NSLayoutConstraint.activate([
            exitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            exitButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            exitButton.widthAnchor.constraint(equalToConstant: 100),
            exitButton.heightAnchor.constraint(equalToConstant: 40)
        ])

        print("DEBUG: Exit button setup completed.")
    }

    private func setupDismissKeyboardGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        print("DEBUG: Dismiss keyboard gesture setup completed.")
    }

    @objc private func filterChanged() {
        selectedFilter = filterSelector.titleForSegment(at: filterSelector.selectedSegmentIndex) ?? "All PIs"
        print("DEBUG: Filter changed to \(selectedFilter).")
        performSearch() // Reapply search with updated filter
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
        print("DEBUG: Keyboard dismissed.")
    }

    @objc private func exitSearch() {
        dismiss(animated: true)
        print("DEBUG: Exiting search view.")
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performSearch()
        searchBar.resignFirstResponder()
        print("DEBUG: Search initiated for query: \(searchBar.text ?? "None").")
    }

    private func performSearch() {
        guard let query = searchBar.text?.lowercased(), !query.isEmpty else {
            print("DEBUG: Empty query. Clearing results.")
            results = []
            updateResultsView()
            return
        }
        
        print("DEBUG: Initiating search with the following parameters:")
        print("DEBUG: Query: '\(query)'")
        print("DEBUG: Filter: '\(selectedFilter)'")
        print("DEBUG: Selected PI Index: \(UserDefaults.standard.value(forKey: "selectedPIIndex") as? Int ?? -1)")
        print("DEBUG: Selected Room Index: \(UserDefaults.standard.value(forKey: "selectedRoomIndex") as? Int ?? -1)")
        print("DEBUG: Performing search for query '\(query)' with filter '\(selectedFilter)'.")
        
        NetworkManager.shared.searchChemicals(query: query, filter: selectedFilter) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let chemicals):
                    self?.results = chemicals
                    print("DEBUG: Found \(chemicals.count) results.")
                case .failure(let error):
                    self?.results = []
                    print("DEBUG: Search failed with error: \(error.errorMessage).")
                }
                self?.updateResultsView()
            }
        }
    }

    private func updateResultsView() {
        // Debugging: Print the current results count
        print("DEBUG: Updating results view. Results count: \(results.count)")

        // Clear existing results
        let existingSubviewsCount = resultsStackView.arrangedSubviews.count
        resultsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        print("DEBUG: Cleared \(existingSubviewsCount) existing result views.")

        if results.isEmpty {
            // No results found
            noResultsLabel.isHidden = false
            resultsScrollView.isHidden = true // Hide the scroll view when no results
            print("DEBUG: No results to display.")
        } else {
            // Results found
            noResultsLabel.isHidden = true
            resultsScrollView.isHidden = false
            print("DEBUG: Displaying \(results.count) results.")

            for chemical in results {
                // Safely unwrap the values
                let name = chemical["name"] as? String ?? "Unknown"
                let barcode = chemical["barcode"] as? String ?? "Unknown"
                let room = chemical["room_number"] as? String ?? "Unknown"
                let building = chemical["building_name"] as? String ?? "Unknown"

                // Debugging: Print each chemical's details
                print("DEBUG: Adding button for chemical - Name: \(name), Barcode: \(barcode), Room: \(room), Building: \(building)")

                // Create a button for each result
                let button = UIButton(type: .system)
                button.setTitle("\(name) - \(barcode) - \(room) - \(building)", for: .normal)
                button.titleLabel?.numberOfLines = 0 // Allow multiline text
                button.contentHorizontalAlignment = .left
                button.addTarget(self, action: #selector(resultButtonTapped(_:)), for: .touchUpInside)

                button.accessibilityIdentifier = barcode

                resultsStackView.addArrangedSubview(button)
            }
        }

        // Force layout update to ensure the scroll view adjusts
        resultsScrollView.layoutIfNeeded()
        print("DEBUG: Results view updated successfully.")
    }


    @objc private func resultButtonTapped(_ sender: UIButton) {
        // Retrieve the full barcode from the button's accessibilityIdentifier
        if let barcode = sender.accessibilityIdentifier {
            print("DEBUG: Button tapped with barcode: \(barcode)")
            checkChemicalSearch(barcode: barcode)
        } else {
            print("DEBUG: Barcode not found for the tapped button.")
        }
    }

    
    func checkChemicalSearch(barcode: String) {
        // Fetch the selected PI and room indices from UserDefaults
        let selectedPIIndex = UserDefaults.standard.integer(forKey: "selectedPIIndex")
        let selectedRoomIndex = UserDefaults.standard.integer(forKey: "selectedRoomIndex")

        // Validate PI and Room data from UserSession
        guard selectedPIIndex < UserSession.shared.pis.count else {
            print("DEBUG: Invalid selectedPIIndex \(selectedPIIndex).")
            return
        }

        let selectedPI = UserSession.shared.pis[selectedPIIndex]
        guard let piName = selectedPI["pi_name"] as? String,
              let rooms = selectedPI["rooms"] as? [[String: Any]],
              selectedRoomIndex < rooms.count else {
            print("DEBUG: Invalid selectedRoomIndex \(selectedRoomIndex) or missing room data.")
            return
        }

        let selectedRoom = rooms[selectedRoomIndex]
        guard let roomID = selectedRoom["room_id"] as? Int,
              let roomNumber = selectedRoom["room_number"] as? String else {
            print("DEBUG: Room ID or room number not found for selectedRoomIndex \(selectedRoomIndex).")
            return
        }

        print("DEBUG: Selected PI: \(piName), Room: \(roomNumber), Room ID: \(roomID).")

        // Call the NetworkManager to check the chemical
        NetworkManager.shared.checkChemical(barcode: barcode, selectedRoomID: roomID) { result in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }

                switch result {
                case .success(let chemicalInfo):
                    print("DEBUG: Successfully fetched chemical info: \(chemicalInfo)")

                    // Use the retrieved chemical information to display the popup
                    ChemicalPopupManager.shared.showChemicalInfoPopupSearch(chemicalInfo: chemicalInfo, in: self)

                case .failure(let error):
                    print("DEBUG: Error received: \(error.errorMessage)")
                    self.showAlert(title: "Error", message: error.errorMessage)
                }
            }
        }
    }

}

extension SearchViewController {
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}



