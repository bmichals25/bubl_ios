import SwiftUI
import AudioToolbox
import UIKit // Needed for UIImage

/*
 ANIMATION CUSTOMIZATION GUIDE
 -----------------------------
 To modify the bubble animations:
 
 1. Find the "ANIMATION CONFIGURATION" section in the code
 2. Adjust these key parameters:

    STARTING POSITIONS:
    - chatBubbleStartX/Y: The starting position of the text chat bubble
    - voiceBubbleStartX/Y: The starting position of the voice call bubble
    - videoBubbleStartX/Y: The starting position of the video call bubble
    - settingsBubbleStartX/Y: The starting position of the settings bubble
    
    LANDING POSITIONS:
    - chatBubbleLandingX/Y: Where the text chat bubble lands when animated
    - voiceBubbleLandingX/Y: Where the voice call bubble lands when animated
    - videoBubbleLandingX/Y: Where the video call bubble lands when animated
    - settingsBubbleLandingX/Y: Where the settings bubble lands when animated
    
    ANIMATION APPEARANCE:
    - bubbleTargetScale: How much each bubble shrinks when animated (0.5-1.0 recommended)
    - animationResponseSpeed: Speed of the animation (lower = faster)
    - animationDamping: Bounce effect (lower = more bounce)
    - elementsFadeSpeed: How quickly other elements fade out
 
 No need to modify complex animation calculations - just change these parameters!
 */

