//
//  MainPageView.swift
//  Uscann
//
//

import SwiftUI

struct MainPageView: View {
    @State private var isShowingScanner = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Welcome to the Chemical Inventory App")
                    .font(.title)
                    .padding()

                Spacer()

                // Inventory Button
                NavigationLink(destination: InventoryView()) {
                    Text("Go to Inventory")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal)

                // Profile Button
                NavigationLink(destination: ProfileView()) {
                    Text("Go to Profile")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal)

                // Settings Button
                NavigationLink(destination: SettingsView()) {
                    Text("Go to Settings")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal)

                // Scan Barcode Button
                Button(action: {
                    isShowingScanner = true
                }) {
                    Text("Scan Barcode")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                .sheet(isPresented: $isShowingScanner) {
                    BarcodeScannerView()
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Main Page")
        }
    }
}

