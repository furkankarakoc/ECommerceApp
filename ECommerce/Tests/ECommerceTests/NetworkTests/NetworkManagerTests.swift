//
//  NetworkManagerTests.swift
//  ECommerceTests
//
//  Created by furkankarakoc on 28.07.2025.
//

import XCTest
@testable import ECommerce

final class NetworkManagerTests: XCTestCase {
    
    var networkManager: NetworkManager!
    
    override func setUp() {
        super.setUp()
        networkManager = NetworkManager.shared
    }
    
    override func tearDown() {
        networkManager = nil
        super.tearDown()
    }
    
    // MARK: - Real API Tests (Integration Tests)
    
    func testFetchProductsRealAPI() {
        // Given
        let expectation = XCTestExpectation(description: "Fetch products from real API")
        var fetchedProducts: [Product]?
        var fetchError: NetworkError?
        
        // When
        networkManager.fetchProducts { result in
            switch result {
            case .success(let products):
                fetchedProducts = products
            case .failure(let error):
                fetchError = error
            }
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 10.0)
        
        XCTAssertNil(fetchError, "Should not have error: \(fetchError?.localizedDescription ?? "")")
        XCTAssertNotNil(fetchedProducts, "Should have products")
        XCTAssertFalse(fetchedProducts?.isEmpty ?? true, "Products array should not be empty")
        
        // Verify product structure
        if let firstProduct = fetchedProducts?.first {
            XCTAssertFalse(firstProduct.id.isEmpty, "Product should have ID")
            XCTAssertFalse(firstProduct.name.isEmpty, "Product should have name")
            XCTAssertFalse(firstProduct.price.isEmpty, "Product should have price")
            XCTAssertFalse(firstProduct.brand.isEmpty, "Product should have brand")
            XCTAssertFalse(firstProduct.model.isEmpty, "Product should have model")
        }
    }
    
    func testFetchProductsNetworkTimeout() {
        // Given
        let expectation = XCTestExpectation(description: "Network timeout test")
        expectation.isInverted = true
        
        // When
        networkManager.fetchProducts { result in
            expectation.fulfill()
        }
        
        // Then - Should not complete within 1 second (testing timeout behavior)
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Mock Network Tests
    
    func testNetworkManagerWithMockSuccess() {
        // Given
        let mockSession = MockURLSession()
        let testProducts = TestDataFactory.createMockProducts()
        let jsonData = try! JSONEncoder().encode(testProducts)
        
        mockSession.mockData = jsonData
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: APIEndpoints.products)!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        let networkManager = NetworkManagerWithSession(session: mockSession)
        let expectation = XCTestExpectation(description: "Mock network success")
        
        var result: Result<[Product], NetworkError>?
        
        // When
        networkManager.fetchProducts { networkResult in
            result = networkResult
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        
        switch result {
        case .success(let products):
            XCTAssertEqual(products.count, 3, "Should return 3 products")
            XCTAssertEqual(products.first?.name, testProducts.first?.name, "Product names should match")
        case .failure(let error):
            XCTFail("Should not fail: \(error)")
        case .none:
            XCTFail("Result should not be nil")
        }
    }
    
    func testNetworkManagerWithMockError() {
        // Given
        let mockSession = MockURLSession()
        mockSession.mockError = NSError(domain: "TestError", code: 500, userInfo: nil)
        
        let networkManager = NetworkManagerWithSession(session: mockSession)
        let expectation = XCTestExpectation(description: "Mock network error")
        
        var result: Result<[Product], NetworkError>?
        
        // When
        networkManager.fetchProducts { networkResult in
            result = networkResult
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        
        switch result {
        case .success:
            XCTFail("Should not succeed")
        case .failure(let error):
            switch error {
            case .networkError(let underlyingError):
                XCTAssertEqual((underlyingError as NSError).code, 500, "Should return the mock error")
            default:
                XCTFail("Should be network error")
            }
        case .none:
            XCTFail("Result should not be nil")
        }
    }
    
    func testNetworkManagerWithInvalidData() {
        // Given
        let mockSession = MockURLSession()
        mockSession.mockData = "Invalid JSON".data(using: .utf8)
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: APIEndpoints.products)!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        let networkManager = NetworkManagerWithSession(session: mockSession)
        let expectation = XCTestExpectation(description: "Invalid data test")
        
        var result: Result<[Product], NetworkError>?
        
        // When
        networkManager.fetchProducts { networkResult in
            result = networkResult
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        
        switch result {
        case .success:
            XCTFail("Should not succeed with invalid JSON")
        case .failure(let error):
            XCTAssertEqual(error, .decodingError, "Should be decoding error")
        case .none:
            XCTFail("Result should not be nil")
        }
    }
}

// MARK: - Mock URL Session for Testing

class MockURLSession: URLSession {
    var mockData: Data?
    var mockResponse: URLResponse?
    var mockError: Error?
    
    override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return MockURLSessionDataTask {
            completionHandler(self.mockData, self.mockResponse, self.mockError)
        }
    }
}

class MockURLSessionDataTask: URLSessionDataTask {
    private let closure: () -> Void
    
    init(closure: @escaping () -> Void) {
        self.closure = closure
    }
    
    override func resume() {
        closure()
    }
}

// MARK: - NetworkManager with Injectable Session

class NetworkManagerWithSession: NetworkManagerProtocol {
    private let session: URLSession
    
    init(session: URLSession) {
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