// Make BublChatView available directly in this file scope since it can't find it
// We'll use our existing view implementation but include it as a local declaration
// This avoids cross-module or import errors

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
    
    // Chat state control
    @State private var isChatActive = false
    @State private var chatIconPosition = CGPoint(x: 0, y: 0)
    @State private var chatMessages: [SimpleChatMessage] = []
    @State private var messageText = ""
    @State private var isTyping = false
    @State private var chatBubbleSize: CGFloat = 120 // Size of chat bubble before animation
    @State private var logoPosition: CGPoint = .zero // Track the logo position
    
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
    
    // =====================================================
    // ANIMATION CONFIGURATION - EDIT THESE VALUES AS NEEDED
    // =====================================================
    
    // STARTING POSITIONS
    // - Starting position for each bubble
    @State private var chatBubbleStartX: CGFloat = UIScreen.main.bounds.width / 2 - 150  // From center
    @State private var chatBubbleStartY: CGFloat = UIScreen.main.bounds.height - 200     // From bottom
    @State private var voiceBubbleStartX: CGFloat = UIScreen.main.bounds.width / 2 + 100  // From center right
    @State private var voiceBubbleStartY: CGFloat = UIScreen.main.bounds.height - 200     // From bottom
    @State private var videoBubbleStartX: CGFloat = UIScreen.main.bounds.width / 2         // Center
    @State private var videoBubbleStartY: CGFloat = UIScreen.main.bounds.height - 100     // From bottom, lower
    @State private var settingsBubbleStartX: CGFloat = UIScreen.main.bounds.width - 50     // Right side
    @State private var settingsBubbleStartY: CGFloat = 70                                  // Top
    
    // LANDING POSITIONS 
    // - Position where each bubble lands after animation
    private let chatBubbleLandingX: CGFloat = UIScreen.main.bounds.width / 2 - 150    // Left side
    private let chatBubbleLandingY: CGFloat = 100                                   // From top of screen
    private let voiceBubbleLandingX: CGFloat = UIScreen.main.bounds.width / 2 + 100    // Right side
    private let voiceBubbleLandingY: CGFloat = 100                                   // From top of screen
    private let videoBubbleLandingX: CGFloat = UIScreen.main.bounds.width / 2         // Center
    private let videoBubbleLandingY: CGFloat = 200                                   // From top of screen
    private let settingsBubbleLandingX: CGFloat = UIScreen.main.bounds.width - 210     // Right side
    private let settingsBubbleLandingY: CGFloat = 210                                 // From top of screen
    
    // Animation properties
    private let bubbleTargetScale: CGFloat = 0.8  // Size scaling factor (0.5-1.0 recommended)
    private let settingsBubbleTargetScale: CGFloat = 1.5  // Larger scale factor specifically for settings
    private let animationResponseSpeed: Double = 0.5  // Speed of animation (lower = faster)
    private let animationDamping: Double = 0.7  // Bounce effect (lower = more bounce)
    private let elementsFadeSpeed: Double = 0.3  // How quickly other elements fade out
    
    // Animation state tracking
    @State private var animatingToChat = false 
    @State private var animatingToVoice = false 
    @State private var animatingToVideo = false 
    @State private var animatingToSettings = false 
    
    // Bubble positions
    @State private var chatBubblePosition: CGPoint = .zero
    @State private var voiceBubblePosition: CGPoint = .zero
    @State private var videoBubblePosition: CGPoint = .zero
    @State private var settingsBubblePosition: CGPoint = .zero
    
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
                            .opacity(animatingToChat || animatingToVoice || animatingToVideo || animatingToSettings ? 0 : 1)
                            .animation(.easeOut(duration: elementsFadeSpeed), value: animatingToChat || animatingToVoice || animatingToVideo || animatingToSettings)
                            .background(
                                GeometryReader { geo -> Color in
                                    DispatchQueue.main.async {
                                        // Get the center of the logo
                                        let frame = geo.frame(in: .global)
                                        logoPosition = CGPoint(x: frame.midX, y: frame.midY)
                                    }
                                    return Color.clear
                                }
                            )
                    } else {
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 80)
                            .foregroundColor(.white)
                            .opacity(animatingToChat || animatingToVoice || animatingToVideo || animatingToSettings ? 0 : 1)
                            .animation(.easeOut(duration: elementsFadeSpeed), value: animatingToChat || animatingToVoice || animatingToVideo || animatingToSettings)
                            .background(
                                GeometryReader { geo -> Color in
                                    DispatchQueue.main.async {
                                        // Get the center of the logo
                                        let frame = geo.frame(in: .global)
                                        logoPosition = CGPoint(x: frame.midX, y: frame.midY)
                                    }
                                    return Color.clear
                                }
                            )
                    }
                    
                    Spacer() // Center alignment
                }
                .padding(.top, logoTopPadding) // ← ADJUST THIS to move logo up/down
                
                Spacer()
            }
            
            // Settings bubble (top right)
            if let _ = UIImage(named: "settings-icon") {
                Button(action: {
                    // Capture current position for animation
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.prepare()
                    generator.impactOccurred()
                    
                    // Play sound
                    playBubbleSound()
                    
                    // Start transition animation
                    withAnimation(.spring(response: animationResponseSpeed, dampingFraction: animationDamping)) {
                        animatingToSettings = true
                    }
                }) {
                    Image("settings-icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 70)
                        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 3)
                        .background(
                            GeometryReader { geo -> Color in
                                DispatchQueue.main.async {
                                    let frame = geo.frame(in: .global)
                                    settingsBubblePosition = CGPoint(x: frame.midX, y: frame.midY)
                                }
                                return Color.clear
                            }
                        )
                }
                .position(x: UIScreen.main.bounds.width - 50, y: settingsYPosition)
                .offset(settingsOffset) // Floating animation offset
                .offset(x: animatingToSettings ? (settingsBubbleLandingX - settingsBubbleStartX) : 0,
                        y: animatingToSettings ? (settingsBubbleLandingY - settingsBubbleStartY) : 0)
                .scaleEffect(animatingToSettings ? settingsBubbleTargetScale : 1.0)
                .animation(.spring(response: animationResponseSpeed, dampingFraction: animationDamping), value: animatingToSettings)
                .zIndex(animatingToSettings ? 100 : 0)
                .opacity(animatingToChat || animatingToVoice || animatingToVideo ? 0 : 1)
                .animation(.easeOut(duration: elementsFadeSpeed), value: animatingToChat || animatingToVoice || animatingToVideo)
            }
            
            // Main content layout
            VStack {
                Spacer()
                    .frame(height: 30) // Use a positive value
                
                // AI Assistant character (centered)
                ZStack {
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
                .opacity(animatingToChat || animatingToVoice || animatingToVideo || animatingToSettings ? 0 : 1)
                .animation(.easeOut(duration: elementsFadeSpeed), value: animatingToChat || animatingToVoice || animatingToVideo || animatingToSettings)
                
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
                .opacity(animatingToChat || animatingToVoice || animatingToVideo || animatingToSettings ? 0 : 1)
                .animation(.easeOut(duration: elementsFadeSpeed), value: animatingToChat || animatingToVoice || animatingToVideo || animatingToSettings)
                
                // Interactive bubbles in triangular arrangement
                ZStack {
                    // Text Chat bubble (left)
                    Button(action: {
                        // Capture current position of chat bubble for animation
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.prepare()
                        generator.impactOccurred()
                        
                        // Play sound
                        playBubbleSound()
                        
                        // Start transition animation to move bubble to target position
                        withAnimation(.spring(response: animationResponseSpeed, dampingFraction: animationDamping)) {
                            animatingToChat = true
                        }
                    }) {
                        bubbleButton(
                            icon: "message.fill",
                            iconImage: "text-chat-icon",
                            offset: textChatOffset,
                            isAnimated: animateTextChat
                        )
                    }
                    .background(
                        GeometryReader { geo -> Color in
                            DispatchQueue.main.async {
                                // Get the center of the chat bubble for animation
                                let frame = geo.frame(in: .global)
                                chatBubblePosition = CGPoint(x: frame.midX, y: frame.midY)
                            }
                            return Color.clear
                        }
                    )
                    // Initial position before animation starts
                    .offset(x: -100, y: 10)
                    // Animation offset (applies when animating)
                    .offset(x: animatingToChat ? (chatBubbleLandingX - chatBubbleStartX + 100) : 0,
                            y: animatingToChat ? (chatBubbleLandingY - chatBubbleStartY - 10) : 0)
                    .scaleEffect(animatingToChat ? bubbleTargetScale : 1.0)
                    .animation(.spring(response: animationResponseSpeed, dampingFraction: animationDamping), value: animatingToChat)
                    .zIndex(animatingToChat ? 100 : 0)
                    .opacity(animatingToVoice || animatingToVideo || animatingToSettings ? 0 : 1)
                    .animation(.easeOut(duration: elementsFadeSpeed), value: animatingToVoice || animatingToVideo || animatingToSettings)
                    
                    // Voice Call bubble (right)
                    Button(action: {
                        // Capture current position for animation
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.prepare()
                        generator.impactOccurred()
                        
                        // Play sound
                        playBubbleSound()
                        
                        // Start transition animation
                        withAnimation(.spring(response: animationResponseSpeed, dampingFraction: animationDamping)) {
                            animatingToVoice = true
                        }
                    }) {
                        bubbleButton(
                            icon: "mic.fill", 
                            iconImage: "voice-call-icon",
                            offset: voiceCallOffset,
                            isAnimated: animateVoiceCall
                        )
                    }
                    .background(
                        GeometryReader { geo -> Color in
                            DispatchQueue.main.async {
                                let frame = geo.frame(in: .global)
                                voiceBubblePosition = CGPoint(x: frame.midX, y: frame.midY)
                            }
                            return Color.clear
                        }
                    )
                    .offset(x: 100, y: 10)
                    .offset(x: animatingToVoice ? (voiceBubbleLandingX - voiceBubbleStartX - 100) : 0,
                            y: animatingToVoice ? (voiceBubbleLandingY - voiceBubbleStartY - 10) : 0)
                    .scaleEffect(animatingToVoice ? bubbleTargetScale : 1.0)
                    .animation(.spring(response: animationResponseSpeed, dampingFraction: animationDamping), value: animatingToVoice)
                    .zIndex(animatingToVoice ? 100 : 0)
                    .opacity(animatingToChat || animatingToVideo || animatingToSettings ? 0 : 1)
                    .animation(.easeOut(duration: elementsFadeSpeed), value: animatingToChat || animatingToVideo || animatingToSettings)
                    
                    // Video Call bubble (bottom center in triangle)
                    Button(action: {
                        // Capture current position for animation
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.prepare()
                        generator.impactOccurred()
                        
                        // Play sound
                        playBubbleSound()
                        
                        // Start transition animation
                        withAnimation(.spring(response: animationResponseSpeed, dampingFraction: animationDamping)) {
                            animatingToVideo = true
                        }
                    }) {
                        bubbleButton(
                            icon: "video.fill",
                            iconImage: "video-call-icon",
                            offset: videoCallOffset,
                            isAnimated: animateVideoCall
                        )
                    }
                    .background(
                        GeometryReader { geo -> Color in
                            DispatchQueue.main.async {
                                let frame = geo.frame(in: .global)
                                videoBubblePosition = CGPoint(x: frame.midX, y: frame.midY)
                            }
                            return Color.clear
                        }
                    )
                    .offset(x: 0, y: videoCallYOffset + 10)
                    .offset(x: animatingToVideo ? (videoBubbleLandingX - videoBubbleStartX) : 0,
                            y: animatingToVideo ? (videoBubbleLandingY - videoBubbleStartY - videoCallYOffset - 10) : 0)
                    .scaleEffect(animatingToVideo ? bubbleTargetScale : 1.0)
                    .animation(.spring(response: animationResponseSpeed, dampingFraction: animationDamping), value: animatingToVideo)
                    .zIndex(animatingToVideo ? 100 : 0)
                    .opacity(animatingToChat || animatingToVoice || animatingToSettings ? 0 : 1)
                    .animation(.easeOut(duration: elementsFadeSpeed), value: animatingToChat || animatingToVoice || animatingToSettings)
                }
                
                Spacer()
                    .frame(height: bubblesSectionTopPadding)
            }
            .offset(y: 10) // Changed from 0 to 10 to ensure positive value
            
            // Add back buttons for each animated state
            if animatingToChat || animatingToVoice || animatingToVideo || animatingToSettings {
                VStack {
                    HStack {
                        Button(action: {
                            // Add haptic feedback
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.prepare()
                            generator.impactOccurred()
                            
                            // Reset animation state with animation
                            withAnimation(.spring(response: animationResponseSpeed, dampingFraction: animationDamping)) {
                                animatingToChat = false
                                animatingToVoice = false
                                animatingToVideo = false
                                animatingToSettings = false
                            }
                        }) {
                            Image(systemName: "arrow.left")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Circle().fill(Color.white.opacity(0.2)))
                                .shadow(color: Color.black.opacity(0.2), radius: 3, x: 0, y: 2)
                        }
                        .padding(.leading, 16)
                        
                        Spacer()
                    }
                    .padding(.top, 50)
                    
                    Spacer()
                }
                .transition(.opacity.combined(with: .move(edge: .leading)))
                .animation(.easeInOut(duration: elementsFadeSpeed).delay(0.2), value: animatingToChat || animatingToVoice || animatingToVideo || animatingToSettings)
            }
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
    
    // MARK: - Chat Interface
    private var chatInterface: some View {
        VStack(spacing: 0) {
            // Navigation header with buttons
            ZStack {
                Rectangle()
                    .fill(Color(red: 0.0, green: 0.47, blue: 0.9))
                    .frame(height: 100)
                
                VStack {
                    HStack {
                        // Back button
                        Button(action: {
                            // Reset animation state with animation
                            withAnimation(.spring(response: animationResponseSpeed, dampingFraction: animationDamping)) {
                                animatingToChat = false
                            }
                        }) {
                            Image(systemName: "arrow.left")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Circle().fill(Color.white.opacity(0.2)))
                        }
                        .padding(.leading, 16)
                        
                        Spacer()
                        
                        // Notes button
                        Button(action: {
                            // Notes action
                        }) {
                            Image(systemName: "note.text")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Circle().fill(Color.white.opacity(0.2)))
                        }
                        .padding(.trailing, 12)
                        
                        // Settings button
                        Button(action: {
                            // Settings action
                        }) {
                            Image(systemName: "gearshape")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Circle().fill(Color.white.opacity(0.2)))
                        }
                        .padding(.trailing, 16)
                    }
                    .padding(.top, 50)
                    
                    // Center menu button - appears with animation
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.0, green: 0.8, blue: 0.9).opacity(0.6), 
                                        Color(red: 0.5, green: 0.4, blue: 0.9).opacity(0.4)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 70, height: 70)
                            .shadow(color: Color.black.opacity(0.2), radius: 5)
                        
                        Image(systemName: "bubble.left.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.white)
                    }
                    .offset(y: 35)
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .ignoresSafeArea(edges: .top)
            
            // Chat message area with gradient background
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
                
                // Messages ScrollView
                ScrollViewReader { scrollView in
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(chatMessages) { message in
                                MessageBubbleView(message: message)
                                    .padding(.horizontal, 16)
                            }
                            
                            // Typing indicator for Bubl
                            if isTyping {
                                HStack(alignment: .top) {
                                    // Bubl avatar
                                    Image(systemName: "face.smiling.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 30, height: 30)
                                        .clipShape(Circle())
                                        .foregroundColor(.blue)
                                        .background(Circle().fill(Color.white))
                                        .padding(.top, 2)
                                    
                                    // Typing animation dots
                                    HStack(spacing: 4) {
                                        ForEach(0..<3) { index in
                                            Circle()
                                                .fill(Color.gray)
                                                .frame(width: 8, height: 8)
                                                .opacity(0.7)
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(Color.white.opacity(0.85))
                                    .cornerRadius(16)
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .id("typingIndicator")
                            }
                            
                            // Invisible element to allow scrolling to bottom
                            Color.clear
                                .frame(height: 1)
                                .id("bottomID")
                        }
                        .padding(.top, 60)
                        .padding(.bottom, 16)
                    }
                    .onChange(of: chatMessages.count) { _ in
                        withAnimation {
                            scrollView.scrollTo("bottomID", anchor: .bottom)
                        }
                    }
                    .onChange(of: isTyping) { _ in
                        if isTyping {
                            withAnimation {
                                scrollView.scrollTo("typingIndicator", anchor: .bottom)
                            }
                        }
                    }
                }
            }
            
            // Input area
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    // Plus button
                    Button(action: {
                        // Add attachment action
                    }) {
                        Image(systemName: "plus")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.gray)
                    }
                    .padding(.leading, 16)
                    
                    // Message input field
                    ZStack(alignment: .leading) {
                        if messageText.isEmpty {
                            Text("Message Bubl...")
                                .foregroundColor(Color.gray.opacity(0.8))
                                .padding(.leading, 8)
                        }
                        
                        TextField("", text: $messageText, onCommit: {
                            sendMessage()
                        })
                        .padding(.horizontal, 8)
                        .padding(.vertical, 12)
                    }
                    .background(Color.white)
                    .cornerRadius(30)
                    .padding(.vertical, 8)
                    
                    // Send button
                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Circle().fill(Color.blue))
                    }
                    .disabled(messageText.isEmpty)
                    .padding(.trailing, 16)
                }
                .padding(.vertical, 8)
                .background(Color.white)
            }
        }
    }
    
    // Add a message from the user
    private func sendMessage() {
        guard !messageText.isEmpty else { return }
        
        let userMessage = SimpleChatMessage(
            content: messageText,
            isFromUser: true
        )
        
        chatMessages.append(userMessage)
        let userMessageText = messageText
        messageText = ""
        
        // Show typing indicator
        isTyping = true
        
        // Simulate response after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 1.2...2.5)) {
            isTyping = false
            respondToUserMessage(userMessageText)
        }
    }
    
    // Generate a response based on user message
    private func respondToUserMessage(_ userMessage: String) {
        let lowerMessage = userMessage.lowercased()
        var response = ""
        
        // Simple response logic based on keywords
        if lowerMessage.contains("hello") || lowerMessage.contains("hi") {
            response = "Hello! It's great to chat with you! How are you feeling today?"
        } else if lowerMessage.contains("how are you") {
            response = "I'm doing great, thanks for asking! I'm always happy to chat with you."
        } else if lowerMessage.contains("help") {
            response = "I can help with many things! You can ask me questions, chat about your day, or just talk about whatever's on your mind."
        } else if lowerMessage.contains("thank") {
            response = "You're very welcome! Is there anything else I can help with?"
        } else if lowerMessage.contains("bye") || lowerMessage.contains("goodbye") {
            response = "Goodbye for now! Feel free to chat again anytime. I'll be here!"
        } else {
            // Default responses for other messages
            let defaultResponses = [
                "That's interesting! Tell me more about that.",
                "I see! What else is on your mind?",
                "Thanks for sharing that with me!",
                "I understand. How does that make you feel?",
                "That's good to know! Is there anything specific you'd like to chat about?",
                "I'm here to listen anytime you want to talk."
            ]
            response = defaultResponses.randomElement() ?? "Tell me more!"
        }
        
        addBublMessage(response)
    }
    
    // Add a message from Bubl
    private func addBublMessage(_ content: String) {
        let bublMessage = SimpleChatMessage(
            content: content,
            isFromUser: false
        )
        
        chatMessages.append(bublMessage)
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
    
    // Bubble button with animation support - modified for smoother animations
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
        .animation(.interpolatingSpring(stiffness: 170, damping: 15).delay(0.2), value: animatingToChat)
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

// Simple implementation of BublChatView to avoid import conflicts
struct BublSimpleChatView: View {
    @State private var messageText = ""
    @State private var chatMessages: [SimpleChatMessage] = []
    @State private var isTyping = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 0) {
            // Navigation header with buttons
            ZStack {
                Rectangle()
                    .fill(Color(red: 0.0, green: 0.47, blue: 0.9))
                    .frame(height: 100)
                
                VStack {
                    HStack {
                        // Back button
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "arrow.left")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Circle().fill(Color.white.opacity(0.2)))
                        }
                        .padding(.leading, 16)
                        
                        Spacer()
                        
                        // Notes button
                        Button(action: {
                            // Notes action
                        }) {
                            Image(systemName: "note.text")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Circle().fill(Color.white.opacity(0.2)))
                        }
                        .padding(.trailing, 12)
                        
                        // Settings button
                        Button(action: {
                            // Settings action
                        }) {
                            Image(systemName: "gearshape")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Circle().fill(Color.white.opacity(0.2)))
                        }
                        .padding(.trailing, 16)
                    }
                    .padding(.top, 50)
                    
                    // Center menu button
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.0, green: 0.8, blue: 0.9).opacity(0.6), 
                                        Color(red: 0.5, green: 0.4, blue: 0.9).opacity(0.4)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 70, height: 70)
                            .shadow(color: Color.black.opacity(0.2), radius: 5)
                        
                        Image(systemName: "bubble.left.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.white)
                    }
                    .offset(y: 35)
                }
            }
            .ignoresSafeArea(edges: .top)
            
            // Chat message area with gradient background
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
                
                // Messages ScrollView
                ScrollViewReader { scrollView in
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(chatMessages) { message in
                                MessageBubbleView(message: message)
                                    .padding(.horizontal, 16)
                            }
                            
                            // Typing indicator for Bubl
                            if isTyping {
                                HStack(alignment: .top) {
                                    // Bubl avatar
                                    Image(systemName: "face.smiling.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 30, height: 30)
                                        .clipShape(Circle())
                                        .foregroundColor(.blue)
                                        .background(Circle().fill(Color.white))
                                        .padding(.top, 2)
                                    
                                    // Typing animation dots
                                    HStack(spacing: 4) {
                                        ForEach(0..<3) { index in
                                            Circle()
                                                .fill(Color.gray)
                                                .frame(width: 8, height: 8)
                                                .opacity(0.7)
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(Color.white.opacity(0.85))
                                    .cornerRadius(16)
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .id("typingIndicator")
                            }
                            
                            // Invisible element to allow scrolling to bottom
                            Color.clear
                                .frame(height: 1)
                                .id("bottomID")
                        }
                        .padding(.top, 60)
                        .padding(.bottom, 16)
                    }
                    .onChange(of: chatMessages.count) { _ in
                        withAnimation {
                            scrollView.scrollTo("bottomID", anchor: .bottom)
                        }
                    }
                    .onChange(of: isTyping) { _ in
                        if isTyping {
                            withAnimation {
                                scrollView.scrollTo("typingIndicator", anchor: .bottom)
                            }
                        }
                    }
                }
            }
            
            // Input area
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    // Plus button
                    Button(action: {
                        // Add attachment action
                    }) {
                        Image(systemName: "plus")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.gray)
                    }
                    .padding(.leading, 16)
                    
                    // Message input field
                    ZStack(alignment: .leading) {
                        if messageText.isEmpty {
                            Text("Message Bubl...")
                                .foregroundColor(Color.gray.opacity(0.8))
                                .padding(.leading, 8)
                        }
                        
                        TextField("", text: $messageText, onCommit: {
                            sendMessage()
                        })
                        .padding(.horizontal, 8)
                        .padding(.vertical, 12)
                    }
                    .background(Color.white)
                    .cornerRadius(30)
                    .padding(.vertical, 8)
                    
                    // Send button
                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Circle().fill(Color.blue))
                    }
                    .disabled(messageText.isEmpty)
                    .padding(.trailing, 16)
                }
                .padding(.vertical, 8)
                .background(Color.white)
            }
        }
        .onAppear {
            // Add initial greeting message from Bubl
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                addBublMessage("👋 Hi there! I'm Bubl, your AI companion. How can I help you today?")
            }
        }
        .navigationBarHidden(true)
    }
    
    // Add a message from the user
    private func sendMessage() {
        guard !messageText.isEmpty else { return }
        
        let userMessage = SimpleChatMessage(
            content: messageText,
            isFromUser: true
        )
        
        chatMessages.append(userMessage)
        let userMessageText = messageText
        messageText = ""
        
        // Show typing indicator
        isTyping = true
        
        // Simulate response after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 1.2...2.5)) {
            isTyping = false
            respondToUserMessage(userMessageText)
        }
    }
    
    // Generate a response based on user message
    private func respondToUserMessage(_ userMessage: String) {
        let lowerMessage = userMessage.lowercased()
        var response = ""
        
        // Simple response logic based on keywords
        if lowerMessage.contains("hello") || lowerMessage.contains("hi") {
            response = "Hello! It's great to chat with you! How are you feeling today?"
        } else if lowerMessage.contains("how are you") {
            response = "I'm doing great, thanks for asking! I'm always happy to chat with you."
        } else if lowerMessage.contains("help") {
            response = "I can help with many things! You can ask me questions, chat about your day, or just talk about whatever's on your mind."
        } else if lowerMessage.contains("thank") {
            response = "You're very welcome! Is there anything else I can help with?"
        } else if lowerMessage.contains("bye") || lowerMessage.contains("goodbye") {
            response = "Goodbye for now! Feel free to chat again anytime. I'll be here!"
        } else {
            // Default responses for other messages
            let defaultResponses = [
                "That's interesting! Tell me more about that.",
                "I see! What else is on your mind?",
                "Thanks for sharing that with me!",
                "I understand. How does that make you feel?",
                "That's good to know! Is there anything specific you'd like to chat about?",
                "I'm here to listen anytime you want to talk."
            ]
            response = defaultResponses.randomElement() ?? "Tell me more!"
        }
        
        addBublMessage(response)
    }
    
    // Add a message from Bubl
    private func addBublMessage(_ content: String) {
        let bublMessage = SimpleChatMessage(
            content: content,
            isFromUser: false
        )
        
        chatMessages.append(bublMessage)
    }
}

// Simple chat message model to avoid conflicts
struct SimpleChatMessage: Identifiable {
    let id = UUID()
    let content: String
    let isFromUser: Bool
    let timestamp: Date = Date()
}

// Message bubble view component
struct MessageBubbleView: View {
    let message: SimpleChatMessage
    
    var body: some View {
        HStack(alignment: .top) {
            if !message.isFromUser {
                // Avatar for Bubl
                Image(systemName: "face.smiling.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .clipShape(Circle())
                    .foregroundColor(.blue)
                    .background(Circle().fill(Color.white))
                    .padding(.top, 2)
                
                // Message bubble
                Text(message.content)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.white.opacity(0.85))
                    .foregroundColor(.black)
                    .cornerRadius(16)
                
                Spacer()
            } else {
                Spacer()
                
                // User message bubble
                Text(message.content)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(red: 0.8, green: 0.95, blue: 1.0))
                    .foregroundColor(.black)
                    .cornerRadius(16)
            }
        }
    }
} 