import Foundation
import Combine
import UIKit
import SwiftUI

// Include models directly in the file since imports are causing problems
// Message model for UI display
struct ChatMessage: Identifiable {
    let id = UUID()
    let content: String
    let isFromUser: Bool
    let timestamp = Date()
    
    init(content: String, isFromUser: Bool) {
        self.content = content
        self.isFromUser = isFromUser
    }
}

// API Models
struct Conversation: Codable, Identifiable {
    let id: String
    let userId: String
    let title: String
    let messages: [Message]
    let status: String
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userId
        case title
        case messages
        case status
        case createdAt
        case updatedAt
    }
}

struct Message: Codable, Identifiable {
    let id: String
    let sender: String
    let content: String
    let mediaType: String
    let timestamp: Date
    let metadata: [String: String]?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case sender
        case content
        case mediaType
        case timestamp
        case metadata
    }
    
    // Function to convert API Message to UI ChatMessage
    func toChatMessage() -> ChatMessage {
        return ChatMessage(
            content: content,
            isFromUser: sender == "user"
        )
    }
}

@objc class TextChatViewModel: NSObject, ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isConnecting = false
    @Published var connectionError: String?
    @Published var currentConversation: Conversation?
    
    private var cancellables = Set<AnyCancellable>()
    private var webSocketManager: WebSocketManager
    
    // Create our own API client directly
    private let apiClient = APIClientImplementation()
    
    init(webSocketManager: WebSocketManager = WebSocketManager.shared) {
        self.webSocketManager = webSocketManager
        
        super.init()
        
        // Subscribe to WebSocket connection status
        webSocketManager.$isConnected
            .receive(on: DispatchQueue.main)
            .sink { [weak self] connected in
                self?.isConnecting = false
                if !connected {
                    self?.connectionError = "Connection lost. Trying to reconnect..."
                } else {
                    self?.connectionError = nil
                }
            }
            .store(in: &cancellables)
        
        // Listen for incoming messages
        NotificationCenter.default.publisher(for: Notification.Name("WebSocketMessageReceived"))
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notification in
                if let messageText = notification.userInfo?["message"] as? String {
                    self?.handleReceivedMessage(messageText)
                }
            }
            .store(in: &cancellables)
    }
    
    func addInitialMessages() {
        let welcomeMessage = ChatMessage(
            content: "Hello! I'm Bubl, your friendly AI companion. How can I help you today?",
            isFromUser: false
        )
        messages.append(welcomeMessage)
    }
    
    func sendMessage(content: String) {
        // Add user message immediately for better UX
        let userMessage = ChatMessage(content: content, isFromUser: true)
        messages.append(userMessage)
        
        if let currentConversation = currentConversation {
            // If we have an existing conversation, add to it
            apiClient.addMessageToTestConversation(conversationId: currentConversation.id, content: content)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { [weak self] (completion: Subscribers.Completion<APIClientImplementation.APIError>) in
                    if case let .failure(error) = completion {
                        print("Error adding message to conversation: \(error)")
                        self?.generateFallbackResponse(to: content)
                    }
                }, receiveValue: { [weak self] (updatedConversation: Conversation) in
                    self?.handleConversationUpdate(updatedConversation)
                })
                .store(in: &cancellables)
        } else {
            // Create a new conversation
            apiClient.createTestConversation(initialMessage: content)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { [weak self] (completion: Subscribers.Completion<APIClientImplementation.APIError>) in
                    if case let .failure(error) = completion {
                        print("Error creating conversation: \(error)")
                        
                        // If API call fails, use WebSocket if available
                        if self?.webSocketManager.isConnected == true {
                            self?.webSocketManager.sendMessage(content) { success in
                                if !success {
                                    self?.generateFallbackResponse(to: content)
                                }
                            }
                        } else {
                            self?.generateFallbackResponse(to: content)
                        }
                    }
                }, receiveValue: { [weak self] (conversation: Conversation) in
                    self?.handleConversationUpdate(conversation)
                })
                .store(in: &cancellables)
        }
    }
    
    private func handleConversationUpdate(_ conversation: Conversation) {
        self.currentConversation = conversation
        
        // Clear existing messages
        messages.removeAll()
        
        // Convert API messages to UI messages
        for message in conversation.messages {
            messages.append(message.toChatMessage())
        }
    }
    
    private func handleReceivedMessage(_ messageText: String) {
        print("Processing received message: \(messageText)")
        
        if let data = messageText.data(using: .utf8) {
            do {
                // Try to parse as a standard JSON object with a "text" field
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let responseText = json["text"] as? String {
                    
                    print("Parsed message with text field: \(responseText)")
                    // Create and add Bubl message
                    let bublMessage = ChatMessage(content: responseText, isFromUser: false)
                    self.messages.append(bublMessage)
                    return
                }
                
                // Try parsing full conversation object from our API
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let messages = json["messages"] as? [[String: Any]],
                   !messages.isEmpty,
                   let lastMessage = messages.last,
                   lastMessage["sender"] as? String == "bubl",
                   let content = lastMessage["content"] as? String {
                    
                    print("Parsed API conversation with Bubl message: \(content)")
                    let bublMessage = ChatMessage(content: content, isFromUser: false)
                    self.messages.append(bublMessage)
                    return
                }
                
                // Try to parse as a Socket.IO response object
                if messageText.contains("\"response\"") {
                    // This might be a Socket.IO message that wasn't fully parsed
                    let pattern = "\"response\"\\s*,\\s*\\{(.+?)\\}"
                    if let regex = try? NSRegularExpression(pattern: pattern, options: []),
                       let match = regex.firstMatch(in: messageText, options: [], range: NSRange(messageText.startIndex..., in: messageText)) {
                        
                        if let range = Range(match.range(at: 1), in: messageText) {
                            let jsonString = "{" + messageText[range] + "}"
                            if let jsonData = jsonString.data(using: .utf8),
                               let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
                               let responseText = json["text"] as? String {
                                
                                print("Parsed Socket.IO response: \(responseText)")
                                let bublMessage = ChatMessage(content: responseText, isFromUser: false)
                                self.messages.append(bublMessage)
                                return
                            }
                        }
                    }
                }
                
                // Force a throw to make the catch block reachable
                if messageText.isEmpty {
                    throw NSError(domain: "MessageProcessing", code: 100, userInfo: [NSLocalizedDescriptionKey: "Empty message"])
                }
                
                // If all parsing attempts fail, just use the raw message
                // First check if it looks like valid content (not protocol messages)
                if !messageText.isEmpty && !messageText.hasPrefix("0") && !messageText.hasPrefix("40") {
                    print("Using raw message: \(messageText)")
                    
                    // Try to clean up the message - remove any Echo: prefix the server might add
                    var cleanedText = messageText
                    cleanedText = cleanedText.replacingOccurrences(of: "Echo: ", with: "")
                    
                    // Remove any obvious JSON or Socket.IO formatting
                    if cleanedText.hasPrefix("{") && cleanedText.hasSuffix("}") {
                        cleanedText = "I received your message but couldn't parse the response. Please try again."
                    }
                    
                    let bublMessage = ChatMessage(content: cleanedText, isFromUser: false)
                    self.messages.append(bublMessage)
                }
            } catch {
                print("Error parsing message: \(error)")
            }
        }
    }
    
    // Fallback for when WebSocket is not available
    func generateFallbackResponse(to userMessage: String) {
        // For now, we'll use simple predefined responses
        let bublResponses = [
            "That's interesting! Tell me more about that.",
            "I understand. How does that make you feel?",
            "Thanks for sharing that with me!",
            "I'm here to chat whenever you need me.",
            "What else would you like to talk about?",
            "I'm still learning, but I'm doing my best to be helpful!"
        ]
        
        // Pick a random response
        let randomIndex = Int.random(in: 0..<bublResponses.count)
        let responseText = bublResponses[randomIndex]
        
        // Add after a small delay for a more natural feeling
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let bublMessage = ChatMessage(content: responseText, isFromUser: false)
            self.messages.append(bublMessage)
        }
    }
    
    // Load previous conversations
    func loadConversations() {
        apiClient.getAllTestConversations()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { (completion: Subscribers.Completion<APIClientImplementation.APIError>) in
                if case .failure(let error) = completion {
                    print("Error loading conversations: \(error)")
                }
            }, receiveValue: { [weak self] (conversations: [Conversation]) in
                // Use the most recent conversation if available
                if let mostRecent = conversations.first {
                    self?.handleConversationUpdate(mostRecent)
                }
            })
            .store(in: &cancellables)
    }
}

// Direct implementation of the API client
class APIClientImplementation: NSObject {
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
    
    enum APIError: Error {
        case invalidURL
        case networkError(Error)
        case decodingError(Error)
        case serverError(Int, String)
    }
    
    // MARK: - API Endpoints
    
    func createTestConversation(initialMessage: String) -> AnyPublisher<Conversation, APIError> {
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
    
    func addMessageToTestConversation(conversationId: String, content: String) -> AnyPublisher<Conversation, APIError> {
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
    
    func getAllTestConversations() -> AnyPublisher<[Conversation], APIError> {
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