import Foundation
import FirebaseAuth
import SwiftUI
import Combine

class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var errorMessage = ""
    @Published var isAuthenticated = false

    func signUp() {
        Auth.auth().createUser(withEmail: email, password: password) { _, error in
                    if let error = error {
                        self.errorMessage = error.localizedDescription
                        return
                    }
                    self.isAuthenticated = true
        }
    }

    func signIn() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            DispatchQueue.main.async{
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
            }
            print("Logged in!")
            self.isAuthenticated = true
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.isAuthenticated = false
            self.email = ""
            self.password = ""
        } catch let error {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}
