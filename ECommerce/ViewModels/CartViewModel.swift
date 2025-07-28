//
//  CartViewModel.swift
//  ECommerce
//
//  Created by furkankarakoc on 27.07.2025.
//

import Foundation



// MARK: - CartViewModel.swift
protocol CartViewModelDelegate: AnyObject {
    func didUpdateCart()
    func didFailWithError(_ error: String)
}

class CartViewModel {
    weak var delegate: CartViewModelDelegate?
    private let coreDataManager = CoreDataManager.shared
    private(set) var cartItems: [CartItem] = []
    
    init() {
        loadCartItems()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(cartDidUpdate),
            name: .cartDidUpdate,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func cartDidUpdate() {
        loadCartItems()
    }
    
    private func loadCartItems() {
        cartItems = coreDataManager.fetchCartItems()
        delegate?.didUpdateCart()
    }
    
    func updateQuantity(for item: CartItem, quantity: Int) {
        coreDataManager.updateCartItemQuantity(productId: item.productId!, quantity: quantity)
    }
    
    func removeItem(_ item: CartItem) {
        coreDataManager.removeFromCart(productId: item.productId!)
    }
    
    func getTotalPrice() -> String {
        let total = cartItems.reduce(0.0) { sum, item in
            let price = Double(item.productPrice ?? "0") ?? 0.0
            return sum + (price * Double(item.quantity))
        }
        return String(format: "%.0f ₺", total)
    }
    
    func getTotalItemCount() -> Int {
        return cartItems.reduce(0) { $0 + Int($1.quantity) }
    }
    
    func numberOfItems() -> Int {
        return cartItems.count
    }
    
    func item(at index: Int) -> CartItem? {
        guard index < cartItems.count else { return nil }
        return cartItems[index]
    }
    
    var isEmpty: Bool {
        return cartItems.isEmpty
    }
}
