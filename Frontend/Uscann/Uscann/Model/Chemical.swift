//
//  Chemical.swift
//  Uscann
//
//  Created by Nabaa Naveed on 10/2/24.
//


import Foundation

struct Chemical: Identifiable {
    var id: UUID
    var name: String
    var barcode: String
    var amount: String
    var lastUpdated: Date
}
