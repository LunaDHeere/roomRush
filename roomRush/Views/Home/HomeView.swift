import SwiftUI
import Foundation
import Kingfisher
import CoreLocation

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var locationManager = LocationManager()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                if viewModel.showNotification { NotificationBanner() }
                
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
        .background(AppColors.screenBackground)
        .task {
            await loadDeals()
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
                    onToggleFavourite: { authViewModel.toggleFavourite(dealId: deal.id) }
                )
            }
        }
        .padding(.horizontal)
    }
}
