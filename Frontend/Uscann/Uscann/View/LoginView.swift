//
//  LoginView.swift
//  Uscann
//
//  Created by Nabaa Naveed on 10/2/24.
//

import SwiftUI

struct LoginView: View {
    @State private var id = ""
    @State private var password = ""
    
    var body: some View {
        VStack {
            // Displaying the logo at the top center
            Image("logo") // Make sure the logo image is added to Assets.xcassets
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .padding(.top, 40)
            
            Text("Chemical Inventory Login")
                .font(.title)
                .padding(.bottom, 20)
            
            TextField("ID", text: $id)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            Button(action: {
                // Handle Login Logic
            }) {
                Text("Login")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            
            Spacer()
            
            HStack {
                Text("Don't have an account?")
                Button(action: {
                    SignUpView()
                }) {
                    Text("Sign Up")
                        .foregroundColor(.blue)
                }
            }
        }
        .padding()
    }
}
