//
//  LoginView.swift
//  ChemicalInventory
//
//  Created by Alex Vasiliev on 11/19/24.
//

import UIKit

class LoginViewController: UIViewController {
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email"
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none
        textField.keyboardType = .emailAddress
        return textField
    }()

    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Password"
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true
        return textField
    }()

    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // UserSession.shared.clearSession() 

        print("LoginViewController loaded.")
        print("isLoggedIn: \(UserSession.shared.isLoggedIn), userName: \(UserSession.shared.userName ?? "nil")")

        if UserSession.shared.isLoggedIn {
            print("User is already logged in. Navigating to ScanPageViewController.")
            navigateToScanPage()
            return
        }

        view.backgroundColor = .systemBackground
        setupUI()
    }

    private func setupUI() {
        // Add UI elements to the view
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(loginButton)

        // Set constraints
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        loginButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // Email TextField
            emailTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // Password TextField
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // Login Button
            loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            loginButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc private func loginTapped() {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            print("Please fill in all fields.")
            return
        }

        NetworkManager.shared.login(email: email, password: password) { success, errorMessage in
            DispatchQueue.main.async {
                if success {
                    print("Login Successful: \(UserSession.shared.userName ?? "")")
                    self.navigateToScanPage()
                } else {
                    print(errorMessage ?? "Login failed")
                    let alert = UIAlertController(title: "Error", message: errorMessage ?? "An error occurred", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true)
                }
            }
        }
    }

    private func navigateToScanPage() {
        if let scanPageVC = storyboard?.instantiateViewController(withIdentifier: "ScanPageViewController") as? ScanPageViewController {
            navigationController?.setViewControllers([scanPageVC], animated: true)
        }
    }
}
