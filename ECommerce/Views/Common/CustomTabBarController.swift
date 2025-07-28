//
//  CustomTabBarController.swift
//  ECommerce
//
//  Created by furkankarakoc on 27.07.2025.
//

import Foundation
import UIKit

// MARK: - CustomTabBarController.swift
class CustomTabBarController: UITabBarController {
    
    private var cartBadge: UILabel = {
        let label = UILabel()
        label.backgroundColor = .red
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 10)
        label.textAlignment = .center
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        setupCartBadge()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateCartBadge),
            name: .cartDidUpdate,
            object: nil
        )
        
        updateCartBadge()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupTabBar() {
        tabBar.tintColor = .primaryBlue
        tabBar.unselectedItemTintColor = .gray
        tabBar.backgroundColor = .white
        
        // Create view controllers
        let productListVC = ProductListViewController()
        let cartVC = CartViewController()
        let favoriteVC = FavoriteViewController()
        
        // Wrap in navigation controllers
        let productListNav = UINavigationController(rootViewController: productListVC)
        let cartNav = UINavigationController(rootViewController: cartVC)
        let favoriteNav = UINavigationController(rootViewController: favoriteVC)
        
        // Set tab bar items
        productListNav.tabBarItem = UITabBarItem(
            title: "Home",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )
        
        cartNav.tabBarItem = UITabBarItem(
            title: "Cart",
            image: UIImage(systemName: "cart"),
            selectedImage: UIImage(systemName: "cart.fill")
        )
        
        favoriteNav.tabBarItem = UITabBarItem(
            title: "Favorites",
            image: UIImage(systemName: "star"),
            selectedImage: UIImage(systemName: "star.fill")
        )
        
        viewControllers = [productListNav, cartNav, favoriteNav]
    }
    
    private func setupCartBadge() {
        guard let cartTabBarItem = tabBar.items?[1] else { return }
        
        tabBar.addSubview(cartBadge)
        
        let tabBarItemWidth = tabBar.frame.width / CGFloat(tabBar.items?.count ?? 1)
        let cartTabCenterX = tabBarItemWidth + (tabBarItemWidth / 2)
        
        NSLayoutConstraint.activate([
            cartBadge.centerXAnchor.constraint(equalTo: tabBar.leadingAnchor, constant: cartTabCenterX + 10),
            cartBadge.centerYAnchor.constraint(equalTo: tabBar.topAnchor, constant: 8),
            cartBadge.widthAnchor.constraint(equalToConstant: 16),
            cartBadge.heightAnchor.constraint(equalToConstant: 16)
        ])
    }
    
    @objc private func updateCartBadge() {
        let count = CoreDataManager.shared.getCartItemCount()
        
        DispatchQueue.main.async {
            if count > 0 {
                self.cartBadge.text = "\(count)"
                self.cartBadge.isHidden = false
            } else {
                self.cartBadge.isHidden = true
            }
        }
    }
}
