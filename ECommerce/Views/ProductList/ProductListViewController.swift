//
//  ProductListViewController.swift
//  ECommerce
//
//  Created by furkankarakoc on 27.07.2025.
//

import Foundation
import UIKit

class ProductListViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel = ProductListViewModel()
    
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
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let searchFilterContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let searchBar: CustomSearchBar = {
        let searchBar = CustomSearchBar()
        searchBar.placeholder = "Search"
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    private let filterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Select Filter", for: .normal)
        button.backgroundColor = .lightGray
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.addCornerRadius(6)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ProductCell.self, forCellWithReuseIdentifier: ProductCell.identifier)
        collectionView.showsVerticalScrollIndicator = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private let loadingView = LoadingView()
    private let noDataView = NoDataView()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        viewModel.fetchProducts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubviews(headerView, collectionView, loadingView, noDataView)
        headerView.addSubviews(titleLabel, searchFilterContainerView)
        searchFilterContainerView.addSubviews(searchBar, filterButton)
        
        setupConstraints()
        setupTargets()
        
        loadingView.isHidden = true
        noDataView.isHidden = true
        noDataView.configure(title: "No Products", message: "No products found matching your criteria")
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Header View - Daha yüksek yapıyoruz
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 140),
            
            // Title Label
            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            titleLabel.heightAnchor.constraint(equalToConstant: 30),
            
            // Search Filter Container
            searchFilterContainerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            searchFilterContainerView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            searchFilterContainerView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            searchFilterContainerView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -16),
            
            // Search Bar
            searchBar.topAnchor.constraint(equalTo: searchFilterContainerView.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: searchFilterContainerView.leadingAnchor),
            searchBar.bottomAnchor.constraint(equalTo: searchFilterContainerView.bottomAnchor),
            searchBar.trailingAnchor.constraint(equalTo: filterButton.leadingAnchor, constant: -8),
            
            // Filter Button
            filterButton.topAnchor.constraint(equalTo: searchFilterContainerView.topAnchor),
            filterButton.trailingAnchor.constraint(equalTo: searchFilterContainerView.trailingAnchor),
            filterButton.bottomAnchor.constraint(equalTo: searchFilterContainerView.bottomAnchor),
            filterButton.widthAnchor.constraint(equalToConstant: 80),
            
            // Collection View
            collectionView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // Loading View
            loadingView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // No Data View
            noDataView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            noDataView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            noDataView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            noDataView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupTargets() {
        filterButton.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        searchBar.delegate = self
    }
    
    private func setupBindings() {
        viewModel.delegate = self
    }
    
    // MARK: - Actions
    @objc private func filterButtonTapped() {
        print("Filter button tapped")
        let filterVC = FilterViewController()
        filterVC.currentFilterOptions = viewModel.getCurrentFilterOptions()
        filterVC.availableBrands = viewModel.getAllBrands()
        filterVC.availableModels = viewModel.getAllModels()
        filterVC.delegate = self
        
        let navController = UINavigationController(rootViewController: filterVC)
        present(navController, animated: true)
    }
    
    private func updateUI() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            
            if self.viewModel.isEmpty {
                self.noDataView.isHidden = false
                self.collectionView.isHidden = true
            } else {
                self.noDataView.isHidden = true
                self.collectionView.isHidden = false
            }
        }
    }
}

// MARK: - ProductListViewModelDelegate
extension ProductListViewController: ProductListViewModelDelegate {
    func didUpdateProducts() {
        updateUI()
    }
    
    func didFailWithError(_ error: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
    
    func didStartLoading() {
        DispatchQueue.main.async {
            self.loadingView.startAnimating()
            self.collectionView.isHidden = true
            self.noDataView.isHidden = true
        }
    }
    
    func didFinishLoading() {
        DispatchQueue.main.async {
            self.loadingView.stopAnimating()
        }
    }
}

// MARK: - UICollectionViewDataSource
extension ProductListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfProducts()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProductCell.identifier, for: indexPath) as! ProductCell
        
        if let product = viewModel.product(at: indexPath.item) {
            cell.configure(with: product)
        }
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension ProductListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let product = viewModel.product(at: indexPath.item) else { return }
        
        let detailVC = ProductDetailViewController(product: product)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        viewModel.loadMoreProductsIfNeeded(for: indexPath.item)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ProductListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let insets = (collectionViewLayout as! UICollectionViewFlowLayout).sectionInset
        let interItemSpacing = (collectionViewLayout as! UICollectionViewFlowLayout).minimumInteritemSpacing
        
        let totalHorizontalSpacing = insets.left + insets.right + interItemSpacing
        let availableWidth = collectionView.frame.width - totalHorizontalSpacing
        let cellWidth = floor(availableWidth / 2)
        
        return CGSize(width: cellWidth, height: 280)
    }
}

// MARK: - CustomSearchBarDelegate
extension ProductListViewController: CustomSearchBarDelegate {
    func searchBar(_ searchBar: CustomSearchBar, textDidChange searchText: String) {
        print("Search text: \(searchText)")
        viewModel.searchProducts(with: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: CustomSearchBar) {
        searchBar.resignFirstResponder()
    }
}

// MARK: - FilterViewControllerDelegate
extension ProductListViewController: FilterViewControllerDelegate {
    func didApplyFilter(_ options: FilterOptions) {
        viewModel.applyFilter(options)
    }
}
