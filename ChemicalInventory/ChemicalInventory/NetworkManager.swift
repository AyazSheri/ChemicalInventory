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
    //private var baseURL = "http://192.168.1.31:5000" // machine ip
    private var baseURL = "https://mobile-chemical-inventory-40584a411faf.herokuapp.com/" // online server
    func setBaseURL(to url: String) {
        baseURL = url
    }
    
    enum NetworkError: Error {
        case invalidURL
        case invalidResponse
        case serverError(String)
        case unexpectedStatusCode(Int)
        case dataParsingFailed(String)
        
        var errorMessage: String {
            switch self {
            case .invalidURL:
                return "The provided URL is invalid."
            case .invalidResponse:
                return "The server response is invalid."
            case .serverError(let message):
                return message
            case .unexpectedStatusCode(let statusCode):
                return "Unexpected status code: \(statusCode)"
            case .dataParsingFailed(let details):
                return "Data parsing failed: \(details)"
            }
        }
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
    
    func checkChemical(barcode: String, selectedRoomID: Int, completion: @escaping (Result<[String: Any], NetworkError>) -> Void) {
        guard let url = URL(string: "\(baseURL)/scan/check_chemical") else {
            completion(.failure(.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["barcode": barcode, "selected_room_id": selectedRoomID]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.serverError(error.localizedDescription)))
                return
            }

            guard let data = data, let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse))
                return
            }

            switch httpResponse.statusCode {
            case 200:
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let chemicalInfo = json["chemical_info"] as? [String: Any] {
                    completion(.success(chemicalInfo))
                } else {
                    completion(.failure(.dataParsingFailed("Unexpected data format")))
                }

            case 404, 400:
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let alertMessage = json["alert"] as? String {
                    print("DEBUG: Received alert from server: \(alertMessage)")
                    completion(.failure(.serverError(alertMessage))) // Pass server alert as error
                } else {
                    print("DEBUG: Unable to parse error response from server")
                    completion(.failure(.dataParsingFailed("Unable to parse server response for error 400/404")))
                }


            default:
                completion(.failure(.unexpectedStatusCode(httpResponse.statusCode)))
            }
        }
        task.resume()
    }

}
