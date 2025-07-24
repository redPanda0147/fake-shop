import Foundation

@MainActor
class NetworkService {
    static let shared = NetworkService()
    
    private init() {}
    
    private let baseURL = "https://api.escuelajs.co/api/v1"
    
    func fetchProducts(limit: Int = 10, skip: Int = 0, categoryId: Int? = nil) async throws -> [Product] {
        var urlString = "\(baseURL)/products?limit=\(limit)&skip=\(skip)"
        
        // Add category filter if provided
        if let categoryId = categoryId {
            urlString += "&categoryId=\(categoryId)"
        }
        
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw APIError.httpError(httpResponse.statusCode)
            }
            
            let decoder = JSONDecoder()
            var products = try decoder.decode([Product].self, from: data)
            
            // Filter out the problematic "Co Co CoLa" product
            products = products.filter { product in
                !product.title.contains("Co Co CoLa")
            }
            
            // Ensure all products have ratings
            for i in 0..<products.count {
                if products[i].rating == nil {
                    products[i].rating = Rating.generateRandom()
                }
            }
            
            return products
        } catch let error as APIError {
            throw error
        } catch let error as DecodingError {
            print("Decoding error: \(error)")
            throw APIError.decodingError
        } catch {
            print("Network error: \(error)")
            throw APIError.networkError
        }
    }
    
    func fetchProduct(id: Int) async throws -> Product {
        guard let url = URL(string: "\(baseURL)/products/\(id)") else {
            throw APIError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw APIError.httpError(httpResponse.statusCode)
            }
            
            let decoder = JSONDecoder()
            var product = try decoder.decode(Product.self, from: data)
            
            // Check if this is the problematic "Co Co CoLa" product
            if product.title.contains("Co Co CoLa") {
                throw APIError.invalidResponse
            }
            
            // Ensure product has a rating
            if product.rating == nil {
                product.rating = Rating.generateRandom()
            }
            
            return product
        } catch let error as APIError {
            throw error
        } catch let error as DecodingError {
            print("Decoding error: \(error)")
            throw APIError.decodingError
        } catch {
            print("Network error: \(error)")
            throw APIError.networkError
        }
    }
    
    func fetchCategories() async throws -> [CategoryResponse] {
        guard let url = URL(string: "\(baseURL)/categories") else {
            throw APIError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw APIError.httpError(httpResponse.statusCode)
            }
            
            let decoder = JSONDecoder()
            let categories = try decoder.decode([CategoryResponse].self, from: data)
            return categories
        } catch let error as DecodingError {
            print("Decoding error: \(error)")
            throw APIError.decodingError
        } catch {
            print("Network error: \(error)")
            throw APIError.networkError
        }
    }
} 