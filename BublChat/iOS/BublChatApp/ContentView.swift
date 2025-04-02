import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Welcome to BublChat")
                    .font(.largeTitle)
                    .padding()
                
                if authViewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                } else {
                    Button(action: {
                        authViewModel.signOut()
                    }) {
                        Text("Sign Out")
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
            .navigationTitle("BublChat")
        }
    }
}
