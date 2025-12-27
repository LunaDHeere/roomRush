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
            // 1. Tell GPS to update
            locationManager.requestLocation()
            
            // 2. Get current coords or fallbacks
            let lat = locationManager.userLocation?.coordinate.latitude ?? 50.8503
            let lon = locationManager.userLocation?.coordinate.longitude ?? 4.3517
            let city = authViewModel.currentUser?.city ?? locationManager.city
            
            // 3. Call fetch with forceRefresh: true
            await viewModel.fetchDeals(lat: lat, lon: lon, city: city, forceRefresh: true)
        }
        .task {
            locationManager.requestLocation()
            await loadDeals()
        }
        // KEY FIX: Listen for the moment the GPS actually finds you
        .onChange(of: locationManager.userLocation) { oldLoc, newLoc in
            if let location = newLoc {
                Task {
                    let currentCity = locationManager.city.isEmpty ? "Current Location" : locationManager.city
                    
                    await viewModel.fetchDeals(
                        lat: location.coordinate.latitude,
                        lon: location.coordinate.longitude,
                        city: currentCity,
                        forceRefresh: true
                    )
                }
            }
        }
    }
    
    private func loadDeals() async {
        let lat = locationManager.userLocation?.coordinate.latitude ?? 50.8503
        let lon = locationManager.userLocation?.coordinate.longitude ?? 4.3517
        let city = authViewModel.currentUser?.city ?? "Brussels"
        await viewModel.fetchDeals(lat: lat, lon: lon, city: city)
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
