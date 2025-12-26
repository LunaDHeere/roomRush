import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import Foundation
import Combine

class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var fullname = ""
    
    @Published var isAuthenticated = false
    @Published var errorMessage = ""
    @Published var currentUser: User?
    @Published var completedOnboarding = false
    
    private let db = Firestore.firestore()
    
    // MARK: - Auth
    func signUp() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                DispatchQueue.main.async { self.errorMessage = error.localizedDescription }
                return
            }
            
            guard let uid = result?.user.uid else { return }
            
            let user = User(
                id: uid,
                fullname: self.fullname,
                email: self.email,
                hasCompletedOnboarding: false
            )
            
            DispatchQueue.main.async { self.completedOnboarding = false }
            self.saveUserToFirestore(user)
        }
    }
    
    func signIn() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                DispatchQueue.main.async { self.errorMessage = error.localizedDescription }
                return
            }
            
            guard let uid = result?.user.uid else { return }
            self.fetchUser(userId: uid)
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                self.isAuthenticated = false
                self.currentUser = nil
                self.completedOnboarding = false
                self.email = ""
                self.password = ""
                self.fullname = ""
                self.errorMessage = ""
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // MARK: - User Fetch & Save
    func fetchUser(userId: String) {
        db.collection("users").document(userId).getDocument { snapshot, error in
            if let error = error {
                DispatchQueue.main.async { self.errorMessage = error.localizedDescription }
                return
            }
            
            guard let snapshot = snapshot else { return }
            
            DispatchQueue.main.async {
                if let user = try? snapshot.data(as: User.self) {
                    self.currentUser = user
                    self.completedOnboarding = user.hasCompletedOnboarding
                    self.isAuthenticated = true
                }
            }
        }
    }
    
    func saveUserToFirestore(_ user: User) {
        do {
            try db.collection("users").document(user.id).setData(from: user)
            DispatchQueue.main.async {
                self.currentUser = user
                self.isAuthenticated = true
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func completeOnboarding(fullname: String, city: String) {
        print("DEBUG: completeOnboarding() called")
        
        guard var user = currentUser else { return }
        
        user.fullname = fullname
        user.city = city
        user.hasCompletedOnboarding = true
        
        // 1. Update Firestore
        db.collection("users").document(user.id).updateData([
            "fullname": fullname,
            "city": city,
            "hasCompletedOnboarding": true
        ]) { error in
            // 2. ONLY switch the screen AFTER the database confirms success
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // 0.5s delay
                self.currentUser = user
                withAnimation {
                    self.completedOnboarding = true
                }
                print("DEBUG: Transitioning to HomeView now.")
            }
        }
    }
    
    // MARK: - Helpers
    func toggleFavourite(dealId: String) {
        guard var user = currentUser else { return }
        
        if user.favourites.contains(dealId) {
            user.favourites.removeAll { $0 == dealId }
        } else {
            user.favourites.append(dealId)
        }
        
        DispatchQueue.main.async { self.currentUser = user }
        db.collection("users").document(user.id)
            .updateData(["favourites": user.favourites])
    }
    
    func updateUserInfo(newName: String, newEmail: String) {
        guard var user = currentUser else { return }
        user.fullname = newName
        user.email = newEmail
        
        DispatchQueue.main.async { self.currentUser = user }
        
        db.collection("users").document(user.id).updateData([
            "fullname": newName,
            "email": newEmail
        ])
        
        Auth.auth().currentUser?.sendEmailVerification(beforeUpdatingEmail: newEmail)
    }
}
