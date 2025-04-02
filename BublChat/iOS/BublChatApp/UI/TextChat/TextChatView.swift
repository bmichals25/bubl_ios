import SwiftUI

struct TextChatView: View {
    @StateObject private var viewModel = TextChatViewModel()
    @State private var messageText = ""
    @State private var scrollToBottom = false
    @State private var bublEmotion: BublEmotion = .happy
    
    var body: some View {
        VStack {
            // Connection status indicator
            if viewModel.isConnecting {
                HStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                    Text("Connecting...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            } else if let error = viewModel.connectionError {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.vertical, 4)
            }
            
            // Bubl animation at the top
            BublAnimationView(emotion: bublEmotion)
                .padding(.vertical)
            
            // Chat messages list
            ScrollViewReader { scrollView in
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(viewModel.messages) { message in
                            MessageBubble(message: message)
                        }
                        .padding(.horizontal)
                        
                        // Invisible view at the bottom to scroll to
                        Text("")
                            .frame(height: 1)
                            .id("bottomID")
                    }
                }
                .onChange(of: viewModel.messages.count) { _ in
                    withAnimation {
                        scrollView.scrollTo("bottomID", anchor: .bottom)
                    }
                }
                .onAppear {
                    withAnimation {
                        scrollView.scrollTo("bottomID", anchor: .bottom)
                    }
                }
            }
            
            // Message input view
            HStack {
                TextField("Type a message...", text: $messageText)
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(20)
                    .submitLabel(.send)
                    .onSubmit {
                        sendMessage()
                    }
                
                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.blue)
                }
                .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
        }
        .navigationTitle("Chat with Bubl")
        .onAppear {
            // If no messages, show the welcome message
            if viewModel.messages.isEmpty {
                viewModel.addInitialMessages()
            }
        }
    }
    
    private func sendMessage() {
        let trimmedText = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedText.isEmpty {
            // Change Bubl to thinking while "processing"
            bublEmotion = .thinking
            
            // Add the user message
            viewModel.sendMessage(content: trimmedText)
            messageText = ""
            
            // After a delay, change back to happy when response arrives
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                bublEmotion = .happy
            }
        }
    }
}

// Message bubble component
struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isFromUser {
                Spacer()
                Text(message.content)
                    .padding(12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            } else {
                HStack(alignment: .bottom, spacing: 8) {
                    // Bubl avatar - replaced with our full animation in the top section
                    Image(systemName: "bubble.left.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.purple)
                    
                    Text(message.content)
                        .padding(12)
                        .background(Color(.systemGray5))
                        .foregroundColor(.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                Spacer()
            }
        }
    }
}

// View model to handle the chat logic
class TextChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    
    func addInitialMessages() {
        let welcomeMessage = ChatMessage(
            content: "Hello! I'm Bubl, your friendly AI companion. How can I help you today?",
            isFromUser: false
        )
        messages.append(welcomeMessage)
    }
    
    func sendMessage(content: String) {
        // Add user message
        let userMessage = ChatMessage(content: content, isFromUser: true)
        messages.append(userMessage)
        
        // Simulate Bubl's response after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.generateBublResponse(to: content)
        }
    }
    
    private func generateBublResponse(to userMessage: String) {
        // For now, we'll use simple predefined responses
        // Later, this will be replaced with API calls to the backend
        
        let bublResponses = [
            "That's interesting! Tell me more about that.",
            "I understand. How does that make you feel?",
            "Thanks for sharing that with me!",
            "I'm here to chat whenever you need me.",
            "What else would you like to talk about?",
            "I'm still learning, but I'm doing my best to be helpful!"
        ]
        
        // Pick a random response for now
        let randomIndex = Int.random(in: 0..<bublResponses.count)
        let responseText = bublResponses[randomIndex]
        
        let bublMessage = ChatMessage(content: responseText, isFromUser: false)
        self.messages.append(bublMessage)
    }
} 