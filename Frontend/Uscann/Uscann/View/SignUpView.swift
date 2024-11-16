//
//  SignUpView.swift
//  Uscann
//
import SwiftUI

struct SignUpView: View {
    @State private var name = ""
    @State private var email = ""
    @State private var id = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var selectedRole: String = ""
    @State private var isDropdownExpanded = false
    @State private var searchText = ""
    
    // Hardcoded data for the dropdown
    let roles = ["Researcher", "Principal Investigator (PI)", "Lab Assistant", "Student", "Lab Technician"]

    var filteredRoles: [String] {
        roles.filter { searchText.isEmpty || $0.lowercased().contains(searchText.lowercased()) }
    }

    var body: some View {
        VStack {
            Text("Sign Up")
                .font(.title)
                .padding(.bottom, 20)
            
            // Name Field
            TextField("Name", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            // Email Field
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
            
            // ID Field
            TextField("ID", text: $id)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            // Password Field
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            // Confirm Password Field
            SecureField("Confirm Password", text: $confirmPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            // Custom dropdown for selecting a role
            VStack(alignment: .leading) {
                Text("Select Role")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                // Dropdown button
                Button(action: {
                    withAnimation {
                        isDropdownExpanded.toggle()
                    }
                }) {
                    HStack {
                        Text(selectedRole.isEmpty ? "Select a role" : selectedRole)
                            .foregroundColor(selectedRole.isEmpty ? .gray : .black)
                        Spacer()
                        Image(systemName: isDropdownExpanded ? "chevron.up" : "chevron.down")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                }
                
                if isDropdownExpanded {
                    VStack {
                        // Search bar
                        TextField("Search roles...", text: $searchText)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .padding(.horizontal)
                        
                        // Dropdown list
                        ScrollView {
                            VStack(alignment: .leading, spacing: 5) {
                                ForEach(filteredRoles, id: \.self) { role in
                                    Button(action: {
                                        selectedRole = role
                                        isDropdownExpanded = false
                                        searchText = ""
                                    }) {
                                        Text(role)
                                            .padding()
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    .foregroundColor(.black)
                                }
                            }
                            .padding(.vertical, 5)
                        }
                        .frame(height: 150) // Set height for dropdown list
                    }
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color.white).shadow(radius: 5))
                }
            }
            .padding(.horizontal)
            .padding(.top)
            
            // Sign Up Button
            Button(action: {
                // Handle Sign Up Logic
            }) {
                Text("Sign Up")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
    }
}
