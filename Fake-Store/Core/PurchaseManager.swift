import Foundation
import StoreKit

@MainActor
class PurchaseManager: ObservableObject {
    static let shared = PurchaseManager()
    
    @Published private(set) var products: [String: StoreKit.Product] = [:]
    @Published private(set) var purchasedProductIDs = Set<Int>()
    @Published var purchaseStatus: PurchaseStatus = .notPurchased
    
    private var productIDs = ["com.fakeshop.product1", "com.fakeshop.product2"]
    private var updateListenerTask: Task<Void, Error>?
    
    private init() {
        updateListenerTask = listenForTransactions()
        
        // Initialize stored purchases
        loadPurchasesOnInit()
    }
    
    private func loadPurchasesOnInit() {
        Task {
            await loadStoredPurchases()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try await self.checkVerified(result)
                    
                    // Convert StoreKit product ID to our app's product ID
                    if let productId = Int(transaction.productID.split(separator: ".").last ?? "") {
                        await self.updatePurchasedProducts(productId)
                    }
                    
                    await transaction.finish()
                } catch {
                    print("Transaction failed verification: \(error)")
                }
            }
        }
    }
    
    func loadStoredPurchases() async {
        // Load from UserDefaults
        purchasedProductIDs = Set(PurchasedProduct.getAll().map { $0.productId })
    }
    
    func refreshPurchaseState() async {
        await loadStoredPurchases()
    }
    
    func requestProducts() async {
        do {
            let storeProducts = try await StoreKit.Product.products(for: productIDs)
            
            var newProducts: [String: StoreKit.Product] = [:]
            for product in storeProducts {
                newProducts[product.id] = product
            }
            
            products = newProducts
        } catch {
            print("Failed to load products: \(error)")
        }
    }
    
    func purchaseProduct(_ product: Product) async throws {
        purchaseStatus = .purchasing
        
        // For demo purposes, we'll simulate a purchase
        do {
            // In a real app, you would use StoreKit to make the purchase
            // await purchase(product)
            
            // Simulate network delay
            try await Task.sleep(nanoseconds: 2_000_000_000)
            
            // Save the purchase
            await updatePurchasedProducts(product.id)
            
            purchaseStatus = .purchased
        } catch {
            purchaseStatus = .failed(error: error.localizedDescription)
            throw error
        }
    }
    
    func updatePurchasedProducts(_ productId: Int) async {
        // Save to UserDefaults - this is synchronous so no await needed
        PurchasedProduct.save(productId)
        
        // Update the published set - already on MainActor so no await needed
        purchasedProductIDs.insert(productId)
    }
    
    func isPurchased(_ productId: Int) -> Bool {
        return purchasedProductIDs.contains(productId)
    }
    
    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
}

enum StoreError: Error {
    case failedVerification
} 
