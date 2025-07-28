//
//  CoreDataManagerTests.swift
//  ECommerceTests
//
//  Created by furkankarakoc on 28.07.2025.
//

import XCTest
import CoreData
@testable import ECommerce

final class CoreDataManagerTests: XCTestCase {
    
    var coreDataManager: CoreDataManager!
    var testProduct: Product!
    
    override func setUp() {
        super.setUp()
        coreDataManager = CoreDataManager.shared
        testProduct = TestDataFactory.createMockProduct()
        
        // Clean up any existing test data
        cleanupTestData()
    }
    
    override func tearDown() {
        cleanupTestData()
        coreDataManager = nil
        testProduct = nil
        super.tearDown()
    }
    
    private func cleanupTestData() {
        // Remove all cart items
        let cartItems = coreDataManager.fetchCartItems()
        cartItems.forEach { coreDataManager.removeFromCart(productId: $0.productId!) }
        
        // Remove all favorite items
        let favoriteItems = coreDataManager.fetchFavoriteItems()
        favoriteItems.forEach { coreDataManager.removeFromFavorites(productId: $0.productId!) }
    }
    
    // MARK: - Cart Tests
    
    func testAddToCart() {
        // Given
        let initialCount = coreDataManager.getCartItemCount()
        
        // When
        coreDataManager.addToCart(product: testProduct)
        
        // Then
        let newCount = coreDataManager.getCartItemCount()
        XCTAssertEqual(newCount, initialCount + 1, "Cart count should increase by 1")
        
        let cartItems = coreDataManager.fetchCartItems()
        let addedItem = cartItems.first { $0.productId == testProduct.id }
        
        XCTAssertNotNil(addedItem, "Product should be added to cart")
        XCTAssertEqual(addedItem?.productId, testProduct.id, "Product ID should match")
        XCTAssertEqual(addedItem?.productName, testProduct.name, "Product name should match")
        XCTAssertEqual(addedItem?.productPrice, testProduct.price, "Product price should match")
        XCTAssertEqual(addedItem?.productBrand, testProduct.brand, "Product brand should match")
        XCTAssertEqual(addedItem?.productModel, testProduct.model, "Product model should match")
        XCTAssertEqual(addedItem?.quantity, 1, "Initial quantity should be 1")
    }
    
    func testAddToCartMultipleTimes() {
        // Given
        coreDataManager.addToCart(product: testProduct)
        let initialQuantity = coreDataManager.fetchCartItems().first?.quantity ?? 0
        
        // When
        coreDataManager.addToCart(product: testProduct, quantity: 2)
        
        // Then
        let cartItems = coreDataManager.fetchCartItems()
        let updatedItem = cartItems.first { $0.productId == testProduct.id }
        
        XCTAssertEqual(updatedItem?.quantity, initialQuantity + 2, "Quantity should increase by 2")
        XCTAssertEqual(cartItems.count, 1, "Should still have only one cart item for this product")
    }
    
    func testRemoveFromCart() {
        // Given
        coreDataManager.addToCart(product: testProduct)
        XCTAssertEqual(coreDataManager.fetchCartItems().count, 1, "Should have 1 item initially")
        
        // When
        coreDataManager.removeFromCart(productId: testProduct.id)
        
        // Then
        let cartItems = coreDataManager.fetchCartItems()
        XCTAssertEqual(cartItems.count, 0, "Cart should be empty")
        XCTAssertEqual(coreDataManager.getCartItemCount(), 0, "Cart count should be 0")
    }
    
    func testUpdateCartItemQuantity() {
        // Given
        coreDataManager.addToCart(product: testProduct)
        
        // When
        coreDataManager.updateCartItemQuantity(productId: testProduct.id, quantity: 5)
        
        // Then
        let cartItems = coreDataManager.fetchCartItems()
        let updatedItem = cartItems.first { $0.productId == testProduct.id }
        
        XCTAssertEqual(updatedItem?.quantity, 5, "Quantity should be updated to 5")
        XCTAssertEqual(coreDataManager.getCartItemCount(), 5, "Total count should be 5")
    }
    
    func testUpdateCartItemQuantityToZero() {
        // Given
        coreDataManager.addToCart(product: testProduct)
        XCTAssertEqual(coreDataManager.fetchCartItems().count, 1, "Should have 1 item initially")
        
        // When
        coreDataManager.updateCartItemQuantity(productId: testProduct.id, quantity: 0)
        
        // Then
        let cartItems = coreDataManager.fetchCartItems()
        XCTAssertEqual(cartItems.count, 0, "Item should be removed when quantity is 0")
        XCTAssertEqual(coreDataManager.getCartItemCount(), 0, "Cart count should be 0")
    }
    
    func testGetCartItemCount() {
        // Given
        let products = TestDataFactory.createMockProducts()
        
        // When
        coreDataManager.addToCart(product: products[0], quantity: 3)
        coreDataManager.addToCart(product: products[1], quantity: 2)
        
        // Then
        XCTAssertEqual(coreDataManager.getCartItemCount(), 5, "Total cart count should be 5")
    }
    
    // MARK: - Favorites Tests
    
