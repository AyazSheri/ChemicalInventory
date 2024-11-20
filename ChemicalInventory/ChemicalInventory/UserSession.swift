//
//  Untitled.swift
//  ChemicalInventory
//
//  Created by Alex Vasiliev on 11/19/24.
//

import Foundation

class UserSession {
    static let shared = UserSession() // Singleton instance

    // Properties to store session data
    var userName: String?
    var pis: [[String: Any]] = []
    var isLoggedIn: Bool = false

    // Private initializer to prevent direct instantiation
    private init() {
        print("Initializing UserSession...")
        loadFromUserDefaults()
        print("UserSession initialized with isLoggedIn: \(isLoggedIn), userName: \(userName ?? "nil")")
    }

    // Save session data to UserDefaults
    func saveToUserDefaults() {
        print("Saving session data to UserDefaults...")
        let sessionData: [String: Any] = [
            "user_name": userName ?? "",
            "pis": pis
        ]

        if let serializedData = try? JSONSerialization.data(withJSONObject: sessionData, options: []) {
            UserDefaults.standard.setValue(serializedData, forKey: "userSessionData")
            UserDefaults.standard.setValue(isLoggedIn, forKey: "isLoggedIn")
            print("Session data saved successfully.")
        } else {
            print("Failed to serialize session data.")
        }
    }

    // Load session data from UserDefaults
    func loadFromUserDefaults() {
        print("Loading session data from UserDefaults...")
        if let sessionData = UserDefaults.standard.data(forKey: "userSessionData"),
           let jsonObject = try? JSONSerialization.jsonObject(with: sessionData, options: []) as? [String: Any] {
            userName = jsonObject["user_name"] as? String
            pis = jsonObject["pis"] as? [[String: Any]] ?? []
            isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
            print("Session data loaded: isLoggedIn: \(isLoggedIn), userName: \(userName ?? "nil")")
        } else {
            print("No session data found in UserDefaults.")
        }
    }

    // Clear session data
    func clearSession() {
        print("Clearing session data...")
        userName = nil
        pis = []
        isLoggedIn = false
        UserDefaults.standard.removeObject(forKey: "userSessionData")
        UserDefaults.standard.removeObject(forKey: "isLoggedIn")
        print("Session data cleared.")
    }
}
