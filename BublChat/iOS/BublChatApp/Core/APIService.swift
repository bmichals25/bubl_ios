import Foundation
import Combine

class APIService {
    static let shared = APIService()
    
    #if DEBUG
    private let baseURL = "http://localhost:4000/api"
    #else
    private let baseURL = "https://api.bublchat.com/api" // Production URL for later
    #endif
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {}
    
    func fetchConversations(authToken: String, completion: @escaping (Result<[Conversation], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/conversations") else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: [Conversation].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { result in
                if case let .failure(error) = result {
                    completion(.failure(error))
                }
            }, receiveValue: { conversations in
                completion(.success(conversations))
            })
            .store(in: &cancellables)
    }
    
    func sendMessage(authToken: String, conversationId: String, content: String, mediaType: String = "text", completion: @escaping (Result<Message, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/conversations/\(conversationId)/messages") else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = [
            "content": content,
            "mediaType": mediaType
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: Message.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { result in
                if case let .failure(error) = result {
                    completion(.failure(error))
                }
            }, receiveValue: { message in
                completion(.success(message))
            })
            .store(in: &cancellables)
    }
    
    func createConversation(authToken: String, initialMessage: String? = nil, completion: @escaping (Result<Conversation, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/conversations") else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        
        var body: [String: Any] = [:]
        if let initialMessage = initialMessage {
            body["initialMessage"] = initialMessage
        }
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: Conversation.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { result in
                if case let .failure(error) = result {
                    completion(.failure(error))
                }
            }, receiveValue: { conversation in
                completion(.success(conversation))
            })
            .store(in: &cancellables)
    }
}

// API Models
struct Conversation: Codable, Identifiable {
    let id: String
    let userId: String
    let title: String
    let messages: [Message]
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userId, title, messages, createdAt, updatedAt
    }
}

struct Message: Codable, Identifiable {
    let id: String
    let sender: String
    let content: String
    let timestamp: Date
    let mediaType: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case sender, content, timestamp, mediaType
    }
}

// API Errors
enum APIError: Error {
    case invalidURL
    case requestFailed
    case decodingFailed
} 