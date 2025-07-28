//
//  String+Extensions.swift
//  ECommerce
//
//  Created by furkankarakoc on 27.07.2025.
//

import Foundation



// MARK: - String Extensions
extension String {
    func contains(caseInsensitive string: String) -> Bool {
        return self.lowercased().contains(string.lowercased())
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let cartDidUpdate = Notification.Name("cartDidUpdate")
    static let favoriteDidUpdate = Notification.Name("favoriteDidUpdate")
}
