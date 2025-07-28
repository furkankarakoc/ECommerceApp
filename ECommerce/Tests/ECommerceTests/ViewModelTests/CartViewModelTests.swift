//
//  CartViewModelTests.swift
//  ECommerceTests
//
//  Created by furkankarakoc on 28.07.2025.
//

import XCTest
@testable import ECommerce

final class CartViewModelTests: XCTestCase {
    
    var viewModel: CartViewModel!
    var mockDelegate: MockCartViewModelDelegate!
    var testProducts: [Product]!
    
    override func setUp() {
        super.setUp()
        testProducts = TestDataFactory.createMockProducts()
        mockDelegate = MockCartViewModelDelegate()
        
        // Clean up any existing cart data
        cleanupCartData()
        
        viewModel = CartViewModel()
        viewModel.delegate = mockDelegate
    }
    
    override func tearDown() {
        cleanupCartData()
        viewModel = nil
        mockDelegate = nil
        testProducts = nil
        super.tearDown()
    }
    
    private func cleanupCartData() {
        let cartItems = CoreDataManager.shared.fetchCartItems()
        cartItems.forEach { CoreDataManager.shared.removeFromCart(productId: $0.productId!) }
    }
    
    // MARK: - Initial State Tests
    
    func testInitialEmptyState() {
        // Then
        XCTAssertTrue(viewModel.isEmpty, "Cart should be empty initially")
        XCTAssertEqual(viewModel.numberOfItems(), 0, "Should have 0 items")
        XCTAssertEqual(viewModel.getTotalItemCount(), 0, "Total count should be 0")
        XCTAssertEqual(viewModel.getTotalPrice(), "0 ₺", "Total price should be 0")
    }
    
    // MARK: - Add Items Tests
    
    func testAddItemToCart() {
        // Given
        let product = testProducts[0]
        
        // When
        CoreDataManager.shared.addToCart(product: product, quantity: 2)
        
        // Then - ViewModel should update automatically via NotificationCenter
        let expectation = XCTestExpectation(description: "Cart update notification")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertFalse(viewModel.isEmpty, "Cart should not be empty")
        XCTAssertEqual(viewModel.numberOfItems(), 1, "Should have 1 unique item")
        XCTAssertEqual(viewModel.getTotalItemCount(), 2, "Total count should be 2")
        XCTAssertGreaterThan(mockDelegate.didUpdateCartCallCount, 0, "Delegate should be called")
    }
    
    func testAddMultipleItemsToCart() {
        // Given
        let products = Array(testProducts.prefix(2))
        
        // When
        CoreDataManager.shared.addToCart(product: products[0], quantity: 1)
        CoreDataManager.shared.addToCart(product: products[1], quantity: 3)
        
        // Then
        let expectation = XCTestExpectation(description: "Multiple cart updates")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertEqual(viewModel.numberOfItems(), 2, "Should have 2 unique items")
        XCTAssertEqual(viewModel.getTotalItemCount(), 4, "Total count should be 4")
    }
    
    // MARK: - Update Quantity Tests
    
    func testUpdateItemQuantity() {
        // Given
        let product = testProducts[0]
        CoreDataManager.shared.addToCart(product: product, quantity: 1)
        
        // Wait for initial update
        let setupExpectation = XCTestExpectation(description: "Setup cart")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            setupExpectation.fulfill()
        }
        wait(for: [setupExpectation], timeout: 1.0)
        
        guard let cartItem = viewModel.item(at: 0) else {
            XCTFail("Should have cart item")
            return
        }
        
        let initialDelegateCallCount = mockDelegate.didUpdateCartCallCount
        
        // When
        viewModel.updateQuantity(for: cartItem, quantity: 5)
        
