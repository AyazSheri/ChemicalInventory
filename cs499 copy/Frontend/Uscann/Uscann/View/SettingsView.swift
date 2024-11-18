//
//  SettingsView.swift
//  Uscann
//
//


import SwiftUI

struct SettingsView: View {
    var body: some View {
        List {
            NavigationLink(destination: Text("Edit Account Info")) {
                Text("Account")
            }
            NavigationLink(destination: Text("Manage Notifications")) {
                Text("Notifications")
            }
            NavigationLink(destination: Text("Appearance Settings")) {
                Text("Appearance")
            }
            NavigationLink(destination: Text("Help & Support")) {
                Text("Help & Support")
            }
            NavigationLink(destination: Text("About the App")) {
                Text("About")
            }
        }
        .navigationTitle("Settings")
    }
}
