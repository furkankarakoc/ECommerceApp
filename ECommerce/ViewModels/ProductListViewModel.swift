//
//  ProductListViewModel.swift
//  ECommerce
//
//  Created by furkankarakoc on 27.07.2025.
//


import Foundation

protocol ProductListViewModelDelegate: AnyObject {
    func didUpdateProducts()
    func didFailWithError(_ error: String)
    func didStartLoading()
    func didFinishLoading()
}

class ProductListViewModel {
    
    // MARK: - Properties
    weak var delegate: ProductListViewModelDelegate?
    private let networkManager: NetworkManagerProtocol
    
    private var allProducts: [Product] = []
    private(set) var filteredProducts: [Product] = []
    private(set) var displayedProducts: [Product] = []
    
    private var filterOptions = FilterOptions()
    private let itemsPerPage = 4
    private var currentPage = 0
    private var isLoading = false
    
    // MARK: - Initialization
    init(networkManager: NetworkManagerProtocol = NetworkManager.shared) {
        self.networkManager = networkManager
    }
    
    // MARK: - Public Methods
    func fetchProducts() {
        guard !isLoading else { return }
        
        isLoading = true
        delegate?.didStartLoading()
        
        networkManager.fetchProducts { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.delegate?.didFinishLoading()
                
                switch result {
                case .success(let products):
                    self?.allProducts = products
                    self?.applyFiltersAndSearch()
                case .failure(let error):
                    self?.delegate?.didFailWithError(error.localizedDescription)
                }
            }
        }
    }
    
    func loadMoreProductsIfNeeded(for index: Int) {
        // Son 2 elemandan birini görüntülediğimizde yeni sayfa yükle
        guard index >= displayedProducts.count - 2,
              displayedProducts.count < filteredProducts.count,
              !isLoading else {
            return
        }
        
        loadMoreProducts()
    }
    
    private func loadMoreProducts() {
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            
            let startIndex = self.displayedProducts.count
            let endIndex = min(startIndex + self.itemsPerPage, self.filteredProducts.count)
            
            if startIndex < endIndex {
                let newProducts = Array(self.filteredProducts[startIndex..<endIndex])
                self.displayedProducts.append(contentsOf: newProducts)
                self.delegate?.didUpdateProducts()
            }
            
            self.isLoading = false
        }
    }
    
    func searchProducts(with text: String) {
        filterOptions.searchText = text
        applyFiltersAndSearch()
    }
    
    func applyFilter(_ options: FilterOptions) {
        filterOptions = options
        applyFiltersAndSearch()
    }
    
    private func applyFiltersAndSearch() {
        var products = allProducts
        
        // Apply search
        if !filterOptions.searchText.isEmpty {
            products = products.filter { product in
                product.name.contains(caseInsensitive: filterOptions.searchText) ||
                product.brand.contains(caseInsensitive: filterOptions.searchText) ||
                product.model.contains(caseInsensitive: filterOptions.searchText)
            }
        }
        
        // Apply brand filter
        if !filterOptions.selectedBrands.isEmpty {
            products = products.filter { filterOptions.selectedBrands.contains($0.brand) }
        }
        
        // Apply model filter
        if !filterOptions.selectedModels.isEmpty {
            products = products.filter { filterOptions.selectedModels.contains($0.model) }
        }
        
        // Apply sorting
        products = sortProducts(products, by: filterOptions.sortType)
        
        filteredProducts = products
        currentPage = 0
        
        let endIndex = min(itemsPerPage, filteredProducts.count)
        displayedProducts = Array(filteredProducts[0..<endIndex])
        
        delegate?.didUpdateProducts()
    }
    
    private func sortProducts(_ products: [Product], by sortType: SortType) -> [Product] {
        switch sortType {
        case .oldToNew:
            return products.sorted { $0.createdAt < $1.createdAt }
        case .newToOld:
            return products.sorted { $0.createdAt > $1.createdAt }
        case .priceHighToLow:
            return products.sorted { $0.priceValue > $1.priceValue }
        case .priceLowToHigh:
            return products.sorted { $0.priceValue < $1.priceValue }
        }
    }
    
    // MARK: - Getters
    func numberOfProducts() -> Int {
        return displayedProducts.count
    }
    
    func product(at index: Int) -> Product? {
        guard index < displayedProducts.count else { return nil }
        return displayedProducts[index]
    }
    
    func getAllBrands() -> [String] {
        return Array(Set(allProducts.map { $0.brand })).sorted()
    }
    
    func getAllModels() -> [String] {
        return Array(Set(allProducts.map { $0.model })).sorted()
    }
    
    func getCurrentFilterOptions() -> FilterOptions {
        return filterOptions
    }
    
    var hasMoreProducts: Bool {
        return displayedProducts.count < filteredProducts.count
    }
    
    var isEmpty: Bool {
        return displayedProducts.isEmpty && !isLoading
    }
}
