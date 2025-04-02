import SwiftUI
import Firebase

@main
struct BublChatApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            if authViewModel.isAuthenticated {
                MainDashboardView()
                    .environmentObject(authViewModel)
            } else {
                AuthenticationView()
                    .environmentObject(authViewModel)
            }
        }
    }
}
