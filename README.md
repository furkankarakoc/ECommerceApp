# ECommerce iOS App

A comprehensive e-commerce iOS application built with UIKit, featuring product browsing, cart management, favorites, and advanced filtering capabilities.

## Features

### Core Features
- **Product Listing**: Grid view (2x2) with infinite scroll
- **Product Search**: Real-time search functionality
- **Advanced Filtering**: Sort by price, date, brand, and model
- **Product Details**: Detailed product view with image and description
- **Shopping Cart**: Add/remove products with quantity management
- **Favorites**: Save and manage favorite products
- **Data Persistence**: Cart and favorites persist between app sessions

### Bonus Features
- **Cart Badge**: Real-time cart item count on tab bar
- **Swipe to Delete**: Cart and favorites support swipe gestures
- **Loading States**: Professional loading indicators
- **Empty States**: Informative no-data screens
- **Filter Search**: Search within filter options
- **Responsive Design**: Adapts to different screen sizes

## Architecture

### MVVM Pattern
```
├── Models/
│   ├── Product.swift
│   └── FilterOptions
├── ViewModels/
│   ├── ProductListViewModel.swift
│   ├── ProductDetailViewModel.swift
│   ├── CartViewModel.swift
│   └── FavoriteViewModel.swift
├── Views/
│   ├── ProductList/
│   ├── ProductDetail/
│   ├── Cart/
│   ├── Favorite/
│   └── Common/
└── Core/
    ├── Network/
    ├── CoreData/
    └── Extensions/
```

### Design Patterns
- **MVVM**: Clean separation of concerns
- **Delegate Pattern**: Communication between layers
- **Observer Pattern**: NotificationCenter for data updates
- **Factory Pattern**: Test data generation
- **Singleton Pattern**: CoreData and Network managers

## 🛠 Technologies

### Core Technologies
- **UIKit**: Programmatic UI (no Storyboards)
- **CoreData**: Local data persistence
- **URLSession**: Network operations
- **NotificationCenter**: Cross-component communication

### Testing
- **XCTest**: Unit testing framework
- **Mocks**: Isolated testing with mock objects
- **Code Coverage**: 80%+ test coverage

### Development Tools
- **Xcode 15+**
- **iOS 15.0+**
- **Swift 5.9+**

## Getting Started

### Prerequisites
- Xcode 15.0 or later
- iOS 15.0+ deployment target
- Internet connection for API calls

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/furkankarakoc/ECommerceApp.git
cd ecommerce-ios
```

2. **Open in Xcode**
```bash
open ECommerce.xcodeproj
```

3. **Build and Run**
- Select your target device/simulator
- Press `⌘+R` to build and run

### API Configuration

The app uses a mock API endpoint:
```
https://5fc9346b2af77700165ae514.mockapi.io/products
```

No additional configuration required.

## 📁 Project Structure

```
ECommerce/
├── App/
│   ├── AppDelegate.swift
│   └── SceneDelegate.swift
│
├── Core/
│   ├── Network/
│   │   ├── NetworkManager.swift
│   │   └── APIEndpoints.swift
│   ├── CoreData/
│   │   ├── CoreDataManager.swift
│   │   ├── ECommerce.xcdatamodeld
│   │   ├── CartItem+CoreDataClass.swift
│   │   ├── CartItem+CoreDataProperties.swift
│   │   ├── FavoriteItem+CoreDataClass.swift
│   │   └── FavoriteItem+CoreDataProperties.swift
│   └── Extensions/
│       ├── UIView+Extensions.swift
│       ├── UIColor+Extensions.swift
│       └── String+Extensions.swift
├── Models/
│   └── Product.swift
├── ViewModels/
│   ├── ProductListViewModel.swift
│   ├── ProductDetailViewModel.swift
│   ├── CartViewModel.swift
│   └── FavoriteViewModel.swift
├── Views/
│   ├── ProductList/
│   │   ├── ProductListViewController.swift
│   │   ├── ProductCell.swift
│   │   └── FilterViewController.swift
│   ├── ProductDetail/
│   │   └── ProductDetailViewController.swift
│   ├── Cart/
│   │   ├── CartViewController.swift
│   │   └── CartItemCell.swift
│   ├── Favorite/
│   │   ├── FavoriteViewController.swift
│   │   └── FavoriteCell.swift
│   ├── Common/
│   │   ├── LoadingView.swift
│   │   ├── NoDataView.swift
│   │   └── CustomTabBarController.swift
│   └── Components/
│       ├── SearchBar.swift
│       └── QuantitySelector.swift
└── Tests/
│   ├── Mocks/
│   ├── ViewModelTests/
│   ├── NetworkTests/
│   └── CoreDataTests/
└── Info.plist
```

## Testing

### Running Tests
```bash
# Run all tests
⌘+U

