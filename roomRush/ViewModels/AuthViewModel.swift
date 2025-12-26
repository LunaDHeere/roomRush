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
            
            // A brand new user always starts with hasCompletedOnboarding = false
            let newUser = User(
                id: userId,
                fullname: self.fullname,
                email: self.email,
                hasCompletedOnboarding: false // Explicitly set this
            )
            
            // Reset the navigation flag before saving
            Task { @MainActor in
                self.completedOnboarding = false
                self.saveUserToFirestore(newUser)
            }
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
        db.collection("users").document(userId).getDocument { snapshot, error in
            if let error = error {
                self.showError(error)
                return
            }
            
            Task { @MainActor in
                guard let snapshot = snapshot,
                      let user = try? snapshot.data(as: User.self) else {
                    print("DEBUG: Could not decode user")
                    return
                }
                
                self.currentUser = user
                
                // Logic: If they are signing in, they already exist in DB.
                // We assume they completed onboarding unless the DB says otherwise.
                // Or, if you want to be safe, check the specific boolean:
                self.completedOnboarding = user.hasCompletedOnboarding
                
                self.isAuthenticated = true
                print("DEBUG: User signed in. Onboarding status: \(self.completedOnboarding)")
            }
        }
    }
    
    // MARK: - Sign Out
    // MARK: - Sign Out
    func signOut() {
        do {
            try Auth.auth().signOut()
            
            // Reset everything to factory settings
            Task { @MainActor in
                self.isAuthenticated = false
                self.currentUser = nil
                self.completedOnboarding = false 
                self.email = ""
                self.password = ""
                self.fullname = ""
                self.errorMessage = ""
                print("DEBUG: User signed out and state reset.")
            }
        } catch {
            print("DEBUG: Error signing out: \(error.localizedDescription)")
        }
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
    
    func toggleFavourite(dealId: String) {
        guard var user = currentUser else { return }
        
        if user.favourites.contains(dealId) {
            user.favourites.removeAll { $0 == dealId }
        } else {
            user.favourites.append(dealId)
        }
        
        // Update local state immediately for UI snappiness
        self.currentUser = user
        
        // Update Firestore
        db.collection("users").document(user.id).updateData([
            "favourites": user.favourites
        ])
    }
    // Add this to your AuthViewModel class
    func updateUserInfo(newName: String, newEmail: String) {
        guard var user = currentUser else { return }
        
        // 1. Update Firestore Document
        user.fullname = newName
        user.email = newEmail
        
        db.collection("users").document(user.id).updateData([
            "fullname": newName,
            "email": newEmail
        ]) { error in
            if let error = error {
                print("DEBUG: Error updating Firestore: \(error.localizedDescription)")
                return
            }
            
            Task { @MainActor in
                self.currentUser = user
            }
        }
        
        // 2. Update Firebase Authentication Email
        // Note: This usually requires a recent login to work for security reasons
        Auth.auth().currentUser?.updateEmail(to: newEmail) { error in
            if let error = error {
                print("DEBUG: Error updating Auth Email: \(error.localizedDescription)")
                // Optionally show this error to the user via self.errorMessage
            }
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
