//
//  ProductDetailViewModel.swift
//  ECommerce
//
//  Created by furkankarakoc on 27.07.2025.
//

import Foundation

// MARK: - ProductDetailViewModel.swift
protocol ProductDetailViewModelDelegate: AnyObject {
    func didUpdateFavoriteStatus()
    func didAddToCart()
}

class ProductDetailViewModel {
    weak var delegate: ProductDetailViewModelDelegate?
    private let coreDataManager = CoreDataManager.shared
    private(set) var product: Product
    
    init(product: Product) {
        self.product = product
    }
    
    func addToCart() {
        coreDataManager.addToCart(product: product)
        delegate?.didAddToCart()
    }
    
    func toggleFavorite() {
        if isFavorite() {
            coreDataManager.removeFromFavorites(productId: product.id)
        } else {
            coreDataManager.addToFavorites(product: product)
        }
        delegate?.didUpdateFavoriteStatus()
    }
    
    func isFavorite() -> Bool {
        return coreDataManager.isFavorite(productId: product.id)
    }
}
