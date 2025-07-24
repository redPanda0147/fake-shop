import Foundation
import Combine

@MainActor
class ProductDetailViewModel: ObservableObject {
    @Published var product: Product?
    @Published var isLoading = false
    @Published var error: APIError?
    @Published var hasError = false
    @Published var purchaseStatus: PurchaseStatus = .notPurchased
    
    private let purchaseManager: PurchaseManager
    
    init(product: Product? = nil, purchaseManager: PurchaseManager = PurchaseManager.shared) {
        self.product = product
        self.purchaseManager = purchaseManager
        
        if let product = product {
            checkPurchaseStatus(for: product.id)
        }
    }
    
    func loadProduct(id: Int) async {
        isLoading = true
        hasError = false
        
        do {
            product = try await NetworkService.shared.fetchProduct(id: id)
            checkPurchaseStatus(for: id)
            isLoading = false
        } catch let apiError as APIError {
            isLoading = false
            self.error = apiError
            hasError = true
        } catch {
            isLoading = false
            self.error = APIError.unknown
            hasError = true
        }
    }
    
    func checkPurchaseStatus(for productId: Int) {
        if purchaseManager.isPurchased(productId) {
            purchaseStatus = .purchased
        } else {
            purchaseStatus = .notPurchased
        }
    }
    
    func purchaseProduct() async {
        guard let product = product else { return }
        
        purchaseStatus = .purchasing
        
        do {
            try await purchaseManager.purchaseProduct(product)
            purchaseStatus = .purchased
        } catch {
            purchaseStatus = .failed(error: error.localizedDescription)
        }
    }
    
    var isPurchased: Bool {
        guard let product = product else { return false }
        return purchaseManager.isPurchased(product.id)
    }
} 
