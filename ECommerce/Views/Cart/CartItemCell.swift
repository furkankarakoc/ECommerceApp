//
//  CartItemCell.swift
//  ECommerce
//
//  Created by furkankarakoc on 27.07.2025.
//

import Foundation
import UIKit

// MARK: - CartItemCell.swift
protocol CartItemCellDelegate: AnyObject {
    func didUpdateQuantity(for item: CartItem, quantity: Int)
}

class CartItemCell: UITableViewCell {
    static let identifier = "CartItemCell"
    
    // MARK: - Properties
    weak var delegate: CartItemCellDelegate?
    private var cartItem: CartItem?
    
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
    
    private let decreaseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("-", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .lightGray
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.addCornerRadius(4)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let quantityLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .white
        label.backgroundColor = .primaryBlue
        label.textAlignment = .center
        label.addCornerRadius(4)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let increaseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("+", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .lightGray
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.addCornerRadius(4)
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
            productImageView, nameLabel, priceLabel,
            decreaseButton, quantityLabel, increaseButton
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
            
            // Name Label
            nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: productImageView.trailingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            // Price Label
            priceLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            priceLabel.leadingAnchor.constraint(equalTo: productImageView.trailingAnchor, constant: 12),
            
            // Quantity Controls
            increaseButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            increaseButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            increaseButton.widthAnchor.constraint(equalToConstant: 32),
            increaseButton.heightAnchor.constraint(equalToConstant: 32),
            
            quantityLabel.trailingAnchor.constraint(equalTo: increaseButton.leadingAnchor, constant: -4),
            quantityLabel.centerYAnchor.constraint(equalTo: increaseButton.centerYAnchor),
            quantityLabel.widthAnchor.constraint(equalToConstant: 40),
            quantityLabel.heightAnchor.constraint(equalToConstant: 32),
            
            decreaseButton.trailingAnchor.constraint(equalTo: quantityLabel.leadingAnchor, constant: -4),
            decreaseButton.centerYAnchor.constraint(equalTo: increaseButton.centerYAnchor),
            decreaseButton.widthAnchor.constraint(equalToConstant: 32),
            decreaseButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    private func setupTargets() {
        decreaseButton.addTarget(self, action: #selector(decreaseButtonTapped), for: .touchUpInside)
        increaseButton.addTarget(self, action: #selector(increaseButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func decreaseButtonTapped() {
        guard let item = cartItem else { return }
        let newQuantity = max(0, Int(item.quantity) - 1)
        delegate?.didUpdateQuantity(for: item, quantity: newQuantity)
    }
    
    @objc private func increaseButtonTapped() {
        guard let item = cartItem else { return }
        let newQuantity = Int(item.quantity) + 1
        delegate?.didUpdateQuantity(for: item, quantity: newQuantity)
    }
    
    // MARK: - Configuration
    func configure(with item: CartItem) {
        cartItem = item
        
        nameLabel.text = item.productName
        priceLabel.text = "\(item.productPrice ?? "0") ₺"
        quantityLabel.text = "\(item.quantity)"
        
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
