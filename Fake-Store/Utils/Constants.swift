import SwiftUI

enum AppColor {
    // Main color from hex 0d031b (dark purple/blue)
    static let main = Color(hex: "0d031b")
    
    // Enhanced color palette based on main color
    static let primary = Color(hex: "0d031b")
    static let secondary = Color(red: 0.95, green: 0.55, blue: 0.0) // Warm orange
    static let accent = Color(red: 0.2, green: 0.8, blue: 0.6) // Teal accent
    static let background = Color(.systemBackground)
    static let secondaryBackground = Color(.secondarySystemBackground)
    static let tertiaryBackground = Color(.tertiarySystemBackground)
    static let text = Color(hex: "0d031b")
    static let secondaryText = Color(hex: "0d031b").opacity(0.7)
    static let tertiaryText = Color(hex: "0d031b").opacity(0.5)
    static let success = Color(red: 0.2, green: 0.8, blue: 0.4) // Success green
    static let error = Color(red: 0.9, green: 0.3, blue: 0.3) // Error red
    static let cardBackground = Color(.systemBackground).opacity(0.95)
}

enum AppFont {
    // Using Roboto font with system fallback
    static let title = Font.robotoOrSystem(size: 28, weight: .bold).leading(.tight)
    static let title2 = Font.robotoOrSystem(size: 22, weight: .bold).leading(.tight)
    static let title3 = Font.robotoOrSystem(size: 20, weight: .semibold).leading(.tight)
    static let headline = Font.robotoOrSystem(size: 17, weight: .semibold)
    static let subheadline = Font.robotoOrSystem(size: 15, weight: .medium)
    static let body = Font.robotoOrSystem(size: 17, weight: .regular)
    static let callout = Font.robotoOrSystem(size: 16, weight: .regular)
    static let footnote = Font.robotoOrSystem(size: 13, weight: .regular)
    static let caption = Font.robotoOrSystem(size: 12, weight: .medium)
    static let caption2 = Font.robotoOrSystem(size: 11, weight: .medium)
    
    // Product card specific fonts
    static let productTitle = Font.robotoOrSystem(size: 16, weight: .semibold)
    static let productPrice = Font.robotoOrSystem(size: 18, weight: .bold)
    static let productDescription = Font.robotoOrSystem(size: 14, weight: .regular)
    static let productCategory = Font.robotoOrSystem(size: 12, weight: .medium)
    
    // For cases where we need to ensure text fits in a constrained space
    static func scaledFont(_ style: Font.TextStyle, size: CGFloat) -> Font {
        return Font.robotoOrSystem(size: size, weight: .regular)
    }
    
    // Alternative approach for dynamic type with size constraints
    static func customFont(for textStyle: Font.TextStyle, relativeTo size: CGFloat = 0) -> Font {
        switch textStyle {
        case .largeTitle:
            return Font.robotoOrSystem(size: 34 + size, weight: .bold)
        case .title:
            return Font.robotoOrSystem(size: 28 + size, weight: .bold)
        case .title2:
            return Font.robotoOrSystem(size: 22 + size, weight: .bold)
        case .title3:
            return Font.robotoOrSystem(size: 20 + size, weight: .semibold)
        case .headline:
            return Font.robotoOrSystem(size: 17 + size, weight: .semibold)
        case .body:
            return Font.robotoOrSystem(size: 17 + size, weight: .regular)
        case .callout:
            return Font.robotoOrSystem(size: 16 + size, weight: .regular)
        case .subheadline:
            return Font.robotoOrSystem(size: 15 + size, weight: .regular)
        case .footnote:
            return Font.robotoOrSystem(size: 13 + size, weight: .regular)
        case .caption:
            return Font.robotoOrSystem(size: 12 + size, weight: .medium)
        case .caption2:
            return Font.robotoOrSystem(size: 11 + size, weight: .medium)
        @unknown default:
            return Font.robotoOrSystem(size: 17 + size, weight: .regular)
        }
    }
}

enum AppDimension {
    // Base dimensions that scale appropriately with Dynamic Type
    static let cornerRadius: CGFloat = 16
    static let padding: CGFloat = 16
    static let smallPadding: CGFloat = 8
    static let largePadding: CGFloat = 24
    static let iconSize: CGFloat = 24
    static let imageHeight: CGFloat = 200
    static let thumbnailSize: CGFloat = 80
    
    // Helper function to scale dimensions based on content size category
    static func scaledDimension(_ dimension: CGFloat, for sizeCategory: ContentSizeCategory) -> CGFloat {
        switch sizeCategory {
        case .accessibilityExtraExtraExtraLarge:
            return dimension * 1.5
        case .accessibilityExtraExtraLarge:
            return dimension * 1.4
        case .accessibilityExtraLarge:
            return dimension * 1.3
        case .accessibilityLarge:
            return dimension * 1.2
        case .accessibilityMedium:
            return dimension * 1.1
        case .extraExtraExtraLarge:
            return dimension * 1.05
        default:
            return dimension
        }
    }
}

enum AppAnimation {
    static let standard = Animation.spring(response: 0.3, dampingFraction: 0.7)
    static let slow = Animation.spring(response: 0.5, dampingFraction: 0.7)
    static let fast = Animation.spring(response: 0.2, dampingFraction: 0.7)
}

// Extension to create Color from hex string
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
} 
