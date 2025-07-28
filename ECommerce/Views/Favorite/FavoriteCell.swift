//
//  FavoriteCell.swift
//  ECommerce
//
//  Created by furkankarakoc on 27.07.2025.
//

import Foundation
import UIKit

// MARK: - FavoriteCell.swift
protocol FavoriteCellDelegate: AnyObject {
    func didTapAddToCart(for item: FavoriteItem)
    func didTapRemoveFromFavorites(for item: FavoriteItem)
}

class FavoriteCell: UITableViewCell {
    static let identifier = "FavoriteCell"
    
    // MARK: - Properties
    weak var delegate: FavoriteCellDelegate?
    private var favoriteItem: FavoriteItem?
    
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
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .black
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .primaryBlue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let removeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "star.fill"), for: .normal)
        button.tintColor = .yellow
        button.backgroundColor = .white
        button.addCornerRadius(12)
        button.addShadow(opacity: 0.2)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupTargets()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        productImageView.image = nil
    }
    
    // MARK: - Setup
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        
        contentView.addSubview(containerView)
        containerView.addSubviews(
            productImageView, removeButton, nameLabel, priceLabel, addToCartButton
        )
        
        NSLayoutConstraint.activate([
            // Container
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            // Product Image
            productImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            productImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            productImageView.widthAnchor.constraint(equalToConstant: 80),
            productImageView.heightAnchor.constraint(equalToConstant: 80),
            
            // Remove Button
            removeButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            removeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            removeButton.widthAnchor.constraint(equalToConstant: 24),
            removeButton.heightAnchor.constraint(equalToConstant: 24),
            
            // Name Label
            nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: productImageView.trailingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: removeButton.leadingAnchor, constant: -8),
            
            // Price Label
            priceLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            priceLabel.leadingAnchor.constraint(equalTo: productImageView.trailingAnchor, constant: 12),
            
            // Add to Cart Button
            addToCartButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            addToCartButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            addToCartButton.widthAnchor.constraint(equalToConstant: 100),
            addToCartButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    private func setupTargets() {
        removeButton.addTarget(self, action: #selector(removeButtonTapped), for: .touchUpInside)
        addToCartButton.addTarget(self, action: #selector(addToCartButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func removeButtonTapped() {
        guard let item = favoriteItem else { return }
        delegate?.didTapRemoveFromFavorites(for: item)
        
        // Add animation
        removeButton.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        UIView.animate(withDuration: 0.2) {
            self.removeButton.transform = CGAffineTransform.identity
        }
    }
    
    @objc private func addToCartButtonTapped() {
        guard let item = favoriteItem else { return }
        delegate?.didTapAddToCart(for: item)
        
        // Add animation feedback
        addToCartButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        UIView.animate(withDuration: 0.1, animations: {
            self.addToCartButton.transform = CGAffineTransform.identity
        })
    }
    
    // MARK: - Configuration
    func configure(with item: FavoriteItem) {
        favoriteItem = item
        
        nameLabel.text = item.productName
        priceLabel.text = "\(item.productPrice ?? "0") ₺"
        
        loadImage(from: item.productImage ?? "")
    }
    
    private func loadImage(from urlString: String) {
        productImageView.image = UIImage(systemName: "photo")
        productImageView.tintColor = .lightGray
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, error == nil, let image = UIImage(data: data) else {
                return
            }
            
            DispatchQueue.main.async {
                self?.productImageView.image = image
                self?.productImageView.tintColor = nil
            }
        }.resume()
    }
}
