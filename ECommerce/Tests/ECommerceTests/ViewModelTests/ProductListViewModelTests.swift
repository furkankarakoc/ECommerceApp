//
//  ProductListViewModelTests.swift
//  ECommerceTests
//
//  Created by furkankarakoc on 28.07.2025.
//

import XCTest
@testable import ECommerce

final class ProductListViewModelTests: XCTestCase {
    
    var viewModel: ProductListViewModel!
    var mockNetworkManager: MockNetworkManager!
    var mockDelegate: MockProductListViewModelDelegate!
    
    override func setUp() {
        super.setUp()
        mockNetworkManager = MockNetworkManager()
        viewModel = ProductListViewModel(networkManager: mockNetworkManager)
        mockDelegate = MockProductListViewModelDelegate()
        viewModel.delegate = mockDelegate
    }
    
    override func tearDown() {
        viewModel = nil
        mockNetworkManager = nil
        mockDelegate = nil
        super.tearDown()
    }
    
    // MARK: - Fetch Products Tests
    
    func testFetchProductsSuccess() {
        // Given
        let testProducts = TestDataFactory.createMockProducts()
        mockNetworkManager.mockProducts = testProducts
        
        // When
        viewModel.fetchProducts()
        
        // Then
        XCTAssertEqual(mockNetworkManager.fetchProductsCallCount, 1, "Network manager should be called once")
        XCTAssertEqual(mockDelegate.didStartLoadingCallCount, 1, "Should call didStartLoading")
        XCTAssertEqual(mockDelegate.didFinishLoadingCallCount, 1, "Should call didFinishLoading")
        XCTAssertEqual(mockDelegate.didUpdateProductsCallCount, 1, "Should call didUpdateProducts")
        XCTAssertEqual(viewModel.numberOfProducts(), 3, "Should have 3 products")
        XCTAssertFalse(viewModel.isEmpty, "ViewModel should not be empty")
    }
    
    func testFetchProductsFailure() {
        // Given
        mockNetworkManager.shouldReturnError = true
        
        // When
        viewModel.fetchProducts()
        
        // Then
        XCTAssertEqual(mockDelegate.didStartLoadingCallCount, 1, "Should call didStartLoading")
        XCTAssertEqual(mockDelegate.didFinishLoadingCallCount, 1, "Should call didFinishLoading")
        XCTAssertEqual(mockDelegate.didFailWithErrorCallCount, 1, "Should call didFailWithError")
        XCTAssertNotNil(mockDelegate.lastErrorMessage, "Should have error message")
        XCTAssertEqual(viewModel.numberOfProducts(), 0, "Should have no products on error")
    }
    
    // MARK: - Search Tests
    
    func testSearchProducts() {
        // Given
        let testProducts = TestDataFactory.createMockProducts()
        mockNetworkManager.mockProducts = testProducts
        viewModel.fetchProducts()
        
        // When
        viewModel.searchProducts(with: "iPhone")
        
        // Then
        XCTAssertEqual(viewModel.numberOfProducts(), 1, "Should find 1 iPhone product")
        XCTAssertEqual(viewModel.product(at: 0)?.name, "iPhone 13 Pro Max 256Gb", "Should find the iPhone product")
    }
    
    func testSearchProductsEmpty() {
        // Given
        let testProducts = TestDataFactory.createMockProducts()
        mockNetworkManager.mockProducts = testProducts
        viewModel.fetchProducts()
        
        // When
        viewModel.searchProducts(with: "NonExistentProduct")
        
        // Then
        XCTAssertEqual(viewModel.numberOfProducts(), 0, "Should find no products")
        XCTAssertTrue(viewModel.isEmpty, "Should be empty")
    }
    
    func testSearchProductsCaseInsensitive() {
        // Given
        let testProducts = TestDataFactory.createMockProducts()
        mockNetworkManager.mockProducts = testProducts
        viewModel.fetchProducts()
        
        // When
        viewModel.searchProducts(with: "iphone") // lowercase
        
        // Then
        XCTAssertEqual(viewModel.numberOfProducts(), 1, "Should find iPhone with case insensitive search")
    }
    
    // MARK: - Filter Tests
    
