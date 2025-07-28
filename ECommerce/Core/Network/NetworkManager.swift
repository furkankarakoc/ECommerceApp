//
//  NetworkManager.swift
//  ECommerce
//
//  Created by furkankarakoc on 27.07.2025.
//

import Foundation

// MARK: - Network Manager
protocol NetworkManagerProtocol {
    func fetchProducts(completion: @escaping (Result<[Product], NetworkError>) -> Void)
}

class NetworkManager: NetworkManagerProtocol {
    static let shared = NetworkManager()
    private let session: URLSession
    
    private init(session: URLSession = .shared) {
        self.session = session
    }
    
    func fetchProducts(completion: @escaping (Result<[Product], NetworkError>) -> Void) {
        guard let url = URL(string: APIEndpoints.products) else {
            completion(.failure(.invalidURL))
            return
        }
        
        let task = session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            do {
                let products = try JSONDecoder().decode([Product].self, from: data)
                completion(.success(products))
            } catch {
                completion(.failure(.decodingError))
            }
        }
        
        task.resume()
    }
}
