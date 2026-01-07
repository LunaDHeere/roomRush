import SwiftUI
import CoreLocation

struct FavouritesView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var homeVM : HomeViewModel
    @EnvironmentObject var locationManager: LocationManager
    
    @State private var selectedFilter = "All Deals"
    
    var filteredFavorites: [Deal] {
        let favoriteIds = authVM.currentUser?.favourites ?? []
        let baseFavorites = homeVM.allDeals.filter { favoriteIds.contains($0.id) }
        
        switch selectedFilter {
        case "Under $100":
            return baseFavorites.filter { $0.price < 100 }
        case "Hotels":
            return baseFavorites.filter { $0.type == "Hotel" }
        case "Hostels":
            return baseFavorites.filter { $0.type == "Hostel" }
        default:
            return baseFavorites
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                favouritesHeader
                
                // Reuse your existing FilterSection component
                FilterSection(selectedFilter: $selectedFilter)
                
                if filteredFavorites.isEmpty {
                    emptyStateView
                } else {
                    favouritesList
                }
            }
        }
        .background(Color(red: 0.98, green: 0.98, blue: 0.99))
        .task {
            if homeVM.deals.isEmpty {
                let city = authVM.currentUser?.city ?? "Mechelen"
                await homeVM.fetchDealsFromAPI(lat: 51.0259, lon: 4.4776, city: city)
            }
        }
    }
    
    private var favouritesHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Saved Deals").font(.system(size: 24, weight: .bold))
            // Count now reflects the filtered result
            Text("\(filteredFavorites.count) \(filteredFavorites.count == 1 ? "room" : "rooms") matching")
                .font(.system(size: 14)).foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white)
        .shadow(color: .black.opacity(0.02), radius: 5, y: 2)
    }
    
    private var favouritesList: some View {
        LazyVStack(spacing: 16) {
            ForEach(filteredFavorites) { deal in
                DealCardView(
                    deal: deal,
                    isFavourited: true,
                    onToggleFavourite: { authVM.toggleFavourite(dealId: deal.id) },
                    userLat: locationManager.userLocation?.coordinate.latitude ?? 51.0259,
                    userLon: locationManager.userLocation?.coordinate.longitude ?? 4.4776
                    
                )
            }
            offlineNotice
        }
        .padding()
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 100)
            Image(systemName: "heart.fill")
                .font(.system(size: 40))
                .foregroundColor(.gray.opacity(0.4))
                .padding(30)
                .background(Circle().fill(Color.gray.opacity(0.1)))
            
            Text("No saved deals yet").font(.headline)
            Text("Start saving your favorite last-minute deals to access them quickly later")
                .font(.subheadline).foregroundColor(.gray).multilineTextAlignment(.center).padding(.horizontal, 40)
        }
    }
    
    private var offlineNotice: some View {
        Label("Saved deals are available offline so you can access them anytime", systemImage: "info.circle")
            .font(.system(size: 13))
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.blue.opacity(0.05))
            .cornerRadius(12)
            .foregroundColor(Color(red: 0.1, green: 0.2, blue: 0.4))
    }
}
