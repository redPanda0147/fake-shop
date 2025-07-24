import SwiftUI

// Image cache
class ImageCache {
    static let shared = ImageCache()
    private var cache = NSCache<NSString, UIImage>()
    
    private init() {
        // Set cache limits
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024 // 50 MB
    }
    
    func get(forKey key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }
    
    func set(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
}

// Image loader with caching
class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    @Published var isLoading = false
    private var cancellable: URLSessionDataTask?
    private var url: URL?
    
    func load(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        self.url = url
        
        // Check cache first
        if let cachedImage = ImageCache.shared.get(forKey: urlString) {
            self.image = cachedImage
            return
        }
        
        cancellable?.cancel()
        isLoading = true
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                guard let data = data, error == nil,
                      let loadedImage = UIImage(data: data) else {
                    return
                }
                
                ImageCache.shared.set(loadedImage, forKey: urlString)
                if self.url?.absoluteString == urlString {
                    self.image = loadedImage
                }
            }
        }
        
        task.resume()
        self.cancellable = task
    }
    
    func cancel() {
        cancellable?.cancel()
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
    
    func cardStyle() -> some View {
        self
            .background(AppColor.cardBackground)
            .cornerRadius(AppDimension.cornerRadius)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    func primaryButtonStyle() -> some View {
        self
            .padding()
            .frame(maxWidth: .infinity)
            .background(AppColor.primary)
            .foregroundColor(.white)
            .cornerRadius(AppDimension.cornerRadius)
            .shadow(color: AppColor.primary.opacity(0.3), radius: 5, x: 0, y: 2)
    }
    
    // Add haptic feedback to buttons
    func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) -> some View {
        self.onTapGesture {
            let generator = UIImpactFeedbackGenerator(style: style)
            generator.impactOccurred()
        }
    }
    
    // Support for reduced motion accessibility setting
    func conditionalAnimation<Value: Equatable>(_ animation: Animation?, value: Value, enabled: Bool = true) -> some View {
        Group {
            if enabled {
                self.animation(animation, value: value)
            } else {
                self
            }
        }
    }
    
    // Support for reduced transparency accessibility setting
    func adaptiveBlur(radius: CGFloat) -> some View {
        modifier(AdaptiveBlurModifier(radius: radius))
    }
}

struct AdaptiveBlurModifier: ViewModifier {
    let radius: CGFloat
    @Environment(\.accessibilityReduceTransparency) var reduceTransparency
    
    func body(content: Content) -> some View {
        Group {
            if reduceTransparency {
                content
            } else {
                content.blur(radius: radius)
            }
        }
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension Double {
    func formatAsCurrency() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        
        return formatter.string(from: NSNumber(value: self)) ?? "$\(self)"
    }
}

extension String {
    func capitalizeFirstLetter() -> String {
        return self.prefix(1).capitalized + self.dropFirst()
    }
    
    func truncated(to length: Int, trailing: String = "...") -> String {
        return (self.count > length) ? self.prefix(length) + trailing : self
    }
}

extension Color {
    static var random: Color {
        return Color(
            red: Double.random(in: 0.4...0.8),
            green: Double.random(in: 0.4...0.8),
            blue: Double.random(in: 0.4...0.8)
        )
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
} 
