//
//  ProductCell.swift
//  ECommerce
//
//  Created by furkankarakoc on 27.07.2025.
//

import Foundation
import UIKit

class ProductCell: UICollectionViewCell {
    static let identifier = "ProductCell"
    
    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.addCornerRadius(12)
        view.addShadow()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let productImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .lightGray
        imageView.addCornerRadius(8)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "star"), for: .normal)
        button.setImage(UIImage(systemName: "star.fill"), for: .selected)
        button.tintColor = .yellow
        button.backgroundColor = .white
        button.addCornerRadius(12)
        button.addShadow(opacity: 0.2)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .primaryBlue
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .black
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let addToCartButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add to Cart", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .primaryBlue
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addCornerRadius(8)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Properties
    private var product: Product?
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupTargets()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        productImageView.image = nil
        favoriteButton.isSelected = false
    }
    
    // MARK: - Setup
    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubviews(productImageView, favoriteButton, priceLabel, nameLabel, addToCartButton)
        
        NSLayoutConstraint.activate([
            // Container
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            // Product Image
            productImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            productImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            productImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            productImageView.heightAnchor.constraint(equalToConstant: 140),
            
            // Favorite Button
            favoriteButton.topAnchor.constraint(equalTo: productImageView.topAnchor, constant: 8),
            favoriteButton.trailingAnchor.constraint(equalTo: productImageView.trailingAnchor, constant: -8),
            favoriteButton.widthAnchor.constraint(equalToConstant: 24),
            favoriteButton.heightAnchor.constraint(equalToConstant: 24),
            
            // Price Label
            priceLabel.topAnchor.constraint(equalTo: productImageView.bottomAnchor, constant: 8),
            priceLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            priceLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            
            // Name Label
            nameLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 4),
            nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            nameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            
            // Add to Cart Button
            addToCartButton.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 12),
            addToCartButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            addToCartButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            addToCartButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
            addToCartButton.heightAnchor.constraint(equalToConstant: 36)
        ])
    }
    
    private func setupTargets() {
        addToCartButton.addTarget(self, action: #selector(addToCartTapped), for: .touchUpInside)
        favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func addToCartTapped() {
        guard let product = product else { return }
        
        CoreDataManager.shared.addToCart(product: product)
        
        // Add animation feedback
        addToCartButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        UIView.animate(withDuration: 0.1, animations: {
            self.addToCartButton.transform = CGAffineTransform.identity
        })
        
        // Show success feedback
        let originalTitle = addToCartButton.title(for: .normal)
        addToCartButton.setTitle("Added!", for: .normal)
        addToCartButton.backgroundColor = .systemGreen
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.addToCartButton.setTitle(originalTitle, for: .normal)
            self.addToCartButton.backgroundColor = .primaryBlue
        }
    }
    
    @objc private func favoriteButtonTapped() {
        guard let product = product else { return }
        
        favoriteButton.isSelected.toggle()
        
        if favoriteButton.isSelected {
            CoreDataManager.shared.addToFavorites(product: product)
        } else {
            CoreDataManager.shared.removeFromFavorites(productId: product.id)
        }
        
        // Add animation
        favoriteButton.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        UIView.animate(withDuration: 0.2) {
            self.favoriteButton.transform = CGAffineTransform.identity
        }
    }
    
    // MARK: - Configuration
    func configure(with product: Product) {
        self.product = product
        
        priceLabel.text = product.formattedPrice
        nameLabel.text = product.name
        
        // Check favorite status
        favoriteButton.isSelected = CoreDataManager.shared.isFavorite(productId: product.id)
        
        // Load image
        loadImage(from: product.image)
    }
    
    private func loadImage(from urlString: String) {
        // Set placeholder
        productImageView.image = UIImage(systemName: "photo")
        productImageView.tintColor = .lightGray
        productImageView.contentMode = .scaleAspectFit
        
        guard !urlString.isEmpty, let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            return
        }
        
        // Create URLRequest with cache policy
        var request = URLRequest(url: url)
        request.cachePolicy = .returnCacheDataElseLoad
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("Image load error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                print("Failed to create image from data")
                return
            }
            
            DispatchQueue.main.async {
                // Check if cell is still showing the same product
                if let currentProduct = self?.product, currentProduct.image == urlString {
                    self?.productImageView.image = image
                    self?.productImageView.tintColor = nil
                    self?.productImageView.contentMode = .scaleAspectFit
                }
            }
        }.resume()
    }
}
