//
//  QuantitySelector.swift
//  ECommerce
//
//  Created by furkankarakoc on 27.07.2025.
//

import Foundation
import UIKit

protocol QuantitySelectorDelegate: AnyObject {
    func quantityDidChange(_ quantity: Int)
}

class QuantitySelector: UIView {
    
    // MARK: - Properties
    weak var delegate: QuantitySelectorDelegate?
    private(set) var quantity: Int = 1 {
        didSet {
            quantityLabel.text = "\(quantity)"
            delegate?.quantityDidChange(quantity)
        }
    }
    
    var minQuantity: Int = 0
    var maxQuantity: Int = 99
    
    // MARK: - UI Components
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
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupTargets()
        updateQuantityDisplay()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        addSubviews(decreaseButton, quantityLabel, increaseButton)
        
        NSLayoutConstraint.activate([
            // Decrease Button
            decreaseButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            decreaseButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            decreaseButton.widthAnchor.constraint(equalToConstant: 32),
            decreaseButton.heightAnchor.constraint(equalToConstant: 32),
            
            // Quantity Label
            quantityLabel.leadingAnchor.constraint(equalTo: decreaseButton.trailingAnchor, constant: 4),
            quantityLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            quantityLabel.widthAnchor.constraint(equalToConstant: 40),
            quantityLabel.heightAnchor.constraint(equalToConstant: 32),
            
            // Increase Button
            increaseButton.leadingAnchor.constraint(equalTo: quantityLabel.trailingAnchor, constant: 4),
            increaseButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            increaseButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            increaseButton.widthAnchor.constraint(equalToConstant: 32),
            increaseButton.heightAnchor.constraint(equalToConstant: 32),
            
            // Self height
            heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    private func setupTargets() {
        decreaseButton.addTarget(self, action: #selector(decreaseButtonTapped), for: .touchUpInside)
        increaseButton.addTarget(self, action: #selector(increaseButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func decreaseButtonTapped() {
        if quantity > minQuantity {
            quantity -= 1
            updateButtonStates()
        }
    }
    
    @objc private func increaseButtonTapped() {
        if quantity < maxQuantity {
            quantity += 1
            updateButtonStates()
        }
    }
    
    // MARK: - Public Methods
    func setQuantity(_ newQuantity: Int) {
        quantity = max(minQuantity, min(maxQuantity, newQuantity))
        updateButtonStates()
    }
    
    private func updateQuantityDisplay() {
        quantityLabel.text = "\(quantity)"
    }
    
    private func updateButtonStates() {
        decreaseButton.isEnabled = quantity > minQuantity
        increaseButton.isEnabled = quantity < maxQuantity
        
        decreaseButton.alpha = decreaseButton.isEnabled ? 1.0 : 0.5
        increaseButton.alpha = increaseButton.isEnabled ? 1.0 : 0.5
    }
}
