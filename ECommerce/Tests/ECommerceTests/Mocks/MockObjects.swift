//
//  MockObjects.swift
//  ECommerceTests
//
//  Created by furkankarakoc on 28.07.2025.
//

import XCTest
@testable import ECommerce

// MARK: - Mock Network Manager
class MockNetworkManager: NetworkManagerProtocol {
    var shouldReturnError = false
    var mockProducts: [Product] = []
    var fetchProductsCallCount = 0
    
    func fetchProducts(completion: @escaping (Result<[Product], NetworkError>) -> Void) {
        fetchProductsCallCount += 1
        
        if shouldReturnError {
            completion(.failure(.networkError(NSError(domain: "TestError", code: 404, userInfo: nil))))
        } else {
            completion(.success(mockProducts))
        }
    }
}

// MARK: - Mock Product List Delegate
class MockProductListViewModelDelegate: ProductListViewModelDelegate {
    var didUpdateProductsCallCount = 0
    var didFailWithErrorCallCount = 0
    var didStartLoadingCallCount = 0
    var didFinishLoadingCallCount = 0
    var lastErrorMessage: String?
    
    func didUpdateProducts() {
        didUpdateProductsCallCount += 1
    }
    
    func didFailWithError(_ error: String) {
        didFailWithErrorCallCount += 1
        lastErrorMessage = error
    }
    
    func didStartLoading() {
        didStartLoadingCallCount += 1
    }
    
    func didFinishLoading() {
        didFinishLoadingCallCount += 1
    }
}

// MARK: - Mock Product Detail Delegate
class MockProductDetailViewModelDelegate: ProductDetailViewModelDelegate {
    var didUpdateFavoriteStatusCallCount = 0
    var didAddToCartCallCount = 0
    
    func didUpdateFavoriteStatus() {
        didUpdateFavoriteStatusCallCount += 1
    }
    
    func didAddToCart() {
        didAddToCartCallCount += 1
    }
}

// MARK: - Mock Cart Delegate
class MockCartViewModelDelegate: CartViewModelDelegate {
    var didUpdateCartCallCount = 0
    var didFailWithErrorCallCount = 0
    var lastErrorMessage: String?
    
    func didUpdateCart() {
        didUpdateCartCallCount += 1
    }
    
    func didFailWithError(_ error: String) {
        didFailWithErrorCallCount += 1
        lastErrorMessage = error
    }
}

// MARK: - Test Data Factory
class TestDataFactory {
    static func createMockProducts() -> [Product] {
        return [
            Product(
                id: "1",
                name: "iPhone 13 Pro Max 256Gb",
                image: "https://loremflickr.com/640/480/technics",
                price: "15000",
                description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
                model: "13 Pro Max",
                brand: "Apple",
                createdAt: "2023-07-16T08:39:41.686Z"
            ),
            Product(
                id: "2",
                name: "Samsung Galaxy S22 Ultra",
                image: "https://loremflickr.com/640/480/technics",
                price: "12000",
                description: "Samsung's flagship phone with S Pen.",
                model: "S22 Ultra",
                brand: "Samsung",
                createdAt: "2023-07-17T08:39:41.686Z"
            ),
            Product(
                id: "3",
                name: "MacBook Pro M2",
                image: "https://loremflickr.com/640/480/computer",
                price: "25000",
                description: "Apple's latest MacBook Pro with M2 chip.",
                model: "MacBook Pro",
                brand: "Apple",
                createdAt: "2023-07-18T08:39:41.686Z"
            )
        ]
    }
    
    static func createMockProduct() -> Product {
        return createMockProducts().first!
    }
}
