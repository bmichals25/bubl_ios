import SwiftUI

struct VoiceCallPlaceholderView: View {
    @State private var isListening = false
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Animated Bubl avatar
            BublAnimationView(emotion: isListening ? .listening : .happy)
                .frame(width: 200, height: 200)
            
            Text(isListening ? "Listening..." : "Talk to Bubl")
                .font(.title)
                .fontWeight(.medium)
            
            Text("Tap the microphone to start speaking with Bubl")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
            
            // Microphone button
            Button(action: {
                withAnimation {
                    isListening.toggle()
                }
                
                // Simulate listening and response
                if isListening {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation {
                            isListening = false
                        }
                    }
                }
            }) {
                Image(systemName: isListening ? "waveform" : "mic.fill")
                    .font(.system(size: 30))
                    .foregroundColor(.white)
                    .padding(30)
                    .background(Color.green)
                    .clipShape(Circle())
                    .shadow(color: Color.green.opacity(0.4), radius: 10, x: 0, y: 5)
                    .scaleEffect(isListening ? 1.1 : 1.0)
            }
            .padding(.bottom, 50)
        }
        .navigationTitle("Talk to Bubl")
    }
} 