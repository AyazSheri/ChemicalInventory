//
//  InventoryView.swift
//  Uscann
//
//  Created by Nabaa Naveed on 10/2/24.
//


import SwiftUI

struct InventoryView: View {
    var body: some View {
        VStack {
            Text("Inventory View")
                .font(.title)
                .padding()

            Spacer()

            // Back Button
            NavigationLink(destination: MainPageView()) {
                Text("Back to Main Page")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal)

            Spacer()
        }
        .navigationTitle("Inventory")
    }
}
