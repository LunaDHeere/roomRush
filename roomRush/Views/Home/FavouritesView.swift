import SwiftUI
import Combine

struct FavouritesView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject var homeVM = HomeViewModel() // To get the list of all deals
    
    // Computed property to find only the deals the user has favorited
    var favoriteDeals: [Deal] {
        let favoriteIds = authVM.currentUser?.favourites ?? []
        return homeVM.deals.filter { favoriteIds.contains($0.id ?? "") }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // MARK: - Header
                VStack(alignment: .leading, spacing: 4) {
                    Text("Saved Deals")
                        .font(.system(size: 24, weight: .bold))
                    Text("\(favoriteDeals.count) \(favoriteDeals.count == 1 ? "room" : "rooms") saved")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.white)
                .shadow(color: .black.opacity(0.02), radius: 5, y: 2)
                
                if favoriteDeals.isEmpty {
                    // MARK: - Empty State
                    VStack(spacing: 20) {
                        Spacer(minLength: 100)
                        ZStack {
                            Circle()
                                .fill(Color.gray.opacity(0.1))
                                .frame(width: 100, height: 100)
                            Image(systemName: "heart.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.gray.opacity(0.4))
                        }
                        
                        Text("No saved deals yet")
                            .font(.system(size: 20, weight: .semibold))
                        
                        Text("Start saving your favorite last-minute deals to access them quickly later")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                } else {
                    // MARK: - favourites List
                    LazyVStack(spacing: 16) {
                        ForEach(favoriteDeals) { deal in
                            DealCardView(deal: deal)
                        }
                        
                        // Offline Notice
                        HStack(alignment: .top, spacing: 12) {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 8, height: 8)
                                .padding(.top, 6)
                            
                            Text("Saved deals are available offline so you can access them anytime")
                                .font(.system(size: 13))
                                .foregroundColor(Color(red: 0.1, green: 0.2, blue: 0.4))
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.blue.opacity(0.05))
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.blue.opacity(0.1), lineWidth: 1))
                        .padding(.top, 20)
                    }
                    .padding()
                }
            }
        }
        .background(Color(red: 0.98, green: 0.98, blue: 0.99))
        .onAppear {
            let cityName = authVM.currentUser?.city ?? "Brussels"
            
            // Pass all 3 arguments now: lat, lon, and userCity
            homeVM.testAmadeus(lat: 51.0259, lon: 4.4776, userCity: cityName)
        }
    }
}
