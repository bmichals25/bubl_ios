import Foundation
import Combine

public extension BublChatApp {
    class APIClient {
        public static let shared = APIClient()
        
        #if DEBUG
        private let baseURL = "http://localhost:4000/api"
        #else
        private let baseURL = "https://api.bublchat.com/api"
        #endif
        
        private var cancellables = Set<AnyCancellable>()
        
        // Create a decoder configured for our API date format
        private lazy var decoder: JSONDecoder = {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .custom { decoder in
                let container = try decoder.singleValueContainer()
                let dateString = try container.decode(String.self)
                
                let formatter = ISO8601DateFormatter()
                formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                
                if let date = formatter.date(from: dateString) {
                    return date
                }
                
                formatter.formatOptions = [.withInternetDateTime]
                if let date = formatter.date(from: dateString) {
                    return date
                }
                
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Cannot decode date: \(dateString)"
                )
            }
            return decoder
        }()
        
        public enum APIError: Error {
            case invalidURL
            case networkError(Error)
            case decodingError(Error)
            case serverError(Int, String)
        }
        
        // MARK: - Test API Endpoints (no auth required)
        
        public func createTestConversation(initialMessage: String) -> AnyPublisher<Conversation, APIError> {
            let endpoint = "\(baseURL)/conversations/test"
            
            guard let url = URL(string: endpoint) else {
                return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let params = ["initialMessage": initialMessage]
            
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: params)
            } catch {
                return Fail(error: APIError.networkError(error)).eraseToAnyPublisher()
            }
            
            return URLSession.shared.dataTaskPublisher(for: request)
                .map(\.data)
                .decode(type: Conversation.self, decoder: decoder)
                .mapError { error -> APIError in
                    if let urlError = error as? URLError {
                        return .networkError(urlError)
                    } else if let decodingError = error as? DecodingError {
                        print("Decoding error: \(decodingError)")
                        return .decodingError(decodingError)
                    } else {
                        return .networkError(error)
                    }
                }
                .eraseToAnyPublisher()
        }
        
        public func addMessageToTestConversation(conversationId: String, content: String) -> AnyPublisher<Conversation, APIError> {
            let endpoint = "\(baseURL)/conversations/test/\(conversationId)/messages"
            
            guard let url = URL(string: endpoint) else {
                return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let params = ["content": content]
            
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: params)
            } catch {
                return Fail(error: APIError.networkError(error)).eraseToAnyPublisher()
            }
            
            return URLSession.shared.dataTaskPublisher(for: request)
                .map(\.data)
                .decode(type: Conversation.self, decoder: decoder)
                .mapError { error -> APIError in
                    if let urlError = error as? URLError {
                        return .networkError(urlError)
                    } else if let decodingError = error as? DecodingError {
                        return .decodingError(decodingError)
                    } else {
                        return .networkError(error)
                    }
                }
                .eraseToAnyPublisher()
        }
        
        public func getAllTestConversations() -> AnyPublisher<[Conversation], APIError> {
            let endpoint = "\(baseURL)/conversations/test"
            
            guard let url = URL(string: endpoint) else {
                return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
            }
            
            let request = URLRequest(url: url)
            
            return URLSession.shared.dataTaskPublisher(for: request)
                .map(\.data)
                .decode(type: [Conversation].self, decoder: decoder)
                .mapError { error -> APIError in
                    if let urlError = error as? URLError {
                        return .networkError(urlError)
                    } else if let decodingError = error as? DecodingError {
                        return .decodingError(decodingError)
                    } else {
                        return .networkError(error)
                    }
                }
                .eraseToAnyPublisher()
        }
    }
} 