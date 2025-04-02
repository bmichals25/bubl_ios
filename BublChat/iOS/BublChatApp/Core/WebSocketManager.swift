import Foundation
import Combine

@objc public class WebSocketManager: NSObject, ObservableObject {
    @objc public static let shared = WebSocketManager()
    
    @Published public var isConnected = false
    @Published public var lastReceivedMessage: String?
    
    private var webSocketTask: URLSessionWebSocketTask?
    private var pingTimer: Timer?
    private var reconnectTimer: Timer?
    
    #if DEBUG
    // Use a plain ws:// URL for WebSocket connection (Socket.IO server will handle it)
    private let socketURL = URL(string: "ws://localhost:4000/socket.io/?EIO=4&transport=websocket")!
    #else
    private let socketURL = URL(string: "wss://api.bublchat.com/socket.io/?EIO=4&transport=websocket")!
    #endif
    
    @objc private override init() {
        super.init()
        print("Initializing WebSocketManager")
        connect()
    }
    
    func connect() {
        print("Attempting to connect to WebSocket: \(socketURL)")
        let session = URLSession(configuration: .default)
        webSocketTask = session.webSocketTask(with: socketURL)
        webSocketTask?.resume()
        isConnected = true
        
        receiveMessage()
        setupPingTimer()
        
        // Cancel any existing reconnect timers
        reconnectTimer?.invalidate()
        reconnectTimer = nil
    }
    
    func disconnect() {
        print("Disconnecting WebSocket")
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
        webSocketTask = nil
        isConnected = false
        
        pingTimer?.invalidate()
        pingTimer = nil
    }
    
    @objc public func sendMessage(_ text: String, completion: @escaping (Bool) -> Void) {
        guard isConnected, let webSocketTask = webSocketTask else {
            print("Cannot send message: WebSocket not connected")
            completion(false)
            return
        }
        
        // Create message payload
        let message = ["text": text, "timestamp": ISO8601DateFormatter().string(from: Date())]
        
        do {
            let data = try JSONSerialization.data(withJSONObject: message)
            let string = String(data: data, encoding: .utf8)!
            
            print("Sending message: \(string)")
            
            // Send as binary for consistency
            webSocketTask.send(.data(data)) { error in
                if let error = error {
                    print("Error sending message: \(error)")
                    completion(false)
                } else {
                    print("Message sent successfully")
                    completion(true)
                }
            }
        } catch {
            print("Error creating message JSON: \(error)")
            completion(false)
        }
    }
    
    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    print("Received string message: \(text)")
                    DispatchQueue.main.async {
                        self.lastReceivedMessage = text
                        self.handleReceivedMessage(text)
                    }
                case .data(let data):
                    if let string = String(data: data, encoding: .utf8) {
                        print("Received data message: \(string)")
                        DispatchQueue.main.async {
                            self.lastReceivedMessage = string
                            self.handleReceivedMessage(string)
                        }
                    } else {
                        print("Received binary data that couldn't be converted to string")
                    }
                @unknown default:
                    print("Received unknown message type")
                    break
                }
                
                // Continue receiving messages
                self.receiveMessage()
                
            case .failure(let error):
                print("Error receiving message: \(error)")
                self.handleDisconnection()
            }
        }
    }
    
    private func handleReceivedMessage(_ text: String) {
        // First check if it's a Socket.IO protocol message
        if text.hasPrefix("0") || text.hasPrefix("40") {
            // Socket.IO handshake - we can ignore these
            print("Received Socket.IO handshake message: \(text)")
            return
        }
        
        // Check if it's a Socket.IO message with a payload (starts with 42)
        if text.hasPrefix("42") {
            do {
                // Socket.IO message format is "42[\"event\",{...}]"
                // We need to extract the payload
                let startIndex = text.index(text.startIndex, offsetBy: 2)
                let jsonText = String(text[startIndex...])
                
                // Parse the socket.io message array [event, data]
                if let data = jsonText.data(using: .utf8),
                   let socketMessage = try JSONSerialization.jsonObject(with: data) as? [Any],
                   socketMessage.count >= 2,
                   let event = socketMessage[0] as? String,
                   event == "response" {
                    
                    // Convert the response data back to JSON
                    if let responseData = socketMessage[1] as? [String: Any] {
                        let responseJSON = try JSONSerialization.data(withJSONObject: responseData)
                        let responseString = String(data: responseJSON, encoding: .utf8)!
                        
                        // Notify listeners about the actual message content
                        notifyListeners(responseString)
                    }
                }
            } catch {
                print("Error parsing Socket.IO message: \(error)")
            }
            return
        }
        
        // Otherwise, treat as a regular JSON message
        notifyListeners(text)
    }
    
    private func notifyListeners(_ message: String) {
        // Post notification with the message
        NotificationCenter.default.post(
            name: Notification.Name("WebSocketMessageReceived"),
            object: nil,
            userInfo: ["message": message]
        )
    }
    
    private func setupPingTimer() {
        // Send a ping every 30 seconds to keep the connection alive
        pingTimer?.invalidate()
        pingTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            self?.ping()
        }
    }
    
    private func ping() {
        webSocketTask?.sendPing { [weak self] error in
            if let error = error {
                print("Error sending ping: \(error)")
                self?.handleDisconnection()
            }
        }
    }
    
    private func handleDisconnection() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            print("WebSocket disconnected")
            self.isConnected = false
            self.webSocketTask = nil
            self.pingTimer?.invalidate()
            self.pingTimer = nil
            
            // Try to reconnect after a delay
            self.setupReconnectTimer()
        }
    }
    
    private func setupReconnectTimer() {
        // Try to reconnect every 5 seconds
        reconnectTimer?.invalidate()
        reconnectTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            print("Attempting to reconnect WebSocket")
            self?.connect()
        }
    }
} 