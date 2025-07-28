//
//  FilterViewController.swift
//  ECommerce
//
//  Created by furkankarakoc on 27.07.2025.
//

import Foundation
import UIKit

protocol FilterViewControllerDelegate: AnyObject {
    func didApplyFilter(_ options: FilterOptions)
}

class FilterViewController: UIViewController {
    
    // MARK: - Properties
    weak var delegate: FilterViewControllerDelegate?
    var currentFilterOptions = FilterOptions()
    var availableBrands: [String] = []
    var availableModels: [String] = []
    
    private var selectedSortType: SortType = .oldToNew
    private var selectedBrands: Set<String> = []
    private var selectedModels: Set<String> = []
    
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
    
    private let sortLabel: UILabel = {
        let label = UILabel()
        label.text = "Sort By"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let sortStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let brandLabel: UILabel = {
        let label = UILabel()
        label.text = "Brand"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let brandSearchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search"
        searchBar.searchBarStyle = .minimal
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    private let brandStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let modelLabel: UILabel = {
        let label = UILabel()
        label.text = "Model"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let modelSearchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search"
        searchBar.searchBarStyle = .minimal
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    private let modelStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let primaryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Apply", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .primaryBlue
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addCornerRadius(8)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var filteredBrands: [String] = []
    private var filteredModels: [String] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCurrentValues()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .white
        title = "Filter"
        
        // Navigation items
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(closeButtonTapped)
        )
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubviews(
            sortLabel, sortStackView,
            brandLabel, brandSearchBar, brandStackView,
            modelLabel, modelSearchBar, modelStackView,
            primaryButton
        )
        
        setupConstraints()
        setupSortOptions()
        setupBrandOptions()
        setupModelOptions()
        setupTargets()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Scroll View
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content View
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Sort Label
            sortLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            sortLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            sortLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Sort Stack View
            sortStackView.topAnchor.constraint(equalTo: sortLabel.bottomAnchor, constant: 16),
            sortStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            sortStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Brand Label
            brandLabel.topAnchor.constraint(equalTo: sortStackView.bottomAnchor, constant: 32),
            brandLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            brandLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Brand Search Bar
            brandSearchBar.topAnchor.constraint(equalTo: brandLabel.bottomAnchor, constant: 8),
            brandSearchBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            brandSearchBar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            brandSearchBar.heightAnchor.constraint(equalToConstant: 44),
            
            // Brand Stack View
            brandStackView.topAnchor.constraint(equalTo: brandSearchBar.bottomAnchor, constant: 8),
            brandStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            brandStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Model Label
            modelLabel.topAnchor.constraint(equalTo: brandStackView.bottomAnchor, constant: 32),
            modelLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            modelLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Model Search Bar
            modelSearchBar.topAnchor.constraint(equalTo: modelLabel.bottomAnchor, constant: 8),
            modelSearchBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            modelSearchBar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            modelSearchBar.heightAnchor.constraint(equalToConstant: 44),
            
            // Model Stack View
            modelStackView.topAnchor.constraint(equalTo: modelSearchBar.bottomAnchor, constant: 8),
            modelStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            modelStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Primary Button
            primaryButton.topAnchor.constraint(equalTo: modelStackView.bottomAnchor, constant: 32),
            primaryButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            primaryButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            primaryButton.heightAnchor.constraint(equalToConstant: 48),
            primaryButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupSortOptions() {
        for sortType in SortType.allCases {
            let radioButton = createRadioButton(title: sortType.displayName, tag: sortType.hashValue)
            sortStackView.addArrangedSubview(radioButton)
        }
    }
    
    private func setupBrandOptions() {
        filteredBrands = availableBrands
        updateBrandList()
    }
    
    private func setupModelOptions() {
        filteredModels = availableModels
        updateModelList()
    }
    
    private func setupTargets() {
        primaryButton.addTarget(self, action: #selector(primaryButtonTapped), for: .touchUpInside)
        brandSearchBar.delegate = self
        modelSearchBar.delegate = self
    }
    
    private func setupCurrentValues() {
        selectedSortType = currentFilterOptions.sortType
        selectedBrands = currentFilterOptions.selectedBrands
        selectedModels = currentFilterOptions.selectedModels
        
        // Update radio buttons
        for view in sortStackView.arrangedSubviews {
            if let button = view as? UIButton {
                let sortType = SortType.allCases.first { $0.hashValue == button.tag }
                button.isSelected = sortType == selectedSortType
                // Background color güncelle
                button.backgroundColor = button.isSelected ? .primaryBlue : .lightGray
                button.setTitleColor(button.isSelected ? .white : .black, for: .normal)
            }
        }
    }
    
    private func createRadioButton(title: String, tag: Int) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.white, for: .selected)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.contentHorizontalAlignment = .left
        button.tag = tag
        button.addTarget(self, action: #selector(sortOptionTapped(_:)), for: .touchUpInside)
        
        // Background color ayarları
        button.backgroundColor = .lightGray
        button.addCornerRadius(6)
        
        // Padding ekle
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        
        return button
    }
    
    private func createCheckbox(title: String, isSelected: Bool, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.white, for: .selected)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.contentHorizontalAlignment = .left
        button.isSelected = isSelected
        
        // Background color ayarları
        button.backgroundColor = isSelected ? .primaryBlue : .lightGray
        button.addCornerRadius(6)
        
        // Padding ekle
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        
        button.addTarget(self, action: action, for: .touchUpInside)
        
        return button
    }
    
    private func updateBrandList() {
        brandStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for brand in filteredBrands {
            let checkbox = createCheckbox(
                title: brand,
                isSelected: selectedBrands.contains(brand),
                action: #selector(brandCheckboxTapped(_:))
            )
            brandStackView.addArrangedSubview(checkbox)
        }
    }
    
    private func updateModelList() {
        modelStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for model in filteredModels {
            let checkbox = createCheckbox(
                title: model,
                isSelected: selectedModels.contains(model),
                action: #selector(modelCheckboxTapped(_:))
            )
            modelStackView.addArrangedSubview(checkbox)
        }
    }
    
    
    // MARK: - Actions
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func sortOptionTapped(_ sender: UIButton) {
        // Deselect all other radio buttons
        for view in sortStackView.arrangedSubviews {
            if let button = view as? UIButton {
                button.isSelected = (button == sender)
                // Background color güncelle
                button.backgroundColor = button.isSelected ? .primaryBlue : .lightGray
                button.setTitleColor(button.isSelected ? .white : .black, for: .normal)
            }
        }
        
        // Update selected sort type
        if let sortType = SortType.allCases.first(where: { $0.hashValue == sender.tag }) {
            selectedSortType = sortType
        }
    }
    
    @objc private func brandCheckboxTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
        
        // Background color güncelle
        sender.backgroundColor = sender.isSelected ? .primaryBlue : .lightGray
        sender.setTitleColor(sender.isSelected ? .white : .black, for: .normal)
        
        let brandTitle = sender.title(for: .normal) ?? ""
        if sender.isSelected {
            selectedBrands.insert(brandTitle)
        } else {
            selectedBrands.remove(brandTitle)
        }
    }
    
