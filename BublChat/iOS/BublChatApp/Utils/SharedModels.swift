import Foundation
import Combine

// This file contains shared model definitions to prevent circular imports

// Message model for UI display
public struct ChatMessage: Identifiable {
    public let id = UUID()
    public let content: String
    public let isFromUser: Bool
    public let timestamp = Date()
    
    public init(content: String, isFromUser: Bool) {
        self.content = content
        self.isFromUser = isFromUser
    }
}

// API Models
public struct Conversation: Codable, Identifiable {
    public let id: String
    public let userId: String
    public let title: String
    public let messages: [Message]
    public let status: String
    public let createdAt: Date
    public let updatedAt: Date
    
    public enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userId
        case title
        case messages
        case status
        case createdAt
        case updatedAt
    }
}

public struct Message: Codable, Identifiable {
    public let id: String
    public let sender: String
    public let content: String
    public let mediaType: String
    public let timestamp: Date
    public let metadata: [String: String]?
    
    public enum CodingKeys: String, CodingKey {
        case id = "_id"
        case sender
        case content
        case mediaType
        case timestamp
        case metadata
    }
    
    // Function to convert API Message to UI ChatMessage
    public func toChatMessage() -> ChatMessage {
        return ChatMessage(
            content: content,
            isFromUser: sender == "user"
        )
    }
} 