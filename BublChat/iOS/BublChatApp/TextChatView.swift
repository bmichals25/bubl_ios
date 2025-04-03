import SwiftUI
import Foundation

// Remove the problematic import
// import struct BublChatApp.ChatMessage

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
            
            // Conversation title if available
            if let conversation = viewModel.currentConversation {
                Text(conversation.title)
                    .font(.headline)
                    .padding(.top, 4)
            }
            
            // Bubl animation at the top
            BublAnimationView(emotion: bublEmotion)
                .frame(width: 120, height: 120)
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
                    .onTapGesture { /* Keep keyboard focus */ }
                
                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.blue)
                }
                .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
        }
        .navigationTitle("Text Bubl")
        .onAppear {
            // Try to load existing conversations first
            viewModel.loadConversations()
            
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
                    // Bubl avatar - small icon next to messages
                    Image(systemName: "bubble.left.fill")
                        .font(.system(size: 24))
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
