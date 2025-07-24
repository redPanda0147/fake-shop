import Foundation
import Combine

@MainActor
class ProductListViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var isLoading = false
    @Published var error: APIError?
    @Published var hasError = false
    @Published var selectedCategory: CategoryResponse?
    @Published var categories: [CategoryResponse] = []
    @Published var searchText: String = ""
    
    private var currentPage = 0
    private let pageSize = 10
    private var canLoadMorePages = true
    private var categoryIdForAPI: Int? = nil
    private var refreshTask: Task<Void, Never>? = nil
    private var loadMoreTask: Task<Void, Never>? = nil
    private var isLoadingMore = false
    private var loadMoreDebounceTask: Task<Void, Never>? = nil
    
    init() {
        Task {
            await loadInitialData()
        }
    }
    
    func loadInitialData() async {
        await fetchCategories()
        await loadMoreProductsIfNeeded(currentIndex: 0)
    }
    
    func fetchCategories() async {
        // Load categories from API instead of using hardcoded ones
        await loadCategories()
    }
    
    func loadMoreProductsIfNeeded(currentIndex: Int) async {
        // Don't trigger loading if we're already loading or refreshing
        guard !isLoading && !isLoadingMore else { return }
        
        // Cancel any existing debounce task
        loadMoreDebounceTask?.cancel()
        
        // Create a new debounce task
        loadMoreDebounceTask = Task {
            do {
                // Add a small delay to debounce multiple calls
                try await Task.sleep(nanoseconds: 200_000_000) // 200ms
                
                guard !Task.isCancelled else { return }
                
                guard currentIndex > 0 else {
                    // First load
                    await loadMoreProducts()
                    return
                }
                
                let thresholdIndex = products.count - 5
                if currentIndex >= thresholdIndex && !isLoading && canLoadMorePages {
                    await loadMoreProducts()
                }
            } catch {
                // Task was cancelled, do nothing
            }
        }
    }
    
    private func loadMoreProducts() async {
        // Cancel any previous load more task
        loadMoreTask?.cancel()
        
        // Prevent multiple simultaneous calls
        guard !isLoading && !isLoadingMore && canLoadMorePages else { return }
        
        // Create a new load more task
        isLoadingMore = true
        
        loadMoreTask = Task {
            guard !Task.isCancelled else {
                isLoadingMore = false
                return
            }
            
            isLoading = true
            hasError = false
            
            do {
                // Add a small delay to prevent rapid successive API calls
                try await Task.sleep(nanoseconds: 300_000_000) // 300ms
                
                guard !Task.isCancelled else {
                    isLoading = false
                    isLoadingMore = false
                    return
                }
                
                let offset = currentPage * pageSize
                let newProducts = try await NetworkService.shared.fetchProducts(
                    limit: pageSize,
                    skip: offset,
                    categoryId: categoryIdForAPI
                )
                
                if !Task.isCancelled {
                    if currentPage == 0 {
                        // First page - replace all products
                        self.products = newProducts
                    } else {
                        // Subsequent pages - append products
                        self.products.append(contentsOf: newProducts)
                    }
                    
                    currentPage += 1
                    canLoadMorePages = newProducts.count == pageSize
                }
                
                isLoading = false
                isLoadingMore = false
            } catch let apiError as APIError {
                if !Task.isCancelled {
                    isLoading = false
                    isLoadingMore = false
                    self.error = apiError
                    hasError = true
                }
            } catch {
                if !Task.isCancelled {
                    isLoading = false
                    isLoadingMore = false
                    self.error = APIError.unknown
                    hasError = true
                }
            }
        }
        
        // Wait for the task to complete
        await loadMoreTask?.value
    }
    
    @MainActor
    func refreshData() async {
        // Cancel any ongoing tasks
        refreshTask?.cancel()
        loadMoreTask?.cancel()
        loadMoreDebounceTask?.cancel()
        
        products = []
        currentPage = 0
        canLoadMorePages = true
        isLoadingMore = false
        
        // Set the category ID for API filtering based on selected category
        categoryIdForAPI = selectedCategory?.id
        
        // Trigger immediate data load
        await loadMoreProducts()
    }
    
    @MainActor
    func loadCategories() async {
        do {
            let fetchedCategories = try await NetworkService.shared.fetchCategories()
            // Filter out categories with invalid names and sort them
            self.categories = fetchedCategories
                .filter { !$0.name.isEmpty && $0.name != "string" && !$0.name.contains("category_") }
                .sorted { $0.name < $1.name }
        } catch {
            print("Failed to load categories: \(error)")
            // Set default categories if API fails
            self.categories = []
        }
    }
    
    private func isRefreshing() -> Bool {
        // Check if a refresh is currently in progress
        guard let refreshTask = refreshTask else { return false }
        return !refreshTask.isCancelled
    }
    
    func filterByCategory(_ categoryResponse: CategoryResponse?) {
        // Cancel any ongoing tasks
        refreshTask?.cancel()
        loadMoreTask?.cancel()
        loadMoreDebounceTask?.cancel()
        
        selectedCategory = categoryResponse
        products = []
        currentPage = 0
        canLoadMorePages = true
        isLoadingMore = false
        
        // Set the category ID for API filtering
        categoryIdForAPI = categoryResponse?.id
        
        // Reset search text when changing category
        self.searchText = ""
        
        // Trigger immediate data load
        Task {
            await loadMoreProducts()
        }
    }
    
    // Helper method to check if a product matches the selected category
    func productMatchesSelectedCategory(_ product: Product) -> Bool {
        guard let selectedCategory = selectedCategory else {
            return true // No category filter
        }
        
        // Compare the category IDs directly
        return product.category.id == selectedCategory.id
    }
    
    // Get filtered products based on category and search text
    func getFilteredProducts(searchText: String) -> [Product] {
        // Since we're already filtering by category at the API level,
        // we only need to filter by search text
        if searchText.isEmpty {
            return products
        } else {
            return products.filter { product in
                product.title.lowercased().contains(searchText.lowercased()) ||
                product.description.lowercased().contains(searchText.lowercased()) ||
                product.category.name.lowercased().contains(searchText.lowercased())
            }
        }
    }
} 
