//
//  ProductDetailViewModelTests.swift
//  ECommerceTests
//
//  Created by furkankarakoc on 28.07.2025.
//

import XCTest
@testable import ECommerce

final class ProductDetailViewModelTests: XCTestCase {
    
    var viewModel: ProductDetailViewModel!
    var mockDelegate: MockProductDetailViewModelDelegate!
    var testProduct: Product!
    
    override func setUp() {
        super.setUp()
        testProduct = TestDataFactory.createMockProduct()
        viewModel = ProductDetailViewModel(product: testProduct)
        mockDelegate = MockProductDetailViewModelDelegate()
        viewModel.delegate = mockDelegate
        
        // Clean up any existing data
        cleanupCoreData()
    }
    
    override func tearDown() {
        cleanupCoreData()
        viewModel = nil
        mockDelegate = nil
        testProduct = nil
        super.tearDown()
    }
    
    private func cleanupCoreData() {
        // Remove test product from favorites and cart
        CoreDataManager.shared.removeFromFavorites(productId: testProduct?.id ?? "")
        CoreDataManager.shared.removeFromCart(productId: testProduct?.id ?? "")
    }
    
    // MARK: - Product Property Tests
    
    func testProductProperty() {
        // Then
        XCTAssertEqual(viewModel.product.id, testProduct.id, "Product ID should match")
        XCTAssertEqual(viewModel.product.name, testProduct.name, "Product name should match")
        XCTAssertEqual(viewModel.product.price, testProduct.price, "Product price should match")
        XCTAssertEqual(viewModel.product.brand, testProduct.brand, "Product brand should match")
    }
    
    // MARK: - Add to Cart Tests
    
    func testAddToCart() {
        // Given
        let initialCartCount = CoreDataManager.shared.getCartItemCount()
        
        // When
        viewModel.addToCart()
        
        // Then
        XCTAssertEqual(mockDelegate.didAddToCartCallCount, 1, "Should call didAddToCart delegate method")
        
        let newCartCount = CoreDataManager.shared.getCartItemCount()
        XCTAssertEqual(newCartCount, initialCartCount + 1, "Cart count should increase by 1")
        
        // Verify the product is in cart
        let cartItems = CoreDataManager.shared.fetchCartItems()
        let addedItem = cartItems.first { $0.productId == testProduct.id }
        XCTAssertNotNil(addedItem, "Product should be added to cart")
        XCTAssertEqual(addedItem?.productName, testProduct.name, "Cart item name should match")
    }
    
    func testAddToCartMultipleTimes() {
        // Given
        let initialCartCount = CoreDataManager.shared.getCartItemCount()
        
        // When
        viewModel.addToCart()
        viewModel.addToCart()
        
        // Then
        XCTAssertEqual(mockDelegate.didAddToCartCallCount, 2, "Should call didAddToCart twice")
        
        // Should increase quantity, not add new item
        let cartItems = CoreDataManager.shared.fetchCartItems()
        let addedItem = cartItems.first { $0.productId == testProduct.id }
        XCTAssertNotNil(addedItem, "Product should be in cart")
        XCTAssertEqual(addedItem?.quantity, 2, "Quantity should be 2")
        
        let newCartCount = CoreDataManager.shared.getCartItemCount()
        XCTAssertEqual(newCartCount, initialCartCount + 2, "Total cart count should increase by 2")
    }
    
    // MARK: - Favorite Tests
    
    func testToggleFavoriteFromNotFavorite() {
        // Given
        XCTAssertFalse(viewModel.isFavorite(), "Initially should not be favorite")
        
        // When
        viewModel.toggleFavorite()
        
        // Then
        XCTAssertTrue(viewModel.isFavorite(), "Should be favorite after toggle")
        XCTAssertEqual(mockDelegate.didUpdateFavoriteStatusCallCount, 1, "Should call delegate method")
        
        // Verify in CoreData
        let favoriteItems = CoreDataManager.shared.fetchFavoriteItems()
        let favoriteItem = favoriteItems.first { $0.productId == testProduct.id }
        XCTAssertNotNil(favoriteItem, "Product should be in favorites")
        XCTAssertEqual(favoriteItem?.productName, testProduct.name, "Favorite item name should match")
    }
    
    func testToggleFavoriteFromFavorite() {
        // Given - Add to favorites first
        CoreDataManager.shared.addToFavorites(product: testProduct)
        XCTAssertTrue(viewModel.isFavorite(), "Should be favorite initially")
        
        // When
        viewModel.toggleFavorite()
        
        // Then
        XCTAssertFalse(viewModel.isFavorite(), "Should not be favorite after toggle")
        XCTAssertEqual(mockDelegate.didUpdateFavoriteStatusCallCount, 1, "Should call delegate method")
        
        // Verify removed from CoreData
        let favoriteItems = CoreDataManager.shared.fetchFavoriteItems()
        let favoriteItem = favoriteItems.first { $0.productId == testProduct.id }
        XCTAssertNil(favoriteItem, "Product should be removed from favorites")
    }
    
    func testIsFavoritePersistence() {
        // Given
        XCTAssertFalse(viewModel.isFavorite(), "Initially should not be favorite")
        
        // When - Add to favorites
        CoreDataManager.shared.addToFavorites(product: testProduct)
        
        // Then - Create new ViewModel instance and check
        let newViewModel = ProductDetailViewModel(product: testProduct)
        XCTAssertTrue(newViewModel.isFavorite(), "Should persist favorite status")
    }
    
    // MARK: - Edge Cases
    
    func testMultipleToggleFavorite() {
        // Given
        let initialFavoriteStatus = viewModel.isFavorite()
        
        // When - Toggle multiple times
        viewModel.toggleFavorite() // Should be opposite of initial
        viewModel.toggleFavorite() // Should be back to initial
        viewModel.toggleFavorite() // Should be opposite again
        
        // Then
        XCTAssertNotEqual(viewModel.isFavorite(), initialFavoriteStatus, "Should be opposite of initial status")
        XCTAssertEqual(mockDelegate.didUpdateFavoriteStatusCallCount, 3, "Should call delegate 3 times")
    }
    
    func testDelegateNotSet() {
        // Given
        viewModel.delegate = nil
        
        // When - Should not crash
        viewModel.addToCart()
        viewModel.toggleFavorite()
        
        // Then - Should complete without crashing
        XCTAssertTrue(true, "Should not crash when delegate is nil")
    }
}