    func testAddToFavorites() {
        // Given
        XCTAssertFalse(coreDataManager.isFavorite(productId: testProduct.id), "Should not be favorite initially")
        
        // When
        coreDataManager.addToFavorites(product: testProduct)
        
        // Then
        XCTAssertTrue(coreDataManager.isFavorite(productId: testProduct.id), "Should be favorite after adding")
        
        let favoriteItems = coreDataManager.fetchFavoriteItems()
        let addedItem = favoriteItems.first { $0.productId == testProduct.id }
        
        XCTAssertNotNil(addedItem, "Product should be in favorites")
        XCTAssertEqual(addedItem?.productId, testProduct.id, "Product ID should match")
        XCTAssertEqual(addedItem?.productName, testProduct.name, "Product name should match")
        XCTAssertEqual(addedItem?.productPrice, testProduct.price, "Product price should match")
        XCTAssertEqual(addedItem?.productBrand, testProduct.brand, "Product brand should match")
        XCTAssertEqual(addedItem?.productModel, testProduct.model, "Product model should match")
    }
    
    func testAddToFavoritesTwice() {
        // Given
        coreDataManager.addToFavorites(product: testProduct)
        XCTAssertEqual(coreDataManager.fetchFavoriteItems().count, 1, "Should have 1 favorite")
        
        // When - Try to add again
        coreDataManager.addToFavorites(product: testProduct)
        
        // Then - Should not create duplicate
        let favoriteItems = coreDataManager.fetchFavoriteItems()
        let matchingItems = favoriteItems.filter { $0.productId == testProduct.id }
        XCTAssertEqual(matchingItems.count, 1, "Should still have only 1 favorite item")
    }
    
    func testRemoveFromFavorites() {
        // Given
        coreDataManager.addToFavorites(product: testProduct)
        XCTAssertTrue(coreDataManager.isFavorite(productId: testProduct.id), "Should be favorite initially")
        
        // When
        coreDataManager.removeFromFavorites(productId: testProduct.id)
        
        // Then
        XCTAssertFalse(coreDataManager.isFavorite(productId: testProduct.id), "Should not be favorite after removal")
        
        let favoriteItems = coreDataManager.fetchFavoriteItems()
        let removedItem = favoriteItems.first { $0.productId == testProduct.id }
        XCTAssertNil(removedItem, "Product should not be in favorites")
    }
    
    func testIsFavorite() {
        // Given
        XCTAssertFalse(coreDataManager.isFavorite(productId: testProduct.id), "Should not be favorite initially")
        
        // When
        coreDataManager.addToFavorites(product: testProduct)
        
        // Then
        XCTAssertTrue(coreDataManager.isFavorite(productId: testProduct.id), "Should be favorite after adding")
    }
    
    func testFetchFavoriteItems() {
        // Given
        let products = TestDataFactory.createMockProducts()
        
        // When
        products.forEach { coreDataManager.addToFavorites(product: $0) }
        
        // Then
        let favoriteItems = coreDataManager.fetchFavoriteItems()
        XCTAssertEqual(favoriteItems.count, 3, "Should have 3 favorite items")
        
        let favoriteIds = favoriteItems.compactMap { $0.productId }
        products.forEach { product in
            XCTAssertTrue(favoriteIds.contains(product.id), "Should contain product \(product.id)")
        }
    }
    
    // MARK: - Data Persistence Tests
    
    func testDataPersistenceAfterSave() {
        // Given
        coreDataManager.addToCart(product: testProduct, quantity: 3)
        coreDataManager.addToFavorites(product: testProduct)
        
        // When - Save context
        coreDataManager.saveContext()
        
        // Then - Data should still be there
        XCTAssertEqual(coreDataManager.getCartItemCount(), 3, "Cart data should persist")
        XCTAssertTrue(coreDataManager.isFavorite(productId: testProduct.id), "Favorite data should persist")
    }
    
    func testConcurrentAccess() {
        // Given
        let expectation = XCTestExpectation(description: "Concurrent access")
        expectation.expectedFulfillmentCount = 3
        
        let products = TestDataFactory.createMockProducts()
        
        // When - Add products concurrently
        DispatchQueue.global().async {
            self.coreDataManager.addToCart(product: products[0])
            expectation.fulfill()
        }
        
        DispatchQueue.global().async {
            self.coreDataManager.addToFavorites(product: products[1])
            expectation.fulfill()
        }
        
        DispatchQueue.global().async {
            self.coreDataManager.addToCart(product: products[2], quantity: 2)
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 5.0)
        
        XCTAssertEqual(coreDataManager.getCartItemCount(), 3, "Should handle concurrent cart operations")
        XCTAssertEqual(coreDataManager.fetchFavoriteItems().count, 1, "Should handle concurrent favorite operations")
    }
    
    // MARK: - Edge Cases
    
    func testRemoveNonExistentCartItem() {
        // Given
        let nonExistentId = "non-existent-id"
        
        // When - Should not crash
        coreDataManager.removeFromCart(productId: nonExistentId)
        
        // Then
        XCTAssertEqual(coreDataManager.fetchCartItems().count, 0, "Cart should remain empty")
    }
    
    func testRemoveNonExistentFavoriteItem() {
        // Given
        let nonExistentId = "non-existent-id"
        
        // When - Should not crash
        coreDataManager.removeFromFavorites(productId: nonExistentId)
        
        // Then
        XCTAssertEqual(coreDataManager.fetchFavoriteItems().count, 0, "Favorites should remain empty")
    }
    
    func testUpdateNonExistentCartItem() {
        // Given
        let nonExistentId = "non-existent-id"
        
        // When - Should not crash
        coreDataManager.updateCartItemQuantity(productId: nonExistentId, quantity: 5)
        
        // Then
        XCTAssertEqual(coreDataManager.fetchCartItems().count, 0, "Cart should remain empty")
    }
    
    func testIsFavoriteNonExistentProduct() {
        // Given
        let nonExistentId = "non-existent-id"
        
        // When & Then - Should not crash and return false
        XCTAssertFalse(coreDataManager.isFavorite(productId: nonExistentId), "Non-existent product should not be favorite")
    }
}
