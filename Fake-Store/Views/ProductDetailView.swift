import SwiftUI

struct ProductDetailView: View {
    @StateObject private var viewModel: ProductDetailViewModel
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @State private var selectedImageIndex = 0
    @State private var showPurchaseConfirmation = false
    @State private var showFullScreenImages = false
    private let productIdToLoad: Int?
    
    init(product: Product? = nil, productId: Int? = nil) {
        _viewModel = StateObject(wrappedValue: ProductDetailViewModel(product: product))
        self.productIdToLoad = productId
    }
    
    private func createViewModel(for product: Product) -> ProductDetailViewModel {
        return ProductDetailViewModel(product: product, purchaseManager: purchaseManager)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Product images carousel
                if let product = viewModel.product {
                    imageCarousel(for: product)
                    
                    // Product info
                    VStack(alignment: .leading, spacing: 16) {
                        // Title and price
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(product.title)
                                    .font(AppFont.title2)
                                    .foregroundColor(AppColor.text)
                                
                                if let rating = product.rating {
                                    RatingView(rating: rating)
                                }
                            }
                            
                            Spacer()
                            
                            Text(product.price.formatAsCurrency())
                                .font(AppFont.title)
                                .foregroundColor(AppColor.primary)
                        }
                        
                        // Category
                        CategoryPill(name: product.category.category.displayName)
                        
                        Divider()
                        
                        // Description
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(AppFont.headline)
                                .foregroundColor(AppColor.text)
                            
                            Text(product.description)
                                .font(AppFont.body)
                                .foregroundColor(AppColor.secondaryText)
                                .fixedSize(horizontal: false, vertical: true)
                                .lineSpacing(4)
                        }
                        
                        Divider()
                        
                        // Reviews section
                        if let rating = product.rating {
                            reviewsSection(rating: rating)
                        }
                        
                        Spacer(minLength: 30)
                        
