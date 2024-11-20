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
    private init() {}

    // Save session data to UserDefaults
    func saveToUserDefaults() {
        let sessionData: [String: Any] = [
            "user_name": userName ?? "",
            "pis": pis
        ]

        if let serializedData = try? JSONSerialization.data(withJSONObject: sessionData, options: []) {
            UserDefaults.standard.setValue(serializedData, forKey: "userSessionData")
            UserDefaults.standard.setValue(isLoggedIn, forKey: "isLoggedIn")
        }
    }

    // Load session data from UserDefaults
    func loadFromUserDefaults() {
        if let sessionData = UserDefaults.standard.data(forKey: "userSessionData"),
           let jsonObject = try? JSONSerialization.jsonObject(with: sessionData, options: []) as? [String: Any] {
            userName = jsonObject["user_name"] as? String
            pis = jsonObject["pis"] as? [[String: Any]] ?? []
            isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
        }
    }

    // Clear session data
    func clearSession() {
        userName = nil
        pis = []
        isLoggedIn = false
        UserDefaults.standard.removeObject(forKey: "userSessionData")
        UserDefaults.standard.removeObject(forKey: "isLoggedIn")
    }
}
