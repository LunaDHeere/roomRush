import SwiftUI
import Combine
struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var homeViewModel : HomeViewModel
    @EnvironmentObject var networkMonitor: NetworkMonitor
    
    @State private var showOfflineAlert = false
    
    var body: some View {
        Group {
            if authViewModel.isInitialLoading {
                VStack {
                    Image(systemName: "bed.double.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    ProgressView()
                        .padding(.top, 20)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(red: 0.95, green: 0.97, blue: 1.0))
            } else if authViewModel.isAuthenticated {
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
                }
            } else {
                LoginView(viewModel: authViewModel)
            }
        }
        
        .onChange(of: networkMonitor.isConnected){_, isConnected in
            showOfflineAlert = !isConnected
        }
        .alert("No Internet Connection", isPresented: $showOfflineAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("You're offline. Showing cached deals.")
        }
        .animation(.easeInOut, value: authViewModel.isAuthenticated)
        .animation(.easeInOut, value: authViewModel.isInitialLoading)
        .animation(.easeInOut, value: authViewModel.completedOnboarding)
    }
}
