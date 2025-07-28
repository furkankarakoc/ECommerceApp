//
//  SearchBar.swift
//  ECommerce
//
//  Created by furkankarakoc on 27.07.2025.
//

import Foundation
import UIKit

protocol CustomSearchBarDelegate: AnyObject {
    func searchBar(_ searchBar: CustomSearchBar, textDidChange searchText: String)
    func searchBarSearchButtonClicked(_ searchBar: CustomSearchBar)
}

class CustomSearchBar: UIView {
    
    // MARK: - Properties
    weak var delegate: CustomSearchBarDelegate?
    
    var placeholder: String = "Search" {
        didSet {
            textField.placeholder = placeholder
        }
    }
    
    var text: String {
        get { return textField.text ?? "" }
        set { textField.text = newValue }
    }
    
    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.addCornerRadius(8)
        view.addShadow(opacity: 0.1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let searchIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "magnifyingglass")
        imageView.tintColor = .gray
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Search"
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.borderStyle = .none
        textField.returnKeyType = .search
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let clearButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .gray
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupTargets()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        addSubview(containerView)
        containerView.addSubviews(searchIconImageView, textField, clearButton)
        
        NSLayoutConstraint.activate([
            // Container View - Self'e pin et
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Self height constraint
            heightAnchor.constraint(equalToConstant: 44),
            
            // Search Icon
            searchIconImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            searchIconImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            searchIconImageView.widthAnchor.constraint(equalToConstant: 20),
            searchIconImageView.heightAnchor.constraint(equalToConstant: 20),
            
            // Text Field
            textField.leadingAnchor.constraint(equalTo: searchIconImageView.trailingAnchor, constant: 8),
            textField.trailingAnchor.constraint(equalTo: clearButton.leadingAnchor, constant: -8),
            textField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            // Clear Button
            clearButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            clearButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            clearButton.widthAnchor.constraint(equalToConstant: 20),
            clearButton.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    private func setupTargets() {
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        textField.delegate = self
        clearButton.addTarget(self, action: #selector(clearButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func textFieldDidChange() {
        let text = textField.text ?? ""
        clearButton.isHidden = text.isEmpty
        delegate?.searchBar(self, textDidChange: text)
    }
    
    @objc private func clearButtonTapped() {
        textField.text = ""
        clearButton.isHidden = true
        textField.resignFirstResponder()
        delegate?.searchBar(self, textDidChange: "")
    }
    
    // MARK: - Public Methods
    override func becomeFirstResponder() -> Bool {
        return textField.becomeFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
        return textField.resignFirstResponder()
    }
}

// MARK: - UITextFieldDelegate
extension CustomSearchBar: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        delegate?.searchBarSearchButtonClicked(self)
        return true
    }
}
