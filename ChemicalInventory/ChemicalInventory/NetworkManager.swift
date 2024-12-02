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
    //private var baseURL = "https://mobile-chemical-inventory-40584a411faf.herokuapp.com/" // online server
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
    
    struct Space: Decodable {
        let id: Int
        let name: String
    }
    
    // Update Contact name or Contact phone
    func updateRoomField(updateData: [String: String], completion: @escaping (Bool, String?) -> Void) {
        guard let url = URL(string: "\(baseURL)/rooms/update_field") else {
            completion(false, "Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: updateData, options: [])
        } catch {
            completion(false, "Failed to encode request data")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("DEBUG: Network error:", error.localizedDescription)
                completion(false, error.localizedDescription)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(false, "Server error")
                return
            }
            
            completion(true, nil)
        }
        task.resume()
    }


    
    // Add or Update Space
    func manageSpace(spaceData: [String: Any], completion: @escaping (Bool, String?) -> Void) {
        guard let url = URL(string: "\(baseURL)/manage_space") else {
            completion(false, "Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: spaceData, options: [])
        } catch {
            completion(false, "Error serializing data: \(error.localizedDescription)")
            return
        }
        
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
                print("DEBUG: Space managed successfully.")
                completion(true, nil)
            } else {
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                print("DEBUG: Error managing space. Response: {errorMessage}")
                completion(false, errorMessage)
            }
        }
        task.resume()
    }
    
    
    func fetchRoomDetails(roomID: Int, completion: @escaping (Bool, [String: Any]?, String?) -> Void) {
        let url = URL(string: "\(baseURL)/rooms/details")! // Adjust the endpoint path
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["room_id": roomID]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        print("DEBUG: Sending room details request for room ID:", roomID)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("DEBUG: Network error occurred:", error.localizedDescription)
                completion(false, nil, error.localizedDescription)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200,
                  let data = data else {
                print("DEBUG: Invalid response or no data received.")
                completion(false, nil, "Invalid response or no data received")
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let success = json["success"] as? Bool, success {
                    let roomData = json["room_data"] as? [String: Any]
                    print("DEBUG: Successfully fetched room data:", roomData ?? "No data")
                    completion(true, roomData, nil)
                } else {
                    let message = (try JSONSerialization.jsonObject(with: data) as? [String: Any])?["message"] as? String
                    print("DEBUG: API error occurred:", message ?? "Unknown error")
                    completion(false, nil, message)
                }
            } catch {
                print("DEBUG: JSON parsing error:", error.localizedDescription)
                completion(false, nil, error.localizedDescription)
            }
        }
        task.resume()
    }

    
    func searchChemicals(query: String, filter: String, completion: @escaping (Result<[[String: Any]], NetworkError>) -> Void) {
        guard let url = URL(string: "\(baseURL)/search-chemical") else {
            completion(.failure(.invalidURL))
            return
        }

        // Fetch selected PI and Room indices from UserDefaults
        let selectedPIIndex = UserDefaults.standard.value(forKey: "selectedPIIndex") as? Int ?? 0
        let selectedRoomIndex = UserDefaults.standard.value(forKey: "selectedRoomIndex") as? Int ?? 0

        // Construct the request body
        let body: [String: Any] = [
            "query": query,
            "filter": filter,
            "pi_index": selectedPIIndex,
            "room_index": selectedRoomIndex,
            "pis": UserSession.shared.pis
        ]

        print("DEBUG: Request body being sent: \(body)")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            completion(.failure(.dataParsingFailed("Failed to serialize request body: \(error.localizedDescription)")))
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.serverError(error.localizedDescription)))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, let data = data else {
                completion(.failure(.invalidResponse))
                return
            }

            if httpResponse.statusCode == 200 {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let results = json["results"] as? [[String: Any]] {
                        completion(.success(results))
                    } else {
                        completion(.failure(.dataParsingFailed("Invalid JSON structure.")))
                    }
                } catch {
                    completion(.failure(.dataParsingFailed("Failed to parse response data: \(error.localizedDescription)")))
                }
            } else {
                completion(.failure(.unexpectedStatusCode(httpResponse.statusCode)))
            }
        }
        task.resume()
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
                    UserSession.shared.isPI = false

                    // Persist to UserDefaults
                    UserSession.shared.saveToUserDefaults()
                    completion(true, nil)
                } else {
                    print("DEBUG: User login failed. Attempting PI login.")
                    self.piLogin(email: email, password: password, completion: completion)
                }
            } else {
                print("DEBUG: User login failed. Attempting PI login.")
                //completion(false, "Login failed with status code \(httpResponse.statusCode)")
                self.piLogin(email: email, password: password, completion: completion)
            }
        }
        task.resume()
    }
    
    private func piLogin(email: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        guard let url = URL(string: "\(baseURL)/pi-login") else {
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
                    UserSession.shared.userName = json["pi_name"] as? String // PI name as username
                    UserSession.shared.pis = [[
                        "pi_id": json["pi_id"] as? Int ?? -1,
                        "pi_name": json["pi_name"] as? String ?? "",
                        "rooms": json["rooms"] as? [[String: Any]] ?? []
                    ]] // Only the logged-in PI
                    UserSession.shared.isLoggedIn = true
                    UserSession.shared.isPI = true // User is a PI

                    // Persist to UserDefaults
                    UserSession.shared.saveToUserDefaults()
                    completion(true, nil)
                } else {
                    completion(false, "Invalid email or password")
                }
            } else {
                completion(false, "PI Login failed with status code \(httpResponse.statusCode)")
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
    
    func fetchSpaces(for roomId: Int, completion: @escaping ([Space]) -> Void) {
        guard let url = URL(string: "\(baseURL)/rooms/\(roomId)/spaces") else {
            print("Invalid URL for fetching spaces")
            completion([])
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching spaces: \(error)")
                completion([])
                return
            }

            guard let data = data else {
                print("No data received")
                completion([])
                return
            }

            do {
                let decodedSpaces = try JSONDecoder().decode([Space].self, from: data)
                completion(decodedSpaces)
            } catch {
                print("Error decoding spaces: \(error)")
                completion([])
            }
        }
        task.resume()
    }
    
    func updateChemical(chemicalInfo: [String: Any], completion: @escaping (Bool) -> Void) {
            guard let url = URL(string: "\(baseURL)/chemicals/update") else {
                print("Invalid URL for updating chemical")
                completion(false)
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")

            do {
                let body = try JSONSerialization.data(withJSONObject: chemicalInfo, options: [])
                request.httpBody = body
            } catch {
                print("Error serializing JSON: \(error)")
                completion(false)
                return
            }
        
        print("DEBUG: Payload being sent to backend: \(chemicalInfo)")


            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error updating chemical: \(error)")
                    completion(false)
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    print("Failed to update chemical: \(response.debugDescription)")
                    completion(false)
                    return
                }

                completion(true)
            }
            task.resume()
        }


    func deleteChemical(id: Int, completion: @escaping (Bool) -> Void) {
            guard let url = URL(string: "\(baseURL)/chemicaldelete/\(id)") else {
                print("DEBUG: Invalid URL for deleting chemical")
                completion(false)
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("DEBUG: Error deleting chemical: \(error.localizedDescription)")
                    completion(false)
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    print("DEBUG: Failed to delete chemical: \(response.debugDescription)")
                    completion(false)
                    return
                }

                completion(true)
            }
            task.resume()
        }
    
    func casAPI(casNumber: String, completion: @escaping (Result<String, NetworkError>) -> Void) {
            let casBaseURL = "https://commonchemistry.cas.org/api/search"
            guard var urlComponents = URLComponents(string: casBaseURL) else {
                completion(.failure(.invalidURL))
                return
            }
            
            // Add CAS number as a query parameter
            urlComponents.queryItems = [URLQueryItem(name: "q", value: casNumber)]
            
            guard let url = urlComponents.url else {
                completion(.failure(.invalidURL))
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(.serverError(error.localizedDescription)))
                    return
                }
                
                guard let data = data, let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(.invalidResponse))
                    return
                }
                
                guard httpResponse.statusCode == 200 else {
                    completion(.failure(.unexpectedStatusCode(httpResponse.statusCode)))
                    return
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let results = json["results"] as? [[String: Any]],
                       let firstResult = results.first,
                       let rawName = firstResult["name"] as? String {
                        // Clean the CAS name by removing commas
                        let cleanedName = rawName.replacingOccurrences(of: ",", with: "")
                        completion(.success(cleanedName))
                    } else {
                        completion(.failure(.dataParsingFailed("Unexpected JSON structure")))
                    }
                } catch {
                    completion(.failure(.dataParsingFailed(error.localizedDescription)))
                }
            }
            
            task.resume()
        }


}
