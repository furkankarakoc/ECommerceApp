//
//  FavoriteViewModel.swift
//  ECommerce
//
//  Created by furkankarakoc on 27.07.2025.
//

import Foundation

// MARK: - FavoriteViewModel.swift
protocol FavoriteViewModelDelegate: AnyObject {
    func didUpdateFavorites()
    func didFailWithError(_ error: String)
}

class FavoriteViewModel {
    weak var delegate: FavoriteViewModelDelegate?
    private let coreDataManager = CoreDataManager.shared
    private(set) var favoriteItems: [FavoriteItem] = []
    
    init() {
        loadFavoriteItems()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(favoriteDidUpdate),
            name: .favoriteDidUpdate,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func favoriteDidUpdate() {
        loadFavoriteItems()
    }
    
    private func loadFavoriteItems() {
        favoriteItems = coreDataManager.fetchFavoriteItems()
        delegate?.didUpdateFavorites()
    }
    
    func removeFromFavorites(_ item: FavoriteItem) {
        coreDataManager.removeFromFavorites(productId: item.productId!)
    }
    
    func addToCart(_ item: FavoriteItem) {
        let product = Product(
            id: item.productId!,
            name: item.productName!,
            image: item.productImage!,
            price: item.productPrice!,
            description: "",
            model: item.productModel!,
            brand: item.productBrand!,
            createdAt: ""
        )
        coreDataManager.addToCart(product: product)
    }
    
    func numberOfItems() -> Int {
        return favoriteItems.count
    }
    
    func item(at index: Int) -> FavoriteItem? {
        guard index < favoriteItems.count else { return nil }
        return favoriteItems[index]
    }
    
    var isEmpty: Bool {
        return favoriteItems.isEmpty
    }
}
