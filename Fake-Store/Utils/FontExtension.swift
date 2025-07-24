import SwiftUI

// Font extension to support Roboto-like fonts
extension Font {
    // Since we can't directly download and install Roboto fonts,
    // we'll use the system font with Roboto-like characteristics
    
    static func robotoRegular(size: CGFloat) -> Font {
        return Font.custom("Roboto-Regular", size: size).weight(.regular)
    }
    
    static func robotoMedium(size: CGFloat) -> Font {
        return Font.custom("Roboto-Medium", size: size).weight(.medium)
    }
    
    static func robotoBold(size: CGFloat) -> Font {
        return Font.custom("Roboto-Bold", size: size).weight(.bold)
    }
    
    static func robotoLight(size: CGFloat) -> Font {
        return Font.custom("Roboto-Light", size: size).weight(.light)
    }
    
    // Fallback to system font
    static func robotoOrSystem(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        switch weight {
        case .bold:
            return Font.custom("Roboto-Bold", size: size).weight(.bold)
        case .medium:
            return Font.custom("Roboto-Medium", size: size).weight(.medium)
        case .light:
            return Font.custom("Roboto-Light", size: size).weight(.light)
        case .regular:
            return Font.custom("Roboto-Regular", size: size).weight(.regular)
        default:
            return Font.system(size: size, weight: .regular, design: .default)
        }
    }
} 
