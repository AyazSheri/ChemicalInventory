//
//  InventoryView.swift
//  Uscann
//
//  Created by Nabaa Naveed on 10/2/24.
//


import SwiftUI

struct InventoryView: View {
    @State private var chemicals = [
        Chemical(id: UUID(), name: "Acetonitrile", barcode: "000052461", amount: "4L", lastUpdated: Date())
    ]
    
    var body: some View {
        List(chemicals) { chemical in
            HStack {
                VStack(alignment: .leading) {
                    Text(chemical.name)
                        .font(.headline)
                    Text("Barcode: \(chemical.barcode)")
                    Text("Amount: \(chemical.amount)")
                    Text("Last Updated: \(chemical.lastUpdated, formatter: dateFormatter)")
                }
            }
        }
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    return formatter
}()
