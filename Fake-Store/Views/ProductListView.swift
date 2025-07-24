import SwiftUI

struct ProductListView: View {
    @StateObject private var viewModel = ProductListViewModel()
    @State private var searchText = ""
    @State private var showingFilters = false
    @State private var scrollToTop = false
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @EnvironmentObject private var purchaseManager: PurchaseManager
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                AppColor.background.ignoresSafeArea()
                
                // Main content
                VStack(spacing: 0) {
                    categoryFilterSection
                    productListSection
                }
                
                // Overlay views
                overlayViews
            }
            .navigationTitle("Fake Store")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search products")
            .onChange(of: searchText) { newValue in
                viewModel.searchText = newValue
            }
            .onChange(of: viewModel.selectedCategory) { _ in
                searchText = ""
            }
            .toolbar(content: toolbarContent)
            .sheet(isPresented: $showingFilters) {
                FilterSheetView(
                    selectedCategory: $viewModel.selectedCategory,
                    categories: viewModel.categories,
                    onDismiss: {
                        showingFilters = false
                        if let selectedCategory = viewModel.selectedCategory {
                            viewModel.filterByCategory(selectedCategory)
                        } else {
                            viewModel.filterByCategory(nil)
                        }
                        scrollToTop = true
                    }
                )
            }
            .onAppear {
                Task {
                    await viewModel.loadCategories()
                    await purchaseManager.refreshPurchaseState()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                Task {
                    await purchaseManager.refreshPurchaseState()
                }
            }
            .onReceive(purchaseManager.$purchasedProductIDs) { _ in
                // This will trigger a view update when purchase state changes
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                Task {
                    await purchaseManager.refreshPurchaseState()
                }
            }
        }
    }
    
    // MARK: - Helper Views
    
    @ViewBuilder
    private var categoryFilterSection: some View {
        ScrollViewReader { filterScrollProxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    CategoryFilterButton(
                        title: "All",
                        isSelected: viewModel.selectedCategory == nil,
                        action: {
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                            viewModel.filterByCategory(nil)
                            scrollToTop = true
                        }
                    )
                    .id("filter-all")

                    ForEach(viewModel.categories, id: \.id) { category in
                        CategoryFilterButton(
                            title: category.name,
                            isSelected: viewModel.selectedCategory?.id == category.id,
                            action: {
                                let generator = UIImpactFeedbackGenerator(style: .light)
                                generator.impactOccurred()
                                viewModel.filterByCategory(category)
                                scrollToTop = true
                            }
                        )
                        .id("filter-\(category.id)")
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .padding(.horizontal, 8)
                .onChange(of: viewModel.selectedCategory) { category in
                    withAnimation(.easeInOut(duration: 0.3)) {
                        if let category = category {
                            filterScrollProxy.scrollTo("filter-\(category.id)", anchor: .center)
                        } else {
                            filterScrollProxy.scrollTo("filter-all", anchor: .center)
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var productListSection: some View {
        ScrollViewReader { scrollProxy in
            ScrollView {
                LazyVStack(spacing: 0) {
                    Color.clear
                        .frame(height: 1)
                        .id("topAnchor")
                    
                    productGridView
                }
                .frame(maxWidth: .infinity)
            }
            .coordinateSpace(name: "scrollView")
            .onChange(of: scrollToTop) { shouldScroll in
                if shouldScroll {
                    withAnimation {
                        scrollProxy.scrollTo("topAnchor", anchor: .top)
                    }
                    scrollToTop = false
                }
            }
            .onChange(of: viewModel.selectedCategory) { _ in
                searchText = ""
            }
            .refreshable {
                await viewModel.refreshData()
            }
        }
    }
    
    @ViewBuilder
    private var productGridView: some View {
        VStack(spacing: 0) {
            LazyVGrid(columns: gridColumns, spacing: gridSpacing) {
                ForEach(filteredProducts) { product in
                    NavigationLink(destination: ProductDetailView(product: product)) {
                        ProductCardView(
                            product: product,
                            isPurchased: purchaseManager.isPurchased(product.id)
                        )
                        .frame(maxWidth: .infinity, minHeight: 280, maxHeight: 340)
                        .onAppear {
                            let currentIndex = viewModel.products.firstIndex(of: product) ?? 0
                            if currentIndex > viewModel.products.count - 10 && !viewModel.isLoading {
                                Task {
                                    await viewModel.loadMoreProductsIfNeeded(currentIndex: currentIndex)
                                }
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            
            loadingIndicatorsView
        }
        .padding(.vertical, 6)
        .frame(maxWidth: .infinity)
        .id("productGrid-\(viewModel.selectedCategory?.category.displayName ?? "all")-\(searchText)")
    }
    
    @ViewBuilder
    private var loadingIndicatorsView: some View {
        if viewModel.isLoading && !viewModel.products.isEmpty {
            FooterLoadingView()
                .padding(.top, 10)
        }
        
        if viewModel.isLoading && viewModel.products.isEmpty && viewModel.selectedCategory != nil {
            LoadingView(message: "Loading \(viewModel.selectedCategory?.name ?? "") products...")
                .padding(.top, 20)
        }
    }
    
    @ViewBuilder
    private var overlayViews: some View {
        if viewModel.hasError {
            ErrorView(error: viewModel.error?.message ?? "Unknown error", retryAction: {
                Task {
                    await viewModel.refreshData()
                }
            })
        }
        
        if !viewModel.isLoading && filteredProducts.isEmpty && !viewModel.hasError {
            EmptyStateView(
                title: "No Products Found",
                message: emptyStateMessage,
                systemImage: "magnifyingglass"
            )
        }
        
        if viewModel.isLoading && viewModel.products.isEmpty {
            LoadingView(message: "Loading Products...", isFullScreen: true)
        }
    }
    
    // MARK: - Computed Properties
    
    // Adjust grid columns based on dynamic type size
    private var gridColumns: [GridItem] {
        return Array(
            repeating: GridItem(.flexible(), spacing: gridSpacing),
            count: dynamicTypeSize >= .accessibility1 ? 1 : 2
        )
    }
    
    // Optimized spacing between grid items for shadow visibility
    private var gridSpacing: CGFloat {
        return 12
    }
    
    private var filteredProducts: [Product] {
        return viewModel.getFilteredProducts(searchText: searchText)
    }
    
    private var emptyStateMessage: String {
        if viewModel.selectedCategory != nil {
            return "No products found in \(viewModel.selectedCategory?.name ?? "") category"
        } else {
            return "Try changing your search or filters"
        }
    }
    
    @ToolbarContentBuilder
    private func toolbarContent() -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            HStack(spacing: 12) {
                Button(action: {
                    Task {
                        await purchaseManager.refreshPurchaseState()
                        await viewModel.refreshData()
                    }
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                }) {
                    Label("Refresh", systemImage: "arrow.clockwise")
                        .symbolRenderingMode(.hierarchical)
                        .font(.title3)
                        .imageScale(.large)
                        .foregroundColor(AppColor.primary)
                }
                .accessibilityLabel("Refresh products and purchase state")
                
                Button(action: {
                    showingFilters.toggle()
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                }) {
                    Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                        .symbolRenderingMode(.hierarchical)
                        .font(.title3)
                        .imageScale(.large)
                        .foregroundColor(AppColor.primary)
                }
                .accessibilityLabel("Filter products")
            }
        }
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}



struct CategoryFilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: isSelected ? .semibold : .medium))
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    ZStack {
                        if isSelected {
                            Capsule()
                                .fill(Color.accentColor)
                                .shadow(color: Color.accentColor.opacity(0.25), radius: 6, x: 0, y: 2)
                        } else {
                            Capsule()
                                .fill(Color(UIColor.systemGray5))
                                .overlay(
                                    Capsule()
                                        .stroke(Color.accentColor.opacity(0.3), lineWidth: 1)
                                )
                        }
                    }
                )
                .scaleEffect(isSelected ? 1.08 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("\(title)\(isSelected ? ", selected" : "")")
    }
}

struct ErrorView: View {
    let error: String
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.red)
            
            Text("Oops! Something went wrong")
                .font(.title3)
                .foregroundColor(Color(UIColor.label))
            
            Text(error)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(Color(UIColor.secondaryLabel))
            
            Button(action: retryAction) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Try Again")
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
        }
        .padding()
        .frame(maxWidth: 300)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: .black.opacity(0.15), radius: 15, x: 0, y: 8)
        )
    }
}