    func testApplyBrandFilter() {
        // Given
        let testProducts = TestDataFactory.createMockProducts()
        mockNetworkManager.mockProducts = testProducts
        viewModel.fetchProducts()
        
        var filterOptions = FilterOptions()
        filterOptions.selectedBrands = ["Apple"]
        
        // When
        viewModel.applyFilter(filterOptions)
        
        // Then
        XCTAssertEqual(viewModel.numberOfProducts(), 2, "Should find 2 Apple products")
        XCTAssertEqual(viewModel.product(at: 0)?.brand, "Apple", "First product should be Apple")
        XCTAssertEqual(viewModel.product(at: 1)?.brand, "Apple", "Second product should be Apple")
    }
    
    func testApplyModelFilter() {
        // Given
        let testProducts = TestDataFactory.createMockProducts()
        mockNetworkManager.mockProducts = testProducts
        viewModel.fetchProducts()
        
        var filterOptions = FilterOptions()
        filterOptions.selectedModels = ["13 Pro Max"]
        
        // When
        viewModel.applyFilter(filterOptions)
        
        // Then
        XCTAssertEqual(viewModel.numberOfProducts(), 1, "Should find 1 product with model 13 Pro Max")
        XCTAssertEqual(viewModel.product(at: 0)?.model, "13 Pro Max", "Should find the iPhone 13 Pro Max")
    }
    
    func testApplySortFilter() {
        // Given
        let testProducts = TestDataFactory.createMockProducts()
        mockNetworkManager.mockProducts = testProducts
        viewModel.fetchProducts()
        
        var filterOptions = FilterOptions()
        filterOptions.sortType = .priceHighToLow
        
        // When
        viewModel.applyFilter(filterOptions)
        
        // Then
        XCTAssertEqual(viewModel.numberOfProducts(), 3, "Should have all products")
        // MacBook Pro (25000) should be first, iPhone (15000) second, Samsung (12000) third
        XCTAssertEqual(viewModel.product(at: 0)?.name, "MacBook Pro M2", "Highest price should be first")
        XCTAssertEqual(viewModel.product(at: 2)?.name, "Samsung Galaxy S22 Ultra", "Lowest price should be last")
    }
    
    // MARK: - Pagination Tests
    
    func testLoadMoreProducts() {
        // Given
        let manyProducts = Array(repeating: TestDataFactory.createMockProduct(), count: 10)
        let uniqueProducts = manyProducts.enumerated().map { index, product in
            Product(
                id: "\(index)",
                name: "\(product.name) \(index)",
                image: product.image,
                price: product.price,
                description: product.description,
                model: product.model,
                brand: product.brand,
                createdAt: product.createdAt
            )
        }
        
        mockNetworkManager.mockProducts = uniqueProducts
        viewModel.fetchProducts()
        
        // Should initially show 4 products (first page)
        XCTAssertEqual(viewModel.numberOfProducts(), 4, "Should initially show 4 products")
        
        // When - trigger load more
        viewModel.loadMoreProductsIfNeeded(for: 2) // Near the end
        
        // Wait a bit for async operation
        let expectation = XCTestExpectation(description: "Load more products")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        // Then
        XCTAssertGreaterThan(viewModel.numberOfProducts(), 4, "Should load more products")
        XCTAssertTrue(viewModel.hasMoreProducts, "Should have more products available")
    }
    
    // MARK: - Utility Tests
    
    func testGetAllBrands() {
        // Given
        let testProducts = TestDataFactory.createMockProducts()
        mockNetworkManager.mockProducts = testProducts
        viewModel.fetchProducts()
        
        // When
        let brands = viewModel.getAllBrands()
        
        // Then
        XCTAssertEqual(brands.count, 2, "Should have 2 unique brands")
        XCTAssertTrue(brands.contains("Apple"), "Should contain Apple")
        XCTAssertTrue(brands.contains("Samsung"), "Should contain Samsung")
    }
    
    func testGetAllModels() {
        // Given
        let testProducts = TestDataFactory.createMockProducts()
        mockNetworkManager.mockProducts = testProducts
        viewModel.fetchProducts()
        
        // When
        let models = viewModel.getAllModels()
        
        // Then
        XCTAssertEqual(models.count, 3, "Should have 3 unique models")
        XCTAssertTrue(models.contains("13 Pro Max"), "Should contain 13 Pro Max")
        XCTAssertTrue(models.contains("S22 Ultra"), "Should contain S22 Ultra")
        XCTAssertTrue(models.contains("MacBook Pro"), "Should contain MacBook Pro")
    }
}
