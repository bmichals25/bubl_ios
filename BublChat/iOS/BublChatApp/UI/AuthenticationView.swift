import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var isLoginMode = true
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)
                
                Text("BublChat")
                    .font(.largeTitle)
                    .bold()
                
                VStack(spacing: 15) {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    
                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                
                if !authViewModel.errorMessage.isEmpty {
                    Text(authViewModel.errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                
                Button(action: {
                    if isLoginMode {
                        authViewModel.signIn(email: email, password: password)
                    } else {
                        authViewModel.signUp(email: email, password: password)
                    }
                }) {
                    Text(isLoginMode ? "Sign In" : "Create Account")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(8)
                        .padding(.horizontal)
                }
                .disabled(authViewModel.isLoading)
                
                if authViewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                }
                
                Button(action: {
                    isLoginMode.toggle()
                }) {
                    Text(isLoginMode ? "Don't have an account? Sign Up" : "Already have an account? Sign In")
                        .foregroundColor(.blue)
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
    }
} 