import Foundation

enum PurchaseStatus: Equatable {
    case notPurchased
    case purchasing
    case purchased
    case failed(error: String)
    
    static func == (lhs: PurchaseStatus, rhs: PurchaseStatus) -> Bool {
        switch (lhs, rhs) {
        case (.notPurchased, .notPurchased):
            return true
        case (.purchasing, .purchasing):
            return true
        case (.purchased, .purchased):
            return true
        case (.failed(let lhsError), .failed(let rhsError)):
            return lhsError == rhsError
        default:
            return false
        }
    }
}

struct PurchasedProduct: Codable {
    let productId: Int
    let purchaseDate: Date
    
    init(productId: Int) {
        self.productId = productId
        self.purchaseDate = Date()
    }
    
    // Save to UserDefaults
    static func save(_ productId: Int) {
        let purchasedProduct = PurchasedProduct(productId: productId)
        let key = "purchased_product_\(productId)"
        
        if let data = try? JSONEncoder().encode(purchasedProduct) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    // Get all purchased products
    static func getAll() -> [PurchasedProduct] {
        let defaults = UserDefaults.standard
        var purchasedProducts: [PurchasedProduct] = []
        
        for key in defaults.dictionaryRepresentation().keys {
            if key.hasPrefix("purchased_product_") {
                if let data = defaults.data(forKey: key),
                   let product = try? JSONDecoder().decode(PurchasedProduct.self, from: data) {
                    purchasedProducts.append(product)
                }
            }
        }
        
        return purchasedProducts
    }
    
    // Check if a product is purchased
    static func isPurchased(_ productId: Int) -> Bool {
        let key = "purchased_product_\(productId)"
        return UserDefaults.standard.object(forKey: key) != nil
    }
    
    // Remove a purchase (for testing)
    static func remove(_ productId: Int) {
        let key = "purchased_product_\(productId)"
        UserDefaults.standard.removeObject(forKey: key)
    }
} 