struct EmptyStateView: View {
    let title: String
    let message: String
    let systemImage: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: systemImage)
                .font(.system(size: 50))
                .foregroundColor(Color(UIColor.secondaryLabel))
            
            Text(title)
                .font(.title3)
                .foregroundColor(Color(UIColor.label))
            
            Text(message)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(Color(UIColor.secondaryLabel))
        }
        .padding()
        .frame(maxWidth: 300)
    }
}

struct FilterSheetView: View {
    @Binding var selectedCategory: CategoryResponse?
    let categories: [CategoryResponse]
    let onDismiss: () -> Void
    
    var body: some View {
        NavigationView {
            List {
                Section("Categories") {
                    Button(action: {
                        selectedCategory = nil
                        onDismiss()
                    }) {
                        HStack {
                            Text("All Categories")
                                .foregroundColor(Color(UIColor.label))
                            Spacer()
                            if selectedCategory == nil {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    
                    ForEach(categories, id: \.id) { category in
                        Button(action: {
                            selectedCategory = category
                            onDismiss()
                        }) {
                            HStack {
                                Text(category.name)
                                    .foregroundColor(Color(UIColor.label))
                                Spacer()
                                if selectedCategory?.id == category.id {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Filter Products")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onDismiss()
                    }
                    .foregroundColor(.blue)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    ProductListView()
}
