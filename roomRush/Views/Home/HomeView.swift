import SwiftUI
import Foundation
import Kingfisher
import CoreLocation

struct HomeView: View {
    @EnvironmentObject var viewModel : HomeViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var locationManager = LocationManager()
    
    var body: some View {
        ZStack(alignment: .top){
            
            ScrollView {
                VStack(spacing: 0) {
                    
                    HeaderSection(
                        city: authViewModel.currentUser?.city ?? "Locating...",
                        timeAgo: viewModel.lastFetchTime?.timeAgo() ?? "just now"
                    )
                    
                    FilterSection(selectedFilter: $viewModel.selectedFilter) {
                        viewModel.applyFilter($0)
                    }
                    
                    if viewModel.isLoading {
                        ProgressView().padding(.top, 50)
                    } else {
                        DealsGrid()
                    }
                }
            }
            if viewModel.isOffline {
                OfflinePopup()
                    .padding(.top, 60) // Small gap from the top
                    .zIndex(1)
                    .transition(.asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .opacity
                    ))
                    .onAppear {
                        // Optional: Auto-hide after 5 seconds
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                            withAnimation { viewModel.isOffline = false }
                        }
                    }
            }
        }
        .background(AppColors.screenBackground)
        .refreshable {
            locationManager.requestLocation()
            
            // 2. Get current coords or fallbacks
            let lat = locationManager.userLocation?.coordinate.latitude ?? 50.8503
            let lon = locationManager.userLocation?.coordinate.longitude ?? 4.3517
            let city = authViewModel.currentUser?.city ?? locationManager.city
            
            await viewModel.refreshDeals(lat: lat, lon: lon, city: city)
            }
        .task {
            locationManager.requestLocation()
        }
        // KEY FIX: Listen for the moment the GPS actually finds you
        .onChange(of: locationManager.userLocation) { oldLoc, newLoc in
            guard let location = newLoc else { return }
            
            UserDefaults.standard.set(location.coordinate.latitude, forKey: "lastLat")
            UserDefaults.standard.set(location.coordinate.longitude, forKey: "lastLon")
        }
    }
    
    @ViewBuilder
    private func DealsGrid() -> some View {
        LazyVStack(spacing: 16) {
            ForEach(viewModel.deals) { deal in
                DealCardView(
                    deal: deal,
                    isFavourited: authViewModel.currentUser?.favourites.contains(deal.id) ?? false,
                    onToggleFavourite: { authViewModel.toggleFavourite(dealId: deal.id) },
                    userLat: locationManager.userLocation?.coordinate.latitude ?? 50.8503,
                    userLon: locationManager.userLocation?.coordinate.longitude ?? 4.3517
                )
            }
        }
        .padding(.horizontal)
    }
}
