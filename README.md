# 🛍️ Fake Store - iOS E-commerce App

A modern SwiftUI-based iOS e-commerce application that displays products from a public API and simulates in-app purchases with StoreKit 2 integration.

## ✨ Features

- **📱 Product Catalog**: Browse products with pagination and smooth animations
- **🔍 Search & Filter**: Search products and filter by categories
- **🛒 In-App Purchases**: Simulated purchase flow with StoreKit 2
- **🎨 Modern UI**: Clean, responsive design with smooth transitions
- **🌙 Dark Mode**: Full support for iOS dark mode
- **♿ Accessibility**: VoiceOver and accessibility features
- **🔄 Pull to Refresh**: Native iOS pull-to-refresh functionality
- **📱 Responsive**: Optimized for iPhone and iPad

## 🏗️ Architecture

- **MVVM Pattern**: Clean separation of concerns
- **SwiftUI**: Modern declarative UI framework
- **Combine**: Reactive programming for data binding
- **Async/Await**: Modern concurrency for network operations

## 🛠️ Tech Stack

### Core Technologies
- **Swift 5.5+**
- **SwiftUI** - UI Framework
- **Combine** - Reactive Programming
- **StoreKit 2** - In-App Purchases

### Networking & Data
- **URLSession** - Network requests
- **JSONDecoder** - Data parsing
- **UserDefaults** - Local storage

### UI Components
- **LazyVGrid** - Efficient grid layouts
- **NavigationStack** - Modern navigation
- **AsyncImage** - Image loading
- **Custom Animations** - Smooth transitions

## 📁 Project Structure

```
📦 Fake-Store
├── 📁 Core
│   ├── NetworkService.swift      # API communication
│   ├── APIError.swift           # Error handling
│   └── PurchaseManager.swift    # StoreKit integration
│
├── 📁 Models
│   ├── Product.swift            # Product data model
│   └── PurchaseStatus.swift     # Purchase state management
│
├── 📁 ViewModels
│   ├── ProductListViewModel.swift    # Product list logic
│   └── ProductDetailViewModel.swift  # Product detail logic
│
├── 📁 Views
│   ├── 📁 Components
│   │   ├── ProductCardView.swift     # Product card component
│   │   ├── RatingView.swift          # Star rating display
│   │   ├── LoadingView.swift         # Loading indicators
│   │   └── PurchaseButtonView.swift  # Buy button component
│   ├── ProductListView.swift         # Main product list
│   └── ProductDetailView.swift       # Product details
│
├── 📁 Utils
│   ├── Extensions.swift         # SwiftUI extensions
│   ├── Constants.swift          # App constants
│   └── FontExtension.swift      # Custom fonts
│
└── 📁 Resources
    └── Fonts/                   # Custom Roboto fonts
```

## 🚀 Getting Started

### Prerequisites
- Xcode 15.0+
- iOS 17.0+
- Swift 5.5+

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/Fake-Store.git
   cd Fake-Store
   ```

2. **Open in Xcode**
   ```bash
   open Fake-Store.xcodeproj
   ```

3. **Build and Run**
   - Select your target device/simulator
   - Press `Cmd + R` to build and run

## 🔧 Configuration

### API Configuration
The app uses the [Fake Store API](https://api.escuelajs.co/api/v1) for product data:
- Base URL: `https://api.escuelajs.co/api/v1`
- Endpoints: `/products`, `/categories`
- No API key required

### StoreKit Configuration
- Simulated in-app purchases
- Product IDs: `com.fakeshop.product1`, `com.fakeshop.product2`
- Purchase state persisted in UserDefaults

## 🎯 Key Features Implementation

### Product Listing
- **Pagination**: Loads 10 products per page
- **Lazy Loading**: Efficient memory usage
- **Category Filtering**: API-level filtering
- **Search**: Real-time search with debouncing

### In-App Purchases
- **StoreKit 2**: Modern purchase flow
- **Purchase State**: Persistent across app launches
- **Success Feedback**: Animated confirmation
- **Error Handling**: Graceful failure handling

### UI/UX
- **Responsive Design**: Adapts to different screen sizes
- **Smooth Animations**: Spring animations and transitions
- **Loading States**: Professional loading indicators
- **Error States**: User-friendly error messages

## 🔍 Code Quality

- **Clean Architecture**: MVVM pattern
- **Error Handling**: Comprehensive error management
- **Accessibility**: VoiceOver support
- **Performance**: Optimized for smooth scrolling
- **Memory Management**: Proper resource cleanup

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📞 Support

If you have any questions or need help, please open an issue on GitHub.

---

**Built with ❤️ using SwiftUI and modern iOS development practices** 