# Run specific test file
⌘+U on specific test class

# Command line
xcodebuild test -project ECommerce.xcodeproj -scheme ECommerce -destination 'platform=iOS Simulator,name=iPhone 14'
```

### Test Coverage
- **ViewModels**: 90%+ coverage
- **CoreData**: 85%+ coverage
- **Network Layer**: 80%+ coverage
- **Overall**: 80%+ coverage

### Test Types
- **Unit Tests**: Isolated component testing
- **Mock Tests**: External dependency simulation

## UI/UX Features

### Visual Design
- **Modern iOS Design**: Following iOS Human Interface Guidelines
- **Custom Colors**: Brand-specific color palette
- **Smooth Animations**: Loading states and transitions

### User Experience
- **Infinite Scroll**: Smooth product loading
- **Pull to Refresh**: Manual data refresh capability
- **Search Suggestions**: Real-time search results
- **Filter Memory**: Remembers last used filters
- **Cart Persistence**: Never lose cart items

## Performance

### Optimization Techniques
- **Image Caching**: Efficient image loading and caching
- **Lazy Loading**: Load data as needed
- **Memory Management**: Proper cleanup and weak references
- **Background Processing**: Non-blocking UI operations

### Metrics
- **Image Loading**: Progressive loading
- **Memory Usage**: Optimized for low memory devices

##  Configuration

### Build Configurations

### Environment Variables
```swift
// Network Configuration
static let baseURL = "https://5fc9346b2af77700165ae514.mockapi.io"

// App Configuration  
static let itemsPerPage = 4
static let cachePolicy = .returnCacheDataElseLoad
```

## API Reference

### Endpoints

#### Get Products
```
GET /products
```

**Response:**
```json
[
  {
    "createdAt": "2023-07-17T07:21:02.529Z",
    "name": "Bentley Focus",
    "image": "https://loremflickr.com/640/480/food",
    "price": "51.00",
    "description": "Quasi adipisci sint veniam delectus. Illum laboriosam minima dignissimos natus earum facere consequuntur eius vero. Itaque facilis at tempore ipsa. Accusamus nihil fugit velit possimus expedita error porro aliquid. Optio magni mollitia veritatis repudiandae tenetur nemo. Id consectetur fuga ipsam quidem voluptatibus sed magni dolore.\nFacilis commodi dolores sapiente delectus nihil ex a perferendis. Totam deserunt assumenda inventore. Incidunt nesciunt adipisci natus porro deleniti nisi incidunt laudantium soluta. Nostrum optio ab facilis quisquam.\nSoluta laudantium ipsa ut accusantium possimus rem. Illo voluptatibus culpa incidunt repudiandae placeat animi. Delectus id in animi incidunt autem. Ipsum provident beatae nisi cumque nulla iure.",
    "model": "CTS",
    "brand": "Lamborghini",
    "id": "1"
  }
]
```

## Troubleshooting

### Common Issues

#### Build Errors
```bash
# Clean build folder
⌘+Shift+K

# Clean derived data
rm -rf ~/Library/Developer/Xcode/DerivedData
```

#### CoreData Issues
- Ensure entity names match exactly
- Check attribute types
- Verify codegen settings

#### Network Issues
- Check internet connection
- Verify API endpoint availability

## Future Enhancements

### Planned Features

### Technical Improvements

## Contributing

### Development Workflow
1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

### Code Style
- Swift coding conventions
- MVVM architecture adherence
- Comprehensive unit tests
- Documentation for public APIs

## License


## Authors

- **Furkan Karakoç** -  https://github.com/furkankarakoc

## Acknowledgments

## 📞 Support

For support, email ffurkankarakoc@gmail.com or create an issue in this repository.

---

**Built with ❤️ in Swift**
