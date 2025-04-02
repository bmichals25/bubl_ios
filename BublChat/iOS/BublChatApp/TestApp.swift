import SwiftUI

@main
struct TestApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                TextChatView()
                    .navigationTitle("Bubl Chat Test")
            }
        }
    }
} 