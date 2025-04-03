import SwiftUI
import AudioToolbox

// Import the TextChat view - the syntax was incorrect
// Remove this import and just use a simple chat view to avoid complex import paths
// import BublChatApp.UI.TextChat

// Import our text shimmer components
import UIKit // Needed for UIImage

// ShimmeringText component for creating a text shimmer effect
struct ShimmeringText: View {
    let text: String
    let font: Font
    let baseColor: Color
    let shimmerColor: Color
    let duration: Double
    
    @State private var shimmerOffset: CGFloat = -400
    
    init(
        text: String,
        font: Font = .system(size: 36, weight: .bold),
        baseColor: Color = .white,
        shimmerColor: Color = Color(red: 0.5, green: 0.95, blue: 1.0),
        duration: Double = 3.5
    ) {
        self.text = text
        self.font = font
        self.baseColor = baseColor
        self.shimmerColor = shimmerColor
        self.duration = duration
    }
    
    var body: some View {
        ZStack {
            // Bold outline for depth
            Text(text)
                .font(font)
                .foregroundColor(Color.blue.opacity(0.6))
                .offset(x: 3, y: 3)
                .blur(radius: 3)
            
            // Base text layer
            Text(text)
                .font(font)
                .foregroundColor(baseColor)
            
            // Extended glow effect
            Text(text)
                .font(font)
                .foregroundColor(Color(red: 0.6, green: 0.95, blue: 1.0).opacity(0.5))
                .blur(radius: 10)
            
            // Primary shimmer layer with continuous loop - MUCH more visible now
            Text(text)
                .font(font)
                .foregroundColor(shimmerColor)
                .mask(
                    LinearGradient(
                        gradient: Gradient(
                            stops: [
                                .init(color: .clear, location: 0),
                                .init(color: .white, location: 0.1),
                                .init(color: .white, location: 0.3),
                                .init(color: .white, location: 0.5),
                                .init(color: .clear, location: 0.6)
                            ]
                        ),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .offset(x: shimmerOffset, y: 0)
                )
                
            // Bright highlight overlay - adds the metallic shine effect
            Text(text)
                .font(font)
                .foregroundColor(Color.white)
                .mask(
                    LinearGradient(
                        gradient: Gradient(
                            stops: [
                                .init(color: .clear, location: 0),
                                .init(color: .clear, location: 0.2),
                                .init(color: .white, location: 0.3),
                                .init(color: .clear, location: 0.4),
                                .init(color: .clear, location: 1)
                            ]
                        ),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .offset(x: shimmerOffset, y: 0)
                )
                
            // Outer glow for more dramatic effect - much brighter now
            Text(text)
                .font(font)
                .foregroundColor(Color(red: 0.7, green: 0.97, blue: 1.0))
                .blur(radius: 8)
                .mask(
                    LinearGradient(
                        gradient: Gradient(
                            stops: [
                                .init(color: .clear, location: 0),
                                .init(color: .clear, location: 0.15),
                                .init(color: .white, location: 0.3),
                                .init(color: .clear, location: 0.45),
                                .init(color: .clear, location: 1)
                            ]
                        ),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .offset(x: shimmerOffset, y: 0)
                )
                
            // Extra intense glow for maximum effect
            Text(text)
                .font(font)
                .foregroundColor(Color.white)
                .blur(radius: 3)
                .mask(
                    LinearGradient(
                        gradient: Gradient(
                            stops: [
                                .init(color: .clear, location: 0),
                                .init(color: .clear, location: 0.25),
                                .init(color: .white, location: 0.3),
                                .init(color: .clear, location: 0.35),
                                .init(color: .clear, location: 1)
                            ]
                        ),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .offset(x: shimmerOffset, y: 0)
                )
                .onAppear {
                    // Slower continuous shimmer animation
                    withAnimation(
                        Animation
                            .linear(duration: duration)
                            .repeatForever(autoreverses: false)
                    ) {
                        shimmerOffset = 400
                    }
                }
        }
    }
}

struct MainDashboardView: View {
    @State private var animateTextChat = false
    @State private var animateVoiceCall = false
    @State private var animateVideoCall = false
    @State private var userName = "Ben" 
    @State private var showGreeting = false // New state for greeting entrance animation
    
    // Animation properties for floating bubbles
    @State private var textChatOffset: CGSize = CGSize(width: 0, height: 0)
    @State private var voiceCallOffset: CGSize = CGSize(width: 0, height: 0)
    @State private var videoCallOffset: CGSize = CGSize(width: 0, height: 0)
    @State private var settingsOffset: CGSize = CGSize(width: 0, height: 0) // New for settings bubble
    @State private var characterOffset: CGSize = CGSize(width: 0, height: 0) // New for character bubble
    
    // POSITIONING CONTROLS
    // Adjust these values to control positioning of UI elements
    private let logoTopPadding: CGFloat = 70       // Lower value brings logo closer to top
    private let settingsYPosition: CGFloat = 70    // Controls settings bubble Y position
    private let logoToCharacterSpacing: CGFloat = 0  // Lower value brings character closer to logo
    
    // Character positioning
    private let characterSize: CGFloat = 200       // Controls the size of character bubble
    private let characterXOffset: CGFloat = 0      // Controls horizontal position (0 = center, negative = left)
    
    // Text positioning
    private let textTopPadding: CGFloat = 10       // Space between character and text
    
    // Interactive bubbles positioning
    private let bubblesSectionTopPadding: CGFloat = 60  // Increased to move bubbles down
    private let videoCallYOffset: CGFloat = 100     // Controls how far down the video bubble appears
    
    private let bottomPadding: CGFloat = 40       // Reduced for better overall spacing
    
    var body: some View {
        ZStack {
            // Background gradient - lighter blue from reference
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.1, green: 0.55, blue: 0.95),
                    Color(red: 0.15, green: 0.6, blue: 0.95)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Platform as background at the bottom
            if let _ = UIImage(named: "platform") {
                Image("platform")
                    .resizable()
                    .scaledToFill()
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                    .ignoresSafeArea()
            }
            
            VStack(spacing: 0) {
                // Top section with logo
                HStack {
                    Spacer() // Push logo to center
                    
                    if let _ = UIImage(named: "bubl-logo") {
                        Image("bubl-logo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 80)
                    } else {
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 80)
                            .foregroundColor(.white)
                    }
                    
                    Spacer() // Center alignment
                }
                .padding(.top, logoTopPadding) // ← ADJUST THIS to move logo up/down
                
                Spacer()
            }
            
            // Settings bubble (top right)
            if let _ = UIImage(named: "settings-icon") {
                Image("settings-icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 70)
                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 3)
                    .position(x: UIScreen.main.bounds.width - 50, y: settingsYPosition) // ← ADJUST THIS to move settings up/down
                    .offset(settingsOffset) // Add the floating animation offset
            }
            
            // Main content layout
            VStack {
                Spacer()
                    .frame(height: -70) // Adjusted from -80 to move content down slightly
                
                // AI Assistant character (centered)
                ZStack {
                    // Decorative bubbles - temporarily disabled
                    if false { // Changed to false to hide bubbles
                        if let _ = UIImage(named: "extra-bubbles") {
                            Image("extra-bubbles")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 180)
                                .opacity(0.7)
                                .offset(x: -40, y: -50)
                        } else {
                            // Fallback bubbles
                            ForEach(0..<5) { i in
                                Circle()
                                    .fill(Color.white.opacity(0.5))
                                    .frame(width: CGFloat([20, 16, 24, 18, 22][i % 5]), 
                                           height: CGFloat([20, 16, 24, 18, 22][i % 5]))
                                    .offset(x: CGFloat([-80, -60, -70, -50, -40][i % 5]), 
                                            y: CGFloat([-60, -80, -50, -40, -70][i % 5]))
                                    .opacity(0.7)
                            }
                        }
                    }
                        
                    // Main character
                    if let _ = UIImage(named: "bubl-character") {
                        Image("bubl-character")
                            .resizable()
                            .scaledToFit()
                            .frame(width: characterSize)
                    } else {
                        Image(systemName: "face.smiling.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: characterSize)
                            .foregroundColor(.white)
                    }
                }
                .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                .offset(x: characterXOffset) // Horizontal offset for character
                .offset(characterOffset) // Add the floating animation offset
                
                // Text below character (centered)
                VStack(spacing: 8) {
                    // Animated text entrance separate from shimmer effect
                    if showGreeting {
                        ShimmeringText(
                            text: "Hi \(userName)!",
                            font: .system(size: 36, weight: .bold),
                            baseColor: .white,
                            shimmerColor: Color(red: 0.7, green: 0.97, blue: 1.0), // Brighter blue
                            duration: 3.5 // Slower animation for more dramatic effect
                        )
                        .transition(.opacity.combined(with: .scale))
                    }
                }
                .padding(.top, textTopPadding)
                .multilineTextAlignment(.center)
                
                // Interactive bubbles in triangular arrangement
                ZStack {
                    // Text Chat bubble (left)
                    NavigationLink(destination: SimpleChatView()) {
                        bubbleButton(
                            icon: "message.fill",
                            iconImage: "text-chat-icon",
                            offset: textChatOffset,
                            isAnimated: animateTextChat
                        )
                    }
                    .simultaneousGesture(
                        TapGesture()
                            .onEnded { _ in
                                playBubbleSound()
                            }
                    )
                    .offset(x: -100, y: 10)
                    
                    // Voice Call bubble (right)
                    NavigationLink(destination: voiceCallPlaceholder) {
                        bubbleButton(
                            icon: "mic.fill", 
                            iconImage: "voice-call-icon",
                            offset: voiceCallOffset,
                            isAnimated: animateVoiceCall
                        )
                    }
                    .simultaneousGesture(
                        TapGesture()
                            .onEnded { _ in
                                playBubbleSound()
                            }
                    )
                    .offset(x: 100, y: 10)
                    
                    // Video Call bubble (bottom center in triangle)
                    NavigationLink(destination: videoCallPlaceholder) {
                        bubbleButton(
                            icon: "video.fill",
                            iconImage: "video-call-icon",
                            offset: videoCallOffset,
                            isAnimated: animateVideoCall
                        )
                    }
                    .simultaneousGesture(
                        TapGesture()
                            .onEnded { _ in
                                playBubbleSound()
                            }
                    )
                    .offset(x: 0, y: videoCallYOffset + 10)
                }
                
                Spacer()
                    .frame(height: bubblesSectionTopPadding)
            }
            .offset(y: -65)
            
            Spacer()
                .frame(height: bottomPadding) // ← ADJUST THIS to control space at bottom
        }
        .padding(.horizontal, 20)
        .onAppear {
            // Log image status for debugging
            print("Asset check:")
            print("- bubl-logo: \(UIImage(named: "bubl-logo") != nil)")
            print("- bubl-character: \(UIImage(named: "bubl-character") != nil)")
            print("- text-chat-icon: \(UIImage(named: "text-chat-icon") != nil)")
            
            // Animate greeting entrance after a short delay
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
                showGreeting = true
            }
            
            // Stagger feature bubble animations
            withAnimation(.spring().delay(0.3)) {
                animateTextChat = true
            }
            withAnimation(.spring().delay(0.5)) {
                animateVoiceCall = true
            }
            withAnimation(.spring().delay(0.7)) {
                animateVideoCall = true
            }
            
            // Start floating animations
            startFloatingAnimations()
        }
        .navigationBarHidden(true)
    }
    
    // Start the floating animations for all bubbles
    private func startFloatingAnimations() {
        // Vertical float for text chat bubble
        withAnimation(Animation.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
            textChatOffset = CGSize(width: 5, height: -10)
        }
        
        // Diagonal float for voice call bubble
        withAnimation(Animation.easeInOut(duration: 3.2).repeatForever(autoreverses: true)) {
            voiceCallOffset = CGSize(width: -5, height: -15)
        }
        
        // Circular-ish float for video call bubble
        withAnimation(Animation.easeInOut(duration: 3.4).repeatForever(autoreverses: true)) {
            videoCallOffset = CGSize(width: 5, height: -10)
        }
        
        // Gentle float for settings bubble
        withAnimation(Animation.easeInOut(duration: 3.8).repeatForever(autoreverses: true)) {
            settingsOffset = CGSize(width: 3, height: -8)
        }
        
        // Slow bobbing for character bubble
        withAnimation(Animation.easeInOut(duration: 4.5).repeatForever(autoreverses: true)) {
            characterOffset = CGSize(width: 0, height: -12)
        }
    }
    
    // Play bubble sound when tapped
    private func playBubbleSound() {
        let soundID = SystemSoundID(1104)
        AudioServicesPlaySystemSound(soundID)
    }
    
    // Bubble button with animation support
    private func bubbleButton(
        icon: String,
        iconImage: String,
        offset: CGSize,
        isAnimated: Bool
    ) -> some View {
        Group {
            if let _ = UIImage(named: iconImage) {
                // Use custom image if available with enhanced shadow for 3D effect
                Image(iconImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120) // Larger bubbles
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
            } else {
                // Fallback to SF Symbol with circular background
                ZStack {
                    // Bubble background with enhanced 3D effect
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.9),
                                    Color.white.opacity(0.5)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.4), lineWidth: 2)
                        )
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                    
                    // Feature icon
                    Image(systemName: icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 70, height: 70)
                        .foregroundColor(.blue)
                }
                .frame(width: 120, height: 120) // Larger bubbles
            }
        }
        .offset(y: isAnimated ? 0 : 200)
        .offset(offset)  // Add the animated offset
    }
    
    // Placeholder views to avoid import issues
    private var voiceCallPlaceholder: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.0, green: 0.47, blue: 0.9),
                    Color(red: 0.1, green: 0.6, blue: 0.95)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            Text("Voice Chat Coming Soon")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
    }
    
    private var videoCallPlaceholder: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.1, green: 0.3, blue: 0.8),
                    Color(red: 0.5, green: 0.2, blue: 0.8)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            Text("Video Chat Coming Soon")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
    }
}

// Simple chat view to use instead of potentially conflicting TextChatView
struct SimpleChatView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.0, green: 0.47, blue: 0.9),
                    Color(red: 0.1, green: 0.6, blue: 0.95)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack {
                Spacer()
                    .frame(height: 40)
                
                Text("Chat with Bubl")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.white.opacity(0.8))
                
                Text("Chat functionality coming soon!")
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .frame(width: 300)
                
                Spacer()
            }
        }
        .navigationTitle("Chat")
    }
}
