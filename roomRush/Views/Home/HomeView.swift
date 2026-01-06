import SwiftUI
import Foundation
import Kingfisher
import CoreLocation

struct HomeView: View {
    @EnvironmentObject var viewModel : HomeViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var locationManager : LocationManager
    
    @State private var didInitialFetch = false
    
    var body: some View {
        ZStack(alignment: .top){
            
            ScrollView {
                VStack(spacing: 0) {
                    
                    HeaderSection(
                        city: authViewModel.currentUser?.city ?? "Locating...",
                        timeAgo: viewModel.lastFetchTime?.friendlyLastUpdated() ?? "Updated just now"
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
        }
        .background(AppColors.screenBackground)
        /*.refreshable {
            
            let lat = locationManager.userLocation?.coordinate.latitude ?? 50.8503
            let lon = locationManager.userLocation?.coordinate.longitude ?? 4.3517
            let city = authViewModel.currentUser?.city ?? locationManager.city
            
            await viewModel.refreshDeals(lat: lat, lon: lon, city: city)
            }*/
        .onChange(of: locationManager.userLocation) { _, newLoc in
            guard let location = newLoc, !didInitialFetch else { return }
            didInitialFetch = true

            Task {
                await viewModel.refreshDeals(
                    lat: location.coordinate.latitude,
                    lon: location.coordinate.longitude,
                    city: authViewModel.currentUser?.city ?? locationManager.city
                )
            }
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

