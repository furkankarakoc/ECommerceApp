//
//  CartViewController.swift
//  ECommerce
//
//  Created by furkankarakoc on 27.07.2025.
//

import Foundation
import UIKit

// MARK: - CartViewController.swift
class CartViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel = CartViewModel()
    
    // MARK: - UI Components
    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .primaryBlue
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "E-Commerce"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CartItemCell.self, forCellReuseIdentifier: CartItemCell.identifier)
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let totalView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.addShadow(offset: CGSize(width: 0, height: -2))
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let totalLabel: UILabel = {
        let label = UILabel()
        label.text = "Total:"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .primaryBlue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let totalPriceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let completeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Complete", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .primaryBlue
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.addCornerRadius(12)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let noDataView = NoDataView()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubviews(headerView, tableView, totalView, noDataView)
        headerView.addSubview(titleLabel)
        totalView.addSubviews(totalLabel, totalPriceLabel, completeButton)
        
        setupConstraints()
        setupTargets()
        
        noDataView.configure(
            title: "Your cart is empty",
            message: "Add some products to get started",
            imageName: "cart"
        )
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Header
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 60),
            
            // Title
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            
            // Table View
            tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: totalView.topAnchor),
            
            // Total View
            totalView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            totalView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            totalView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            totalView.heightAnchor.constraint(equalToConstant: 120),
            
            // Total Label
            totalLabel.topAnchor.constraint(equalTo: totalView.topAnchor, constant: 16),
            totalLabel.leadingAnchor.constraint(equalTo: totalView.leadingAnchor, constant: 16),
            
            // Total Price Label
            totalPriceLabel.centerYAnchor.constraint(equalTo: totalLabel.centerYAnchor),
            totalPriceLabel.trailingAnchor.constraint(equalTo: totalView.trailingAnchor, constant: -16),
            
            // Complete Button
            completeButton.topAnchor.constraint(equalTo: totalLabel.bottomAnchor, constant: 16),
            completeButton.leadingAnchor.constraint(equalTo: totalView.leadingAnchor, constant: 16),
            completeButton.trailingAnchor.constraint(equalTo: totalView.trailingAnchor, constant: -16),
            completeButton.heightAnchor.constraint(equalToConstant: 48),
            
            // No Data View
            noDataView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            noDataView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            noDataView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            noDataView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupTargets() {
        completeButton.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)
    }
    
    private func setupBindings() {
        viewModel.delegate = self
    }
    
    private func updateUI() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.totalPriceLabel.text = self.viewModel.getTotalPrice()
            
            if self.viewModel.isEmpty {
                self.noDataView.isHidden = false
                self.tableView.isHidden = true
                self.totalView.isHidden = true
            } else {
                self.noDataView.isHidden = true
                self.tableView.isHidden = false
                self.totalView.isHidden = false
            }
        }
    }
    
    // MARK: - Actions
    @objc private func completeButtonTapped() {
        let alert = UIAlertController(
            title: "Order Complete",
            message: "Your order has been placed successfully!",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - CartViewModelDelegate
extension CartViewController: CartViewModelDelegate {
    func didUpdateCart() {
        updateUI()
    }
    
    func didFailWithError(_ error: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
}

// MARK: - UITableViewDataSource
extension CartViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfItems()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CartItemCell.identifier, for: indexPath) as! CartItemCell
        
        if let item = viewModel.item(at: indexPath.row) {
            cell.configure(with: item)
            cell.delegate = self
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension CartViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let item = viewModel.item(at: indexPath.row) {
                viewModel.removeItem(item)
            }
        }
    }
}

// MARK: - CartItemCellDelegate
extension CartViewController: CartItemCellDelegate {
    func didUpdateQuantity(for item: CartItem, quantity: Int) {
        viewModel.updateQuantity(for: item, quantity: quantity)
    }
}

