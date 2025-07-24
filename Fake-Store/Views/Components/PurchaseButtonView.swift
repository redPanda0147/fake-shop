import SwiftUI

struct PurchaseButtonView: View {
    let product: Product
    let isPurchased: Bool
    
    @StateObject private var purchaseManager = PurchaseManager.shared
    @State private var isPressed = false
    @State private var showingSuccessAlert = false
    
    private var isPurchasing: Bool {
        purchaseManager.purchaseStatus == .purchasing
    }
    
    var body: some View {
        Button(action: handlePurchase) {
            HStack(spacing: 8) {
                // Icon
                Image(systemName: buttonIcon)
                    .font(.system(size: 16, weight: .semibold))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundColor(buttonTextColor)
                
                // Text
                Text(buttonText)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(buttonTextColor)
                
                // Price (only show when not purchased/purchasing)
                if !isPurchased && !isPurchasing {
                    Text(product.price.formatAsCurrency())
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(buttonTextColor)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(
                LinearGradient(
                    colors: buttonGradientColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(
                color: buttonShadowColor,
                radius: 6,
                x: 0,
                y: 3
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(buttonStrokeColor, lineWidth: 1)
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
            .accessibilityLabel(accessibilityLabel)
            .accessibilityHint(accessibilityHint)
        }
        .disabled(isPurchased || isPurchasing)
        .alert("Purchase Successful", isPresented: $showingSuccessAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Thank you for your purchase! Your product has been unlocked.")
        }
    }
    
    private var buttonText: String {
        if isPurchased {
            return "Purchased"
        } else if isPurchasing {
            return "Processing..."
        } else {
            return "Buy Now"
        }
    }
    
    private var buttonIcon: String {
        if isPurchased {
            return "checkmark.circle.fill"
        } else if isPurchasing {
            return "clock.fill"
        } else {
            return "cart.badge.plus"
        }
    }
    
    private var buttonTextColor: Color {
        if isPurchased {
            return .white
        } else if isPurchasing {
            return .black
        } else {
            return .black
        }
    }
    
    private var buttonGradientColors: [Color] {
        if isPurchased {
            return [Color.green, Color.green.opacity(0.8)]
        } else if isPurchasing {
            return [Color.orange.opacity(0.7), Color.orange.opacity(0.5)]
        } else {
            return [Color.orange, Color.orange.opacity(0.8)]
        }
    }
    
    private var buttonShadowColor: Color {
        if isPurchased {
            return Color.green.opacity(0.3)
        } else if isPurchasing {
            return Color.orange.opacity(0.2)
        } else {
            return Color.orange.opacity(0.4)
        }
    }
    
    private var buttonStrokeColor: Color {
        if isPurchased {
            return Color.green.opacity(0.3)
        } else if isPurchasing {
            return Color.orange.opacity(0.2)
        } else {
            return Color.orange.opacity(0.3)
        }
    }
    
    private var accessibilityLabel: String {
        if isPurchased {
            return "Product purchased"
        } else if isPurchasing {
            return "Processing purchase"
        } else {
            return "Buy \(product.title)"
        }
    }
    
    private var accessibilityHint: String {
        if isPurchased {
            return "This product has been purchased"
        } else if isPurchasing {
            return "Purchase is being processed"
        } else {
            return "Double tap to purchase this product"
        }
    }
    
    private func handlePurchase() {
        guard !isPurchased && !isPurchasing else { return }
        
        // Add haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        // Animate button press
        withAnimation(.easeInOut(duration: 0.1)) {
            isPressed = true
        }
        
        // Reset button press after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = false
            }
        }
        
        // Handle purchase
        Task {
            do {
                try await purchaseManager.purchaseProduct(product)
                showingSuccessAlert = true
            } catch {
                print("Purchase failed: \(error)")
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        PurchaseButtonView(
            product: Product(
                id: 1,
                title: "Sample Product",
                price: 29.99,
                description: "A sample product",
                category: CategoryResponse(id: 1, name: "Electronics", image: nil),
                images: [],
                rating: Rating(rate: 4.5, count: 100)
            ),
            isPurchased: false
        )
        
        PurchaseButtonView(
            product: Product(
                id: 2,
                title: "Sample Product",
                price: 29.99,
                description: "A sample product",
                category: CategoryResponse(id: 1, name: "Electronics", image: nil),
                images: [],
                rating: Rating(rate: 4.5, count: 100)
            ),
            isPurchased: true
        )
    }
    .padding()
} 