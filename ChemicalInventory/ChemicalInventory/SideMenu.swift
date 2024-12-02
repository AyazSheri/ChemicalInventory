//
//  SideMenu.swift
//  ChemicalInventory
//
//  Created by Alex Vasiliev on 11/20/24.
//
import SwiftUI

struct Sidebar: View {
    @Binding var isMenuOpen: Bool
    var onNavigate: ((String) -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 20) { // Default spacing for buttons
            Spacer().frame(height: 60) // Space for status bar

            // Other menu items
            Button(action: {
                onNavigate?("Scan")
                isMenuOpen = false // Close menu
            }) {
                Text("Scan Page")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading) // Ensure left alignment
            }
            Button(action: {
                onNavigate?("AddChemical")
                isMenuOpen = false // Close menu
            }) {
                Text("Add Chemical")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading) // Ensure left alignment
            }
            Button(action: {
                onNavigate?("Profile")
                isMenuOpen = false // Close menu
            }) {
                Text("Rooms")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading) // Ensure left alignment
            }

            // Logout button with custom spacing
            Button(action: {
                onNavigate?("Logout") // Trigger logout
                isMenuOpen = false // Close menu
            }) {
                Text("Logout")
                    .font(.headline)
                    .foregroundColor(.red) // Highlight logout in red
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.top, 40) // Twice the spacing relative to other buttons

            Spacer() // Push the menu items to the top
        }
        .padding()
        .frame(maxWidth: UIScreen.main.bounds.width * 0.75)
        .background(Color.gray.opacity(1.0))
        .edgesIgnoringSafeArea(.vertical)
    }
}


