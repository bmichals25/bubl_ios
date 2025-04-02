import SwiftUI
import Firebase
import FirebaseAuth

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var currentUser: User?
    
    init() {
        checkAuthStatus()
    }
    
    func checkAuthStatus() {
        if let user = Auth.auth().currentUser {
            self.currentUser = user
            self.isAuthenticated = true
        } else {
            self.isAuthenticated = false
            self.currentUser = nil
        }
    }
    
    func signIn(email: String, password: String) {
        isLoading = true
        errorMessage = ""
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            self.isLoading = false
            
            if let error = error {
                self.errorMessage = error.localizedDescription
                return
            }
            
            if let user = result?.user {
                self.currentUser = user
                self.isAuthenticated = true
            }
        }
    }
    
    func signUp(email: String, password: String) {
        isLoading = true
        errorMessage = ""
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            self.isLoading = false
            
            if let error = error {
                self.errorMessage = error.localizedDescription
                return
            }
            
            if let user = result?.user {
                self.currentUser = user
                self.isAuthenticated = true
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.isAuthenticated = false
            self.currentUser = nil
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
} 