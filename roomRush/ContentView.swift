import SwiftUI
import Combine

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                if authViewModel.completedOnboarding {
                    // MAIN APP
                    TabView {
                        NavigationStack {
                            HomeView()
                        }
                        .tabItem {
                            Label("Deals", systemImage: "flame")
                        }
                        
                        NavigationStack {
                            ProfileView()
                        }
                        .tabItem {
                            Label("Profile", systemImage: "person")
                        }
                    }
                } else {
                    // FIX: SHOW ONBOARDING IF NOT COMPLETED
                    OnboardingView()
                }
            } else {
                // LANDING PAGE
                LoginView(viewModel: authViewModel)
            }
        }
        // Add animations to make the transitions smooth
        .animation(.easeInOut, value: authViewModel.isAuthenticated)
        .animation(.easeInOut, value: authViewModel.completedOnboarding)
    }
}
