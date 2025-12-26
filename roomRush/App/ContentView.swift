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
                        NavigationStack {HomeView() }
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
                LoginView(viewModel: authViewModel)
            }
        }
        .animation(.easeInOut, value: authViewModel.isAuthenticated)
        .animation(.easeInOut, value: authViewModel.completedOnboarding)
    }
}
