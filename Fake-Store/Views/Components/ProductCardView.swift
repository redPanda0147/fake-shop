import SwiftUI

struct ProductCardView: View {
    let product: Product
    let isPurchased: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            imageSection
            contentSection
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
        .frame(maxWidth: .infinity, minHeight: 300)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(product.title), \(product.price.formatAsCurrency())")
        .accessibilityHint("Double tap to view product details")
    }
    
    @ViewBuilder
    private var imageSection: some View {
        ZStack(alignment: .topTrailing) {
            CachedImageView(url: product.images.first ?? "")
                .frame(height: 160)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .clipped()
            
            // Purchased badge overlay
            if isPurchased {
                PurchasedBadge()
                    .padding(8)
            }
        }
        .frame(height: 160)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .clipped()
    }
    
    @ViewBuilder
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            titleSection
            priceSection
            ratingAndCategorySection
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    @ViewBuilder
    private var titleSection: some View {
        Text(product.title)
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(.primary)
            .lineLimit(2)
            .minimumScaleFactor(0.7)
            .multilineTextAlignment(.leading)
            .frame(height: 40, alignment: .top)
            .fixedSize(horizontal: false, vertical: true)
    }
    
    @ViewBuilder
    private var priceSection: some View {
        Text(product.price.formatAsCurrency())
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(.blue)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .frame(height: 20, alignment: .top)
    }
    
    @ViewBuilder
    private var ratingAndCategorySection: some View {
        HStack(spacing: 8) {
            RatingView(rating: product.rating)
            Spacer()
            CategoryPill(name: product.category.category.displayName)
        }
        .frame(height: 20)
    }
}

struct CategoryPill: View {
    let name: String
    
    var body: some View {
        Text(name)
            .font(.system(size: 10, weight: .medium))
            .foregroundColor(.secondary)
            .lineLimit(1)
            .minimumScaleFactor(0.6)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(
                Capsule()
                    .fill(Color(.systemGray6))
            )
            .accessibilityLabel("Category: \(name)")
    }
}

struct PurchasedBadge: View {
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "checkmark.circle.fill")
                .font(.caption)
            Text("Purchased")
                .font(.caption.bold())
        }
        .foregroundColor(.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(Color.green)
        )
    }
}

struct CachedImageView: View {
    let url: String?
    @StateObject private var imageLoader = ImageLoader()
    @State private var isImageLoaded = false
    
    var body: some View {
        ZStack {
            if let image = imageLoader.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipped()
                    .onAppear {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isImageLoaded = true
                        }
                    }
                    .opacity(isImageLoaded ? 1.0 : 0.0)
            } else {
                ZStack {
                    Rectangle()
                        .fill(Color(.systemGray6))
                    
                    if imageLoader.isLoading {
                        ProgressView()
                            .tint(.blue)
                    } else {
                        VStack(spacing: 8) {
                            Image(systemName: "photo")
                                .font(.title2)
                                .foregroundColor(.secondary)
                            Text("No Image")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .onAppear {
            if let urlString = url {
                imageLoader.load(from: urlString)
            }
        }
        .onDisappear {
            imageLoader.cancel()
        }
    }
}

#Preview {
    let categoryResponse = CategoryResponse(id: 1, name: "Electronics", image: nil)
    
    let sampleProduct = Product(
        id: 1,
        title: "iPhone 13 Pro Max with Super Retina XDR Display",
        price: 1099.99,
        description: "The latest iPhone with amazing features and a beautiful design. It comes with the A15 Bionic chip.",
        category: categoryResponse,
        images: ["https://placeimg.com/640/480/tech"],
        rating: Rating(rate: 4.5, count: 120)
    )
    
    VStack(spacing: 16) {
        ProductCardView(product: sampleProduct, isPurchased: false)
        ProductCardView(product: sampleProduct, isPurchased: true)
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
