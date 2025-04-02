import SwiftUI

struct BublAnimationView: View {
    @State private var scale: CGFloat = 1.0
    @State private var rotation: Double = 0.0
    @State private var isAnimating = false
    var emotion: BublEmotion = .happy
    
    var body: some View {
        ZStack {
            // Bubble shape
            Circle()
                .fill(LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.7),
                        Color.purple.opacity(0.7)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 120, height: 120)
                .scaleEffect(scale)
                .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
            
            // Face based on emotion
            bublFace
                .scaleEffect(0.6)
        }
        .onAppear {
            startBubbleAnimation()
        }
    }
    
    var bublFace: some View {
        Group {
            switch emotion {
            case .happy:
                HappyFace()
            case .thinking:
                ThinkingFace()
            case .surprised:
                SurprisedFace()
            case .confused:
                ConfusedFace()
            }
        }
    }
    
    func startBubbleAnimation() {
        isAnimating = true
        
        // Continuous subtle breathing animation
        withAnimation(Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            scale = 1.05
        }
        
        // Slow rotation only for thinking emotion
        if emotion == .thinking {
            withAnimation(Animation.linear(duration: 8.0).repeatForever(autoreverses: false)) {
                rotation = 360.0
            }
        }
    }
}

// Face components
struct HappyFace: View {
    var body: some View {
        ZStack {
            // Eyes
            HStack(spacing: 40) {
                Circle()
                    .fill(Color.white)
                    .frame(width: 24, height: 24)
                    .overlay(
                        Circle()
                            .fill(Color.black)
                            .frame(width: 12, height: 12)
                    )
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 24, height: 24)
                    .overlay(
                        Circle()
                            .fill(Color.black)
                            .frame(width: 12, height: 12)
                    )
            }
            
            // Mouth - happy curve
            Path { path in
                path.move(to: CGPoint(x: -30, y: 30))
                path.addQuadCurve(to: CGPoint(x: 30, y: 30), control: CGPoint(x: 0, y: 50))
            }
            .stroke(Color.white, lineWidth: 5)
        }
    }
}

struct ThinkingFace: View {
    var body: some View {
        ZStack {
            // Eyes
            HStack(spacing: 40) {
                Circle()
                    .fill(Color.white)
                    .frame(width: 24, height: 24)
                    .overlay(
                        Circle()
                            .fill(Color.black)
                            .frame(width: 10, height: 10)
                            .offset(y: -2)
                    )
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 24, height: 24)
                    .overlay(
                        Circle()
                            .fill(Color.black)
                            .frame(width: 10, height: 10)
                            .offset(y: -2)
                    )
            }
            
            // Mouth - straight line with slight curve
            Path { path in
                path.move(to: CGPoint(x: -20, y: 30))
                path.addQuadCurve(to: CGPoint(x: 20, y: 30), control: CGPoint(x: 0, y: 35))
            }
            .stroke(Color.white, lineWidth: 4)
            
            // Thinking bubble
            Circle()
                .fill(Color.white)
                .frame(width: 12, height: 12)
                .offset(x: 50, y: -20)
        }
    }
}

struct SurprisedFace: View {
    var body: some View {
        ZStack {
            // Eyes - wide open
            HStack(spacing: 40) {
                Circle()
                    .fill(Color.white)
                    .frame(width: 28, height: 28)
                    .overlay(
                        Circle()
                            .fill(Color.black)
                            .frame(width: 16, height: 16)
                    )
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 28, height: 28)
                    .overlay(
                        Circle()
                            .fill(Color.black)
                            .frame(width: 16, height: 16)
                    )
            }
            
            // Mouth - small O shape
            Circle()
                .fill(Color.white)
                .frame(width: 20, height: 20)
                .offset(y: 35)
        }
    }
}

struct ConfusedFace: View {
    var body: some View {
        ZStack {
            // Eyes - one squinting
            HStack(spacing: 40) {
                // Squinted eye
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white)
                    .frame(width: 20, height: 8)
                
                // Normal eye
                Circle()
                    .fill(Color.white)
                    .frame(width: 24, height: 24)
                    .overlay(
                        Circle()
                            .fill(Color.black)
                            .frame(width: 12, height: 12)
                    )
            }
            
            // Mouth - zigzag line
            Path { path in
                path.move(to: CGPoint(x: -30, y: 30))
                path.addLine(to: CGPoint(x: -10, y: 35))
                path.addLine(to: CGPoint(x: 10, y: 25))
                path.addLine(to: CGPoint(x: 30, y: 30))
            }
            .stroke(Color.white, lineWidth: 4)
        }
    }
}

// Bubl emotions enum
enum BublEmotion {
    case happy
    case thinking
    case surprised
    case confused
}

struct BublAnimationView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 30) {
            BublAnimationView(emotion: .happy)
            BublAnimationView(emotion: .thinking)
            BublAnimationView(emotion: .surprised)
            BublAnimationView(emotion: .confused)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
} 