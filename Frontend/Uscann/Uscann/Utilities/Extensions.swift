//
//  Extensions.swift
//  Uscann
//
//


import Foundation
import SwiftUI

extension View {
    func customButtonStyle() -> some View {
        self.padding()
            .background(Color.blue)
            .cornerRadius(8)
            .foregroundColor(.white)
    }
}
