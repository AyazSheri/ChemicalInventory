//
//  ProfileView.swift
//  Uscann
//
//  Created by Nabaa Naveed on 10/2/24.
//


import SwiftUI

struct ProfileView: View {
    @State private var user: User = User(firstName: "David", lastName: "Graves", email: "david@example.com", phone: "555-1234", isPI: true, isResearcher: false)
    
    var body: some View {
        VStack {
            Text("Profile")
                .font(.title)
                .padding()
            
            List {
                Text("First Name: \(user.firstName)")
                Text("Last Name: \(user.lastName)")
                Text("Email: \(user.email)")
                Text("Phone: \(user.phone)")
                Text("Role: \(user.isPI ? "PI" : "Researcher")")
            }
        }
    }
}