                        // Purchase button
                        PurchaseButtonView(
                            product: product,
                            isPurchased: viewModel.isPurchased
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }
                    .padding()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert("Purchase Successful", isPresented: $showPurchaseConfirmation) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Thank you for your purchase!")
        }
        .overlay {
            if viewModel.isLoading {
                LoadingView(message: "Loading Product...", isFullScreen: true)
            }
            
            if viewModel.hasError {
                ErrorView(error: viewModel.error?.message ?? "Unknown error") {
                    if let product = viewModel.product {
                        Task {
                            await viewModel.loadProduct(id: product.id)
                        }
                    } else {
                        dismiss()
                    }
                }
            }
        }
        .task {
            if let productId = productIdToLoad {
                await viewModel.loadProduct(id: productId)
            }
        }
        .fullScreenCover(isPresented: $showFullScreenImages) {
            if let product = viewModel.product {
                FullScreenImageViewer(
                    images: product.images,
                    initialIndex: selectedImageIndex,
                    isPresented: $showFullScreenImages
                )
            }
        }
    }
    
    @ViewBuilder
    private func imageCarousel(for product: Product) -> some View {
        if product.images.isEmpty {
            defaultProductImage()
                .frame(height: 300)
        } else {
            TabView(selection: $selectedImageIndex) {
                ForEach(Array(product.images.enumerated()), id: \.offset) { index, imageUrl in
                    ZStack {
                        CachedImageView(url: imageUrl)
                            .aspectRatio(contentMode: .fill)
                            .clipped()
                        
                        // Invisible tap area for full screen
                        Rectangle()
                            .fill(Color.clear)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                // Add haptic feedback for image tap
                                let generator = UIImpactFeedbackGenerator(style: .light)
                                generator.impactOccurred()
                                
                                showFullScreenImages = true
                            }
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
            .frame(height: 300)
            .animation(.easeInOut, value: selectedImageIndex)
            .overlay(alignment: .topTrailing) {
                if viewModel.isPurchased {
                    PurchasedBadge()
                        .padding()
                }
            }
        }
    }
    
    @ViewBuilder
    private func reviewsSection(rating: Rating) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section header
            HStack {
                Text("Customer Reviews")
                    .font(AppFont.headline)
                    .foregroundColor(AppColor.text)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Text(String(format: "%.1f", rating.rate))
                        .font(AppFont.headline)
                        .foregroundColor(AppColor.text)
                    
                    Text("(\(rating.count))")
                        .font(AppFont.subheadline)
                        .foregroundColor(AppColor.secondaryText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
            }
            
            // Large rating display
            HStack(spacing: 8) {
                ForEach(0..<5) { index in
                    Image(systemName: starImageName(for: index, rating: rating.rate))
                        .font(.title3)
                        .foregroundColor(.yellow)
                }
            }
            
            // Sample reviews
            ForEach(generateSampleReviews(count: min(3, rating.count / 30)), id: \.id) { review in
                ReviewRow(review: review)
            }
            
            // Show all reviews button
            Button(action: {
                // This would navigate to a full reviews page in a real app
            }) {
                Text("See all \(rating.count) reviews")
                    .font(AppFont.subheadline)
                    .foregroundColor(AppColor.primary)
                    .padding(.vertical, 8)
            }
        }
    }
    
    private func starImageName(for index: Int, rating: Double) -> String {
        if index < Int(rating) {
            return "star.fill"
        } else if index < Int(rating) + 1 && rating.truncatingRemainder(dividingBy: 1) > 0 {
            return "star.leadinghalf.filled"
        } else {
            return "star"
        }
    }
    
    private func generateSampleReviews(count: Int) -> [Review] {
        let reviewers = ["Alex", "Jamie", "Taylor", "Jordan", "Casey", "Morgan", "Riley", "Sam"]
        let comments = [
            "Great product, exactly as described!",
            "Very satisfied with my purchase. Would buy again.",
            "Good quality for the price. Fast shipping too.",
            "Love it! Exceeded my expectations.",
            "Pretty good overall, but could be better in some aspects.",
            "Decent product, works as expected.",
            "Amazing value for money. Highly recommend!",
            "Solid product, no complaints."
        ]
        
        var reviews = [Review]()
        
        for i in 0..<count {
            let randomReviewer = reviewers[Int.random(in: 0..<reviewers.count)]
            let randomComment = comments[Int.random(in: 0..<comments.count)]
            let randomRating = Double.random(in: 3.0...5.0).rounded(toPlaces: 1)
            let randomDate = Date().addingTimeInterval(-Double.random(in: 86400...2592000)) // 1-30 days ago
            
            reviews.append(Review(
                id: i,
                reviewer: randomReviewer,
                rating: randomRating,
                comment: randomComment,
                date: randomDate
            ))
        }
        
        return reviews
    }
    
    private func defaultProductImage() -> some View {
        ZStack {
            Rectangle()
                .fill(Color(AppColor.secondaryBackground))
            
            Image(systemName: "photo")
                .font(.system(size: 70))
                .foregroundColor(AppColor.tertiaryText)
        }
    }
}

struct Review: Identifiable {
    let id: Int
    let reviewer: String
    let rating: Double
    let comment: String
    let date: Date
}

struct ReviewRow: View {
    let review: Review
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(review.reviewer)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(AppColor.text)
                
                Spacer()
                
                Text(review.date, style: .date)
                    .font(AppFont.caption)
                    .foregroundColor(AppColor.tertiaryText)
            }
            
            HStack(spacing: 4) {
                ForEach(0..<5) { index in
                    Image(systemName: starImageName(for: index, rating: review.rating))
                        .font(.caption)
                        .foregroundColor(.yellow)
                }
            }
            
            Text(review.comment)
                .font(AppFont.callout)
                .foregroundColor(AppColor.secondaryText)
            
            Divider()
                .padding(.top, 4)
        }
        .padding(.vertical, 4)
    }
    
    private func starImageName(for index: Int, rating: Double) -> String {
        if index < Int(rating) {
            return "star.fill"
        } else if index < Int(rating) + 1 && rating.truncatingRemainder(dividingBy: 1) > 0 {
            return "star.leadinghalf.filled"
        } else {
            return "star"
        }
    }
}

#Preview {
    NavigationStack {
        let categoryResponse = CategoryResponse(id: 1, name: "Electronics", image: nil)
        
        ProductDetailView(product: Product(
            id: 1,
            title: "iPhone 13 Pro Max",
            price: 1099.99,
            description: "The latest iPhone with amazing features and a beautiful design. It comes with the A15 Bionic chip, a Pro camera system, and a Super Retina XDR display with ProMotion.",
            category: categoryResponse,
            images: ["https://placeimg.com/640/480/tech", "https://placeimg.com/640/480/tech/2"],
            rating: Rating(rate: 4.5, count: 120)
        ))
    }
} 
