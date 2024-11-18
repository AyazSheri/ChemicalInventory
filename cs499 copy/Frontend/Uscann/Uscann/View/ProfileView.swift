//
//  ProfileView.swift
//  Uscann
//
//  Created by Nabaa Naveed on 10/2/24.
//


import SwiftUI

struct ProfileView: View {
    var body: some View {
        VStack {
            Text("Profile View")
                .font(.title)
                .padding()

            Spacer()

            // Back Button
            NavigationLink(destination: MainPageView()) {
                Text("Back to Main Page")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal)

            Spacer()
        }
        .navigationTitle("Profile")
    }
}