    @objc private func modelCheckboxTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
        
        // Background color güncelle
        sender.backgroundColor = sender.isSelected ? .primaryBlue : .lightGray
        sender.setTitleColor(sender.isSelected ? .white : .black, for: .normal)
        
        let modelTitle = sender.title(for: .normal) ?? ""
        if sender.isSelected {
            selectedModels.insert(modelTitle)
        } else {
            selectedModels.remove(modelTitle)
        }
    }
    
    @objc private func primaryButtonTapped() {
        var filterOptions = FilterOptions()
        filterOptions.sortType = selectedSortType
        filterOptions.selectedBrands = selectedBrands
        filterOptions.selectedModels = selectedModels
        filterOptions.searchText = currentFilterOptions.searchText
        
        delegate?.didApplyFilter(filterOptions)
        dismiss(animated: true)
    }
}

// MARK: - UISearchBarDelegate
extension FilterViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar == brandSearchBar {
            if searchText.isEmpty {
                filteredBrands = availableBrands
            } else {
                filteredBrands = availableBrands.filter { $0.contains(caseInsensitive: searchText) }
            }
            updateBrandList()
        } else if searchBar == modelSearchBar {
            if searchText.isEmpty {
                filteredModels = availableModels
            } else {
                filteredModels = availableModels.filter { $0.contains(caseInsensitive: searchText) }
            }
            updateModelList()
        }
    }
}
