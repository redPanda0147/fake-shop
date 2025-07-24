import Foundation

enum APIError: Error, Equatable {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case decodingError
    case serverError(String)
    case networkError
    case unknown
    
    var message: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from the server"
        case .httpError(let statusCode):
            return "HTTP error with status code: \(statusCode)"
        case .decodingError:
            return "Failed to decode the response"
        case .serverError(let message):
            return "Server error: \(message)"
        case .networkError:
            return "Network connection error"
        case .unknown:
            return "An unknown error occurred"
        }
    }
} 