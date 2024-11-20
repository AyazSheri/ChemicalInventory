//
//  NetworkManager.swift
//  ChemicalInventory
//
//  Created by Alex Vasiliev on 11/19/24.
//

import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    //private var baseURL = "http://127.0.0.1:5000" // local host
    private var baseURL = "http://192.168.1.31:5000" // machine ip
    func setBaseURL(to url: String) {
        baseURL = url
    }

    func login(email: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        guard let url = URL(string: "\(baseURL)/login") else {
            completion(false, "Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["email": email, "password": password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(false, error.localizedDescription)
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, let data = data else {
                completion(false, "Invalid response")
                return
            }

            if httpResponse.statusCode == 200 {
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let success = json["success"] as? Bool, success {
                    // Save to UserSession
                    UserSession.shared.userName = json["user_name"] as? String
                    UserSession.shared.pis = json["pis"] as? [[String: Any]] ?? []
                    UserSession.shared.isLoggedIn = true

                    // Persist to UserDefaults
                    UserSession.shared.saveToUserDefaults()
                    completion(true, nil)
                } else {
                    completion(false, "Invalid email or password")
                }
            } else {
                completion(false, "Login failed with status code \(httpResponse.statusCode)")
            }
        }
        task.resume()
    }
}
