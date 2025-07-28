//
//  ProductDetailViewController.swift
//  ECommerce
//
//  Created by furkankarakoc on 27.07.2025.
//

import Foundation
import UIKit

class ProductDetailViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: ProductDetailViewModel
    
    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let productImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .lightGray
        imageView.addCornerRadius(12)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "star"), for: .normal)
        button.setImage(UIImage(systemName: "star.fill"), for: .selected)
        button.tintColor = .yellow
        button.backgroundColor = .white
        button.addCornerRadius(20)
        button.addShadow(opacity: 0.2)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = .black
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .darkGray
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 28)
        label.textColor = .primaryBlue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let addToCartButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add to Cart", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .primaryBlue
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.addCornerRadius(12)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Initialization
    init(product: Product) {
        self.viewModel = ProductDetailViewModel(product: product)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        configureWithProduct()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateFavoriteButton()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .white
        navigationController?.isNavigationBarHidden = false
        
        // Navigation setup
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
        navigationItem.leftBarButtonItem?.tintColor = .black
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubviews(
            productImageView, favoriteButton, titleLabel,
            descriptionLabel, priceLabel, addToCartButton
        )
        
        setupConstraints()
        setupTargets()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Scroll View
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // Content View
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Product Image
            productImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            productImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            productImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            productImageView.heightAnchor.constraint(equalToConstant: 300),
            
            // Favorite Button
            favoriteButton.topAnchor.constraint(equalTo: productImageView.topAnchor, constant: 16),
            favoriteButton.trailingAnchor.constraint(equalTo: productImageView.trailingAnchor, constant: -16),
            favoriteButton.widthAnchor.constraint(equalToConstant: 40),
            favoriteButton.heightAnchor.constraint(equalToConstant: 40),
            
            // Title Label
            titleLabel.topAnchor.constraint(equalTo: productImageView.bottomAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Description Label
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Price Label
            priceLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 24),
            priceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            // Add to Cart Button
            addToCartButton.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 32),
            addToCartButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            addToCartButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            addToCartButton.heightAnchor.constraint(equalToConstant: 56),
            addToCartButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32)
        ])
    }
    
    private func setupTargets() {
        addToCartButton.addTarget(self, action: #selector(addToCartTapped), for: .touchUpInside)
        favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
    }
    
    private func setupBindings() {
        viewModel.delegate = self
    }
    
    private func configureWithProduct() {
        let product = viewModel.product
        
        title = product.name
        titleLabel.text = product.name
        descriptionLabel.text = product.description
        priceLabel.text = product.formattedPrice
        
        loadImage(from: product.image)
        updateFavoriteButton()
    }
    
    private func loadImage(from urlString: String) {
        // Set placeholder
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
    
    private func updateFavoriteButton() {
        favoriteButton.isSelected = viewModel.isFavorite()
    }
    
    // MARK: - Actions
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func addToCartTapped() {
        viewModel.addToCart()
    }
    
    @objc private func favoriteButtonTapped() {
        viewModel.toggleFavorite()
        
        // Add animation
        favoriteButton.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: [], animations: {
            self.favoriteButton.transform = CGAffineTransform.identity
        }, completion: nil)
    }
}

// MARK: - ProductDetailViewModelDelegate
extension ProductDetailViewController: ProductDetailViewModelDelegate {
    func didUpdateFavoriteStatus() {
        DispatchQueue.main.async {
            self.updateFavoriteButton()
        }
    }
    
    func didAddToCart() {
        DispatchQueue.main.async {
            // Show success animation
            let originalTitle = self.addToCartButton.title(for: .normal)
            let originalColor = self.addToCartButton.backgroundColor
            
            self.addToCartButton.setTitle("Added to Cart!", for: .normal)
            self.addToCartButton.backgroundColor = .systemGreen
            
            // Scale animation
            self.addToCartButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            UIView.animate(withDuration: 0.1, animations: {
                self.addToCartButton.transform = CGAffineTransform.identity
            })
            
            // Reset after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.addToCartButton.setTitle(originalTitle, for: .normal)
                self.addToCartButton.backgroundColor = originalColor
            }
        }
    }
}
