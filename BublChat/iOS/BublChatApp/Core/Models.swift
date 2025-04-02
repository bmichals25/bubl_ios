import Foundation

// API Models that match the JSON response from our backend
public extension BublChatApp {
    struct Message: Codable, Identifiable {
        public let id: String
        public let sender: String
        public let content: String
        public let mediaType: String
        public let timestamp: Date
        public let metadata: [String: String]?
        
        enum CodingKeys: String, CodingKey {
            case id = "_id"
            case sender
            case content
            case mediaType
            case timestamp
            case metadata
        }
        
        // Custom initializer to handle potential null values
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            id = try container.decode(String.self, forKey: .id)
            sender = try container.decode(String.self, forKey: .sender)
            content = try container.decode(String.self, forKey: .content)
            mediaType = try container.decode(String.self, forKey: .mediaType)
            timestamp = try container.decode(Date.self, forKey: .timestamp)
            
            // Handle metadata which might be null or not exist
            if container.contains(.metadata), try !container.decodeNil(forKey: .metadata) {
                let metadataContainer = try container.nestedContainer(keyedBy: DynamicKey.self, forKey: .metadata)
                var dict = [String: String]()
                
                for key in metadataContainer.allKeys {
                    if let value = try? metadataContainer.decode(String.self, forKey: key) {
                        dict[key.stringValue] = value
                    }
                }
                metadata = dict
            } else {
                metadata = nil
            }
        }
        
        // Dynamic coding key to handle arbitrary keys in metadata
        struct DynamicKey: CodingKey {
            var stringValue: String
            init(stringValue: String) { self.stringValue = stringValue }
            var intValue: Int? { return nil }
            init?(intValue: Int) { return nil }
        }
    }

    struct Conversation: Codable, Identifiable {
        public let id: String
        public let userId: String
        public let title: String
        public let messages: [Message]
        public let status: String
        public let createdAt: Date
        public let updatedAt: Date
        
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
} 