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
    @Published var isInitialLoading = true
    
    private let db = Firestore.firestore()
    private var authListenerHandle: AuthStateDidChangeListenerHandle?
    
    init() {
        authListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }
            
            if let user = user {
                self.fetchUser(userId: user.uid)
            } else {
                DispatchQueue.main.async {
                    self.isAuthenticated = false
                    self.currentUser = nil
                    self.isInitialLoading = false
                }
            }
        }
    }
    
    deinit {
        if let handle = authListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    func signUp() {
        guard !fullname.isEmpty else {
            self.errorMessage = "Please enter your full name."
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                DispatchQueue.main.async { self.errorMessage = self.getFriendlyError(error) }
                return
            }

            guard let uid = result?.user.uid else { return }
            let user = User(
                id: uid,
                fullname: self.fullname,
                email: self.email,
                hasCompletedOnboarding: true
            )
            
            DispatchQueue.main.async { self.completedOnboarding = false }
            self.saveUserToFirestore(user)
        }
    }
    
    func signIn() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                DispatchQueue.main.async { self.errorMessage = self.getFriendlyError(error) }
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
                self.resetForm()
            }
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }

    func fetchUser(userId: String) {
        db.collection("users").document(userId).getDocument { snapshot, error in
            if let error = error {
                DispatchQueue.main.async { self.errorMessage = self.getFriendlyError(error) }
                return
            }
            
            guard let snapshot = snapshot else { return }
            DispatchQueue.main.async {
                if let user = try? snapshot.data(as: User.self) {
                    self.currentUser = user
                    self.completedOnboarding = user.hasCompletedOnboarding
                    self.isAuthenticated = true
                }
                self.isInitialLoading = false
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
        
        db.collection("users").document(user.id).updateData([
            "fullname": fullname,
            "city": city,
            "hasCompletedOnboarding": true
        ]) { error in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.currentUser = user
                withAnimation {
                    self.completedOnboarding = true
                }
                print("DEBUG: Transitioning to HomeView now.")
            }
        }
    }

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
    

    private func resetForm() {
        self.email = ""
        self.password = ""
        self.fullname = ""
        self.errorMessage = ""
    }
    
    private func getFriendlyError(_ error: Error) -> String {
        let nsError = error as NSError
        
        guard let errorCode = AuthErrorCode(rawValue: nsError.code) else {
            return error.localizedDescription
        }
        
        switch errorCode {
        case .invalidEmail:
            return "Please enter a valid email address."
        case .wrongPassword:
            return "Incorrect password. Please try again."
        case .userNotFound:
            return "We couldn't find an account with that email."
        case .weakPassword:
            return "Your password is too weak. Please use at least 6 characters."
        case .emailAlreadyInUse:
            return "This email is already associated with another account."
        case .networkError:
            return "Network error. Please check your internet connection."
        case .requiresRecentLogin:
            return "For security, please log out and log back in to make this change."
        default:
            return "An unexpected error occurred. Please try again."
        }
    }
}
