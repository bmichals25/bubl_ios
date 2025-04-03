import SwiftUI

struct HomeSelectionView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header with app name and logo
                Text("Bubl")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.blue)
                    .padding(.top, 30)
                
                // Bubl animation in the center
                BublAnimationView(emotion: .happy)
                    .frame(width: 120, height: 120)
                    .padding(.vertical, 10)
                
                Text("Your AI Companion")
                    .font(.title2)
                    .foregroundColor(.gray)
                    .padding(.bottom, 20)
                
                // Greeting message
                Text("How would you like to connect today?")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 20)
                
                // Icon buttons for different interaction modes
                VStack(spacing: 16) {
                    // Text chat button
                    NavigationLink(destination: TextChatView()) {
                        OptionButton(
                            title: "Text Bubl",
                            systemImage: "message.fill",
                            color: .blue
                        )
                    }
                    
                    // Voice chat button
                    NavigationLink(destination: VoiceCallPlaceholderView()) {
                        OptionButton(
                            title: "Talk to Bubl",
                            systemImage: "mic.fill",
                            color: .green
                        )
                    }
                    
                    // Video chat button
                    NavigationLink(destination: VideoCallPlaceholderView()) {
                        OptionButton(
                            title: "Video Bubl",
                            systemImage: "video.fill",
                            color: .purple
                        )
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Settings button at the bottom
                NavigationLink(destination: SettingsView()) {
                    HStack {
                        Image(systemName: "gear")
                        Text("Settings")
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.bottom, 20)
            }
            .padding()
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

// Reusable component for the option buttons
struct OptionButton: View {
    var title: String
    var systemImage: String
    var color: Color
    
    var body: some View {
        HStack {
            Image(systemName: systemImage)
                .font(.system(size: 24))
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(color)
                .clipShape(Circle())
                .shadow(color: color.opacity(0.4), radius: 5, x: 0, y: 4)
            
            Text(title)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.primary)
                .padding(.leading, 12)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(color.opacity(0.8))
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(color.opacity(0.1))
        .cornerRadius(16)
    }
}

// Preview for design development
struct HomeSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        HomeSelectionView()
            .previewDevice("iPhone 13")
    }
} 