        // Then
        let expectation = XCTestExpectation(description: "Quantity update")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertEqual(viewModel.getTotalItemCount(), 5, "Total count should be updated to 5")
        XCTAssertGreaterThan(mockDelegate.didUpdateCartCallCount, initialDelegateCallCount, "Delegate should be called again")
    }
    
    func testUpdateItemQuantityToZero() {
        // Given
        let product = testProducts[0]
        CoreDataManager.shared.addToCart(product: product, quantity: 1)
        
        // Wait for initial update
        let setupExpectation = XCTestExpectation(description: "Setup cart")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            setupExpectation.fulfill()
        }
        wait(for: [setupExpectation], timeout: 1.0)
        
        guard let cartItem = viewModel.item(at: 0) else {
            XCTFail("Should have cart item")
            return
        }
        
        // When
        viewModel.updateQuantity(for: cartItem, quantity: 0)
        
        // Then
        let expectation = XCTestExpectation(description: "Item removal")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertTrue(viewModel.isEmpty, "Cart should be empty after setting quantity to 0")
        XCTAssertEqual(viewModel.numberOfItems(), 0, "Should have 0 items")
    }
    
    // MARK: - Remove Items Tests
    
    func testRemoveItem() {
        // Given
        let product = testProducts[0]
        CoreDataManager.shared.addToCart(product: product, quantity: 2)
        
        // Wait for initial update
        let setupExpectation = XCTestExpectation(description: "Setup cart")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            setupExpectation.fulfill()
        }
        wait(for: [setupExpectation], timeout: 1.0)
        
        guard let cartItem = viewModel.item(at: 0) else {
            XCTFail("Should have cart item")
            return
        }
        
        // When
        viewModel.removeItem(cartItem)
        
        // Then
        let expectation = XCTestExpectation(description: "Item removal")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertTrue(viewModel.isEmpty, "Cart should be empty after removing item")
        XCTAssertEqual(viewModel.numberOfItems(), 0, "Should have 0 items")
    }
    
    // MARK: - Price Calculation Tests
    
    func testGetTotalPrice() {
        // Given
        let product1 = testProducts[0] // Price: 15000
        let product2 = testProducts[1] // Price: 12000
        
        CoreDataManager.shared.addToCart(product: product1, quantity: 2) // 15000 * 2 = 30000
        CoreDataManager.shared.addToCart(product: product2, quantity: 1) // 12000 * 1 = 12000
        
        // Wait for updates
        let expectation = XCTestExpectation(description: "Price calculation")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        // Then
        let totalPrice = viewModel.getTotalPrice()
        XCTAssertEqual(totalPrice, "42000 ₺", "Total price should be 42000 ₺")
    }
    
    func testGetTotalPriceWithSingleItem() {
        // Given
        let product = testProducts[0] // Price: 15000
        CoreDataManager.shared.addToCart(product: product, quantity: 3)
        
        // Wait for update
        let expectation = XCTestExpectation(description: "Single item price")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        // Then
        let totalPrice = viewModel.getTotalPrice()
        XCTAssertEqual(totalPrice, "45000 ₺", "Total price should be 45000 ₺")
    }
    
    // MARK: - Data Access Tests
    
    func testItemAtIndex() {
        // Given
        let product = testProducts[0]
        CoreDataManager.shared.addToCart(product: product)
        
        // Wait for update
        let expectation = XCTestExpectation(description: "Item access")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        // When
        let item = viewModel.item(at: 0)
        
        // Then
        XCTAssertNotNil(item, "Should return item at index 0")
        XCTAssertEqual(item?.productId, product.id, "Item should have correct product ID")
        XCTAssertEqual(item?.productName, product.name, "Item should have correct product name")
    }
    
    func testItemAtInvalidIndex() {
        // Given - Empty cart
        
        // When
        let item = viewModel.item(at: 0)
        
        // Then
        XCTAssertNil(item, "Should return nil for invalid index")
    }
    
    func testItemAtNegativeIndex() {
        // Given
        let product = testProducts[0]
        CoreDataManager.shared.addToCart(product: product)
        
        // When
        let item = viewModel.item(at: -1)
        
        // Then
        XCTAssertNil(item, "Should return nil for negative index")
    }
    
    // MARK: - Notification Tests
    
    func testNotificationCenterIntegration() {
        // Given
        let initialCallCount = mockDelegate.didUpdateCartCallCount
        
        // When - Add item directly via CoreDataManager (should trigger notification)
        CoreDataManager.shared.addToCart(product: testProducts[0])
        
        // Then
        let expectation = XCTestExpectation(description: "Notification received")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertGreaterThan(mockDelegate.didUpdateCartCallCount, initialCallCount, "Delegate should be called via notification")
    }
    
    // MARK: - Edge Cases
    
    func testDelegateNotSet() {
        // Given
        viewModel.delegate = nil
        
        // When - Should not crash
        CoreDataManager.shared.addToCart(product: testProducts[0])
        
        // Then
        XCTAssertTrue(true, "Should not crash when delegate is nil")
    }
    
    func testMultipleNotificationsHandling() {
        // Given
        let initialCallCount = mockDelegate.didUpdateCartCallCount
        
        // When - Add multiple items quickly
        testProducts.forEach { product in
            CoreDataManager.shared.addToCart(product: product)
        }
        
        // Then
        let expectation = XCTestExpectation(description: "Multiple notifications")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertGreaterThan(mockDelegate.didUpdateCartCallCount, initialCallCount, "Should handle multiple notifications")
        XCTAssertEqual(viewModel.numberOfItems(), 3, "Should have all items added")
    }
}
