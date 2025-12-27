import SwiftUI
import Combine
struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        Group {
            if authViewModel.isInitialLoading {
                // 1. Splash Screen / Initial Session Check
                VStack {
                    Image(systemName: "bed.double.fill") // Your logo
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    ProgressView()
                        .padding(.top, 20)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(red: 0.95, green: 0.97, blue: 1.0))
            } else if authViewModel.isAuthenticated {
                // 2. Authenticated Flow
                if authViewModel.completedOnboarding {
                    TabView {
                        NavigationStack { HomeView() }
                            .tabItem { Label("Deals", systemImage: "flame") }
                        
                        NavigationStack { FavouritesView() }
                            .tabItem { Label("Favourites", systemImage: "heart") }
                        
                        NavigationStack { DealsMapView() }
                            .tabItem { Label("Explore", systemImage: "map") }
                        
                        NavigationStack { ProfileView() }
                            .tabItem { Label("Profile", systemImage: "person") }
                    }
                } else {
                    OnboardingView()
                }
            } else {
                // 3. Unauthenticated Flow
                LoginView(viewModel: authViewModel)
            }
        }
        .animation(.easeInOut, value: authViewModel.isAuthenticated)
        .animation(.easeInOut, value: authViewModel.isInitialLoading)
        .animation(.easeInOut, value: authViewModel.completedOnboarding)
    }
}
