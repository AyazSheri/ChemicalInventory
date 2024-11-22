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
        VStack(alignment: .leading, spacing: 20) { // Align content to the left
            Spacer().frame(height: 60) // Space for status bar
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
            Spacer() // Push items to the top
            
            Button(action: {
                onNavigate?("Logout") // Trigger logout
                isMenuOpen = false // Close menu
            }) {
                Text("Logout")
                    .font(.headline)
                    .foregroundColor(.red) // Highlight logout in red
            }
            .padding(.top, 40)
        }
        .padding()
        .frame(maxWidth: UIScreen.main.bounds.width * 0.75)
        .background(Color.gray.opacity(1.0))
        .edgesIgnoringSafeArea(.vertical)
    }
}

