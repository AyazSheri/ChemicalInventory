//
//  APIManager.swift
//  Uscann
//
//  Created by Nabaa Naveed on 10/2/24.
//


import Foundation

class APIManager {
    static let shared = APIManager()
    
    func login(id: String, password: String, completion: @escaping (Bool) -> Void) {
        // API call logic
        completion(true)
    }
}
