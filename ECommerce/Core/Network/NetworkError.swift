//
//  NetworkError.swift
//  ECommerce
//
//  Created by furkankarakoc on 27.07.2025.
//

import Foundation



// MARK: - Network Error
enum NetworkError: Error, Equatable {
    case invalidURL
    case noData
    case decodingError
    case networkError(Error)
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError:
            return "Failed to decode data"
        case .networkError(let error):
            return error.localizedDescription
        }
    }
    
    // MARK: - Equatable Implementation
    static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
            (.noData, .noData),
            (.decodingError, .decodingError):
            return true
        case (.networkError(let lhsError), .networkError(let rhsError)):
            return (lhsError as NSError).code == (rhsError as NSError).code &&
            (lhsError as NSError).domain == (rhsError as NSError).domain
        default:
            return false
        }
    }
}
