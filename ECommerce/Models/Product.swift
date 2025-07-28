//
//  Product.swift
//  ECommerce
//
//  Created by furkankarakoc on 27.07.2025.
//

import Foundation

// MARK: - Product Model
struct Product: Codable, Equatable {
    let id: String
    let name: String
    let image: String
    let price: String
    let description: String
    let model: String
    let brand: String
    let createdAt: String
    
    var priceValue: Double {
        return Double(price) ?? 0.0
    }
    
    var formattedPrice: String {
        return "\(price) ₺"
    }
    
    static func == (lhs: Product, rhs: Product) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Filter Types
enum SortType: String, CaseIterable {
    case oldToNew = "Old to new"
    case newToOld = "New to old"
    case priceHighToLow = "Price hight to low"
    case priceLowToHigh = "Price low to High"
    
    var displayName: String {
        return self.rawValue
    }
}

struct FilterOptions {
    var sortType: SortType = .oldToNew
    var selectedBrands: Set<String> = []
    var selectedModels: Set<String> = []
    var searchText: String = ""
}
