import SwiftUI

struct MainDashboardView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Text Chat Tab
            NavigationView {
                TextChatView()
                    .navigationTitle("Text Chat")
            }
            .tabItem {
                Image(systemName: "message.fill")
                Text("Text Chat")
            }
            .tag(0)
            
            // Voice Call Tab
            NavigationView {
                VoiceCallPlaceholderView()
                    .navigationTitle("Voice Call")
            }
            .tabItem {
                Image(systemName: "phone.fill")
                Text("Voice Call")
            }
            .tag(1)
            
            // Video Call Tab
            NavigationView {
                VideoCallPlaceholderView()
                    .navigationTitle("Video Call")
            }
            .tabItem {
                Image(systemName: "video.fill")
                Text("Video Call")
            }
            .tag(2)
            
            // Settings Tab
            NavigationView {
                SettingsView()
                    .navigationTitle("Settings")
            }
            .tabItem {
                Image(systemName: "gear")
                Text("Settings")
            }
            .tag(3)
        }
    }
}

// Placeholder Views for Each Chat Mode
struct VoiceCallPlaceholderView: View {
    var body: some View {
        VStack {
            Text("Voice Call Coming Soon")
            Image(systemName: "phone")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.green)
        }
    }
}

struct VideoCallPlaceholderView: View {
    var body: some View {
        VStack {
            Text("Video Call Coming Soon")
            Image(systemName: "video")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.purple)
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        Form {
            Section(header: Text("Account")) {
                if let user = authViewModel.currentUser {
                    Text("Email: \(user.email ?? "No email")")
                        .foregroundColor(.secondary)
                }
                
                Button("Sign Out") {
                    authViewModel.signOut()
                }
                .foregroundColor(.red)
            }
            
            Section(header: Text("About")) {
                Text("BublChat v0.1")
                Text("The friendly AI companion")
            }
        }
    }
} 