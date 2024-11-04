//
//  SignUpView.swift
//  Uscann
//
//  Created by Nabaa Naveed on 10/2/24.
//


import SwiftUI

struct SignUpView: View {
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var id = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isPI = false
    @State private var isResearcher = false
    
    var body: some View {
        VStack {
            Text("Create Your Account")
                .font(.title)
                .padding(.bottom, 20)
            
            TextField("First Name", text: $firstName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            TextField("Last Name", text: $lastName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            TextField("ID", text: $id)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            SecureField("Confirm Password", text: $confirmPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            Toggle(isOn: $isPI) {
                Text("PI")
            }
            .padding()
            
            Toggle(isOn: $isResearcher) {
                Text("Researcher")
            }
            .padding()
            
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
    }
}
