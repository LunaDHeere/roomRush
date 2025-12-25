import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import Foundation
import Combine

class AuthViewModel: ObservableObject {
    
    // MARK: - User Input
    @Published var email = ""
    @Published var password = ""
    @Published var fullname = ""
    
    // MARK: - App State
    @Published var isAuthenticated = false
    @Published var errorMessage = ""
    @Published var currentUser: User?
    @Published var completedOnboarding = false
    
    private let db = Firestore.firestore()
    
    // MARK: - Sign Up
    func signUp() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                self.showError(error)
                return
            }
            
            guard let userId = result?.user.uid else { return }
            
            let newUser = User(id: userId, fullname: self.fullname, email: self.email)
            
            self.saveUserToFirestore(newUser)
        }
    }
    
    // MARK: - Sign In
    func signIn() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                self.showError(error)
                return
            }
            
            guard let userId = result?.user.uid else { return }
            self.fetchUser(userId: userId)
        }
    }
    
    // MARK: - Fetch User
    func fetchUser(userId: String) {
        db.collection("users").document(userId).getDocument { snapshot, _ in
            Task { @MainActor in
                guard let snapshot = snapshot,
                      let user = try? snapshot.data(as: User.self) else { return }
                
                self.currentUser = user
                self.isAuthenticated = true
            }
        }
    }
    
    // MARK: - Sign Out
    func signOut() {
        try? Auth.auth().signOut()
        isAuthenticated = false
        currentUser = nil
    }
    
    // MARK: - Helpers
    private func showError(_ error: Error) {
        Task { @MainActor in
            self.errorMessage = error.localizedDescription
        }
    }
    
    func saveUserToFirestore(_ user: User) {
        do {
            try db.collection("users").document(user.id).setData(from: user)
            Task { @MainActor in
                self.currentUser = user
                self.isAuthenticated = true
            }
        } catch {
            print("Failed to save user: \(error.localizedDescription)")
        }
    }
}

// MARK: - Seed Database
extension AuthViewModel {
    func seedDatabase() {
        let users = [
            User(id: "user_1", fullname: "Sarah Jenkins", email: "sarah@example.com", bookingsCount: 5, savedCount: 12, totalSavedMoney: "$1,200"),
            User(id: "user_2", fullname: "Michael Chen", email: "m.chen@tech.com", bookingsCount: 2, savedCount: 4, totalSavedMoney: "$450"),
            User(id: "user_3", fullname: "Alex Rivera", email: "alex@design.io", bookingsCount: 15, savedCount: 30, totalSavedMoney: "$4,200"),
            User(id: "user_4", fullname: "Emma Wilson", email: "emma.w@columbia.edu", bookingsCount: 0, savedCount: 8, totalSavedMoney: "$150"),
            User(id: "user_5", fullname: "Guest User", email: "guest@roomrush.com", bookingsCount: 1, savedCount: 1, totalSavedMoney: "$50")
        ]
        
        for user in users {
            do {
                try db.collection("users").document(user.id).setData(from: user)
                print("Seeded user: \(user.fullname)")
            } catch {
                print("Failed to seed user: \(error.localizedDescription)")
            }
        }
    }
}
