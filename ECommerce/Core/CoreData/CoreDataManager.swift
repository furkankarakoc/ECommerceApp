//
//  CoreDataManager.swift
//  ECommerce
//
//  Created by furkankarakoc on 27.07.2025.
//

import Foundation
import CoreData
import Foundation

class CoreDataManager {
    static let shared = CoreDataManager()
    
    private init() {}
    
    // MARK: - Core Data Stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ECommerce")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: - Core Data Saving
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    // MARK: - Cart Operations
    func addToCart(product: Product, quantity: Int = 1) {
        let fetchRequest: NSFetchRequest<CartItem> = CartItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "productId == %@", product.id)
        
        do {
            let existingItems = try context.fetch(fetchRequest)
            
            if let existingItem = existingItems.first {
                existingItem.quantity += Int16(quantity)
            } else {
                let cartItem = CartItem(context: context)
                cartItem.productId = product.id
                cartItem.productName = product.name
                cartItem.productImage = product.image
                cartItem.productPrice = product.price
                cartItem.productBrand = product.brand
                cartItem.productModel = product.model
                cartItem.quantity = Int16(quantity)
            }
            
            saveContext()
            NotificationCenter.default.post(name: .cartDidUpdate, object: nil)
        } catch {
            print("Error adding to cart: \(error)")
        }
    }
    
    func removeFromCart(productId: String) {
        let fetchRequest: NSFetchRequest<CartItem> = CartItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "productId == %@", productId)
        
        do {
            let items = try context.fetch(fetchRequest)
            items.forEach { context.delete($0) }
            saveContext()
            NotificationCenter.default.post(name: .cartDidUpdate, object: nil)
        } catch {
            print("Error removing from cart: \(error)")
        }
    }
    
    func updateCartItemQuantity(productId: String, quantity: Int) {
        let fetchRequest: NSFetchRequest<CartItem> = CartItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "productId == %@", productId)
        
        do {
            let items = try context.fetch(fetchRequest)
            if let item = items.first {
                if quantity <= 0 {
                    context.delete(item)
                } else {
                    item.quantity = Int16(quantity)
                }
                saveContext()
                NotificationCenter.default.post(name: .cartDidUpdate, object: nil)
            }
        } catch {
            print("Error updating cart item: \(error)")
        }
    }
    
    func fetchCartItems() -> [CartItem] {
        let fetchRequest: NSFetchRequest<CartItem> = CartItem.fetchRequest()
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Error fetching cart items: \(error)")
            return []
        }
    }
    
    func getCartItemCount() -> Int {
        let items = fetchCartItems()
        return items.reduce(0) { $0 + Int($1.quantity) }
    }
    
    // MARK: - Favorite Operations
    func addToFavorites(product: Product) {
        let fetchRequest: NSFetchRequest<FavoriteItem> = FavoriteItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "productId == %@", product.id)
        
        do {
            let existingItems = try context.fetch(fetchRequest)
            
            if existingItems.isEmpty {
                let favoriteItem = FavoriteItem(context: context)
                favoriteItem.productId = product.id
                favoriteItem.productName = product.name
                favoriteItem.productImage = product.image
                favoriteItem.productPrice = product.price
                favoriteItem.productBrand = product.brand
                favoriteItem.productModel = product.model
                
                saveContext()
                NotificationCenter.default.post(name: .favoriteDidUpdate, object: nil)
            }
        } catch {
            print("Error adding to favorites: \(error)")
        }
    }
    
    func removeFromFavorites(productId: String) {
        let fetchRequest: NSFetchRequest<FavoriteItem> = FavoriteItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "productId == %@", productId)
        
        do {
            let items = try context.fetch(fetchRequest)
            items.forEach { context.delete($0) }
            saveContext()
            NotificationCenter.default.post(name: .favoriteDidUpdate, object: nil)
        } catch {
            print("Error removing from favorites: \(error)")
        }
    }
    
    func isFavorite(productId: String) -> Bool {
        let fetchRequest: NSFetchRequest<FavoriteItem> = FavoriteItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "productId == %@", productId)
        
        do {
            let count = try context.count(for: fetchRequest)
            return count > 0
        } catch {
            print("Error checking favorite status: \(error)")
            return false
        }
    }
    
    func fetchFavoriteItems() -> [FavoriteItem] {
        let fetchRequest: NSFetchRequest<FavoriteItem> = FavoriteItem.fetchRequest()
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Error fetching favorite items: \(error)")
            return []
        }
    }
}
