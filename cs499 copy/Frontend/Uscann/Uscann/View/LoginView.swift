//
//  LoginView.swift
//  Uscann
//
//  Created by Nabaa Naveed on 10/2/24.
//


import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isLoggedIn = false
    @State private var showSignUp = false

    let firestoreService = FirestoreService()

    var body: some View {
        NavigationStack {
            VStack {
                Text("Chemical Inventory Login")
                    .font(.title)
                    .padding(.bottom, 20)

                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)

                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                // Login Button
                Button(action: {
                    firestoreService.loginUser(email: email, password: password) { success, error in
                        if success {
                            alertMessage = "Login successful!"
                            showAlert = true
                        } else {
                            alertMessage = error ?? "Login failed."
                            showAlert = true
                        }
                    }
                }) {
                    Text("Login")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("Login"),
                        message: Text(alertMessage),
                        dismissButton: .default(Text("OK"), action: {
                            if alertMessage == "Login successful!" {
                                isLoggedIn = true
                            }
                        })
                    )
                }

                Spacer()

                // Sign Up Button
                Button(action: {
                    showSignUp = true
                }) {
                    Text("Don't have an account? Sign Up")
                        .foregroundColor(.blue)
                }
                .padding()

                // Navigation to SignUpView
                NavigationLink(destination: SignUpView(isLoggedIn: $isLoggedIn), isActive: $showSignUp) {
                    EmptyView()
                }

                // Navigate to MainPageView after successful login
                NavigationLink(destination: MainPageView(), isActive: $isLoggedIn) {
                    EmptyView()
                }
            }
            .padding()
        }
    }
}
