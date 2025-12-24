//
//  ContentView.swift
//  roomRush
//
//  Created by Amina Iqbal on 22/12/2025.
//

import SwiftUI
import CoreData
struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                // This is where they go AFTER logging in
                ProfileView()
            } else {
                // This is the landing page
                LoginView(viewModel: authViewModel)
            }
        }
    }
}

// Simple Home Screen for testing
struct HomeScreen: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
            
            Text("Welcome! The sign up/login worked!")
                .font(.headline)
            
            Text("Logged in as: \(authViewModel.email)")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Button("Sign Out") {
                authViewModel.signOut()
            }
            .buttonStyle(.borderedProminent)
            .padding(.top)
        }
    }
}
