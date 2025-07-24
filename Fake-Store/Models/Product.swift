import Foundation

struct Product: Identifiable, Codable, Equatable {
    let id: Int
    let title: String
    let price: Double
    let description: String
    let category: CategoryResponse
    let images: [String]
    var rating: Rating?
    
    static func == (lhs: Product, rhs: Product) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Regular initializer for creating instances in code
    init(id: Int, title: String, price: Double, description: String, category: CategoryResponse, images: [String], rating: Rating?) {
        self.id = id
        self.title = title
        self.price = price
        self.description = description
        self.category = category
        self.images = images
        self.rating = rating ?? Rating.generateRandom()
    }
    
    // Custom coding keys to handle optional fields
    enum CodingKeys: String, CodingKey {
        case id, title, price, description, category, images
        case rating // This might not be in the API response
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        price = try container.decode(Double.self, forKey: .price)
        description = try container.decode(String.self, forKey: .description)
        category = try container.decode(CategoryResponse.self, forKey: .category)
        images = try container.decode([String].self, forKey: .images)
        rating = try container.decodeIfPresent(Rating.self, forKey: .rating) ?? Rating.generateRandom()
    }
    
    // Create a copy with a new rating
    func withRandomRating() -> Product {
        return Product(
            id: self.id,
            title: self.title,
            price: self.price,
            description: self.description,
            category: self.category,
            images: self.images,
            rating: Rating.generateRandom()
        )
    }
}

struct Rating: Codable, Equatable {
    let rate: Double
    let count: Int
    
    init(rate: Double, count: Int) {
        self.rate = rate
        self.count = count
    }
    
    // Generate a random rating
    static func generateRandom() -> Rating {
        let randomRate = Double.random(in: 3.0...5.0).rounded(toPlaces: 1)
        let randomCount = Int.random(in: 10...500)
        return Rating(rate: randomRate, count: randomCount)
    }
}

// New model for the API's category response
struct CategoryResponse: Codable, Equatable {
    let id: Int
    let name: String
    let image: String?
    
    // Regular initializer
    init(id: Int, name: String, image: String?) {
        self.id = id
        self.name = name
        self.image = image
    }
    
    // Add custom decoding if needed
    enum CodingKeys: String, CodingKey {
        case id, name, image
    }
    
    // Map to our app's category enum
    var category: Category {
        switch name.lowercased() {
        case "electronics":
            return .electronics
        case "jewelery", "jewelry":
            return .jewelery
        case "men's clothing", "clothes" where id == 1:
            return .menSClothing
        case "women's clothing", "clothes" where id == 2:
            return .womenSClothing
        default:
            // Default to a category based on the name
            return .other(name: name)
        }
    }
}

// Updated Category enum to handle any category from the API
enum Category: Equatable, CaseIterable {
    case electronics
    case jewelery
    case menSClothing
    case womenSClothing
    case other(name: String)
    
    var displayName: String {
        switch self {
        case .electronics: return "Electronics"
        case .jewelery: return "Jewelery"
        case .menSClothing: return "Men's Clothing"
        case .womenSClothing: return "Women's Clothing"
        case .other(let name): return name.capitalizeFirstLetter()
        }
    }
    
    // Provide the allCases implementation since we have an associated value
    static var allCases: [Category] {
        return [.electronics, .jewelery, .menSClothing, .womenSClothing]
    }
}

// API Response models
struct ProductsResponse: Codable {
    let products: [Product]
    let total: Int
    let skip: Int
    let limit: Int
}

// Extension to round doubles to specific decimal places
extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
} 