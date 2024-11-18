//
//  SignUpView.swift
//  Uscann
//
import SwiftUI

struct SignUpView: View {
    @Binding var isLoggedIn: Bool
    @State private var name = ""
    @State private var email = ""
    @State private var id = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var selectedRole = ""
    @State private var isDropdownExpanded = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    let roles = ["Researcher", "Principal Investigator (PI)", "Lab Assistant", "Student", "Lab Technician"]
    let firestoreService = FirestoreService()

    var body: some View {
        VStack {
            Text("Sign Up")
                .font(.title)
                .padding(.bottom, 20)

            TextField("Name", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)

            TextField("ID", text: $id)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            SecureField("Confirm Password", text: $confirmPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            // Role Selection Dropdown
            VStack(alignment: .leading) {
                Text("Select Role")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                Button(action: {
                    withAnimation {
                        isDropdownExpanded.toggle()
                    }
                }) {
                    HStack {
                        Text(selectedRole.isEmpty ? "Select a role" : selectedRole)
                            .foregroundColor(selectedRole.isEmpty ? .gray : .black)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                }

                if isDropdownExpanded {
                    ScrollView {
                        ForEach(roles, id: \.self) { role in
                            Button(action: {
                                selectedRole = role
                                isDropdownExpanded = false
                            }) {
                                Text(role)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .foregroundColor(.black)
                        }
                    }
                    .frame(height: 150)
                }
            }
            .padding(.horizontal)

            // Sign Up Button
            Button(action: {
                if password != confirmPassword {
                    alertMessage = "Passwords do not match."
                    showAlert = true
                    return
                }

                firestoreService.createUserProfile(name: name, email: email, id: id, password: password, role: selectedRole) { success, error in
                    if success {
                        alertMessage = "Profile created successfully!"
                        isLoggedIn = true
                    } else {
                        alertMessage = error ?? "Failed to create profile."
                    }
                    showAlert = true
                }
            }) {
                Text("Sign Up")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Sign Up"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"), action: {
                        if isLoggedIn {
                            isLoggedIn = true
                        }
                    })
                )
            }

            Spacer()

            // Navigate to MainPageView after successful sign up
            NavigationLink(destination: MainPageView(), isActive: $isLoggedIn) {
                EmptyView()
            }
        }
        .padding()
    }
}
