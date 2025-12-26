import SwiftUI
import Combine
import Kingfisher
import Foundation
import CoreLocation

struct HomeView: View {
    @StateObject var viewModel = HomeViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var timeAgoText: String = "just now"
    @StateObject var locationManager = LocationManager()
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                if viewModel.showNotification { notificationBanner }
                
                headerSection
                
                filterSection
                
                if viewModel.isLoading {
                    ProgressView().padding(.top, 50)
                } else {
                    dealsGrid
                }
            }
        }
        .background(Color(red: 0.97, green: 0.97, blue: 0.98))
        .onAppear {
            // Default coordinates for Brussels
            let defaultLat = 50.8503
            let defaultLon = 4.3517
            
            // Use real location if available, otherwise Brussels
            let lat = locationManager.userLocation?.coordinate.latitude ?? defaultLat
            let lon = locationManager.userLocation?.coordinate.longitude ?? defaultLon
            
            // Pass the city from authViewModel directly into the function
            let city = authViewModel.currentUser?.city ?? "Brussels"
            
            viewModel.testAmadeus(lat: lat, lon: lon, userCity: city)
            updateTimeText()
        }
    }
    
    private func updateTimeText() {
        if let lastFetch = viewModel.lastFetchTime {
            timeAgoText = lastFetch.timeAgo()
        } else {
            timeAgoText = "just now"
        }
    }
    
    // MARK: - Subviews moved here for cleanliness
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: "mappin.and.ellipse").foregroundColor(.blue)
                Text(authViewModel.currentUser?.city ?? "Locating...")
                    .font(.system(size: 14)).foregroundColor(.gray)
            }
            Text("Last-Minute Deals").font(.system(size: 24, weight: .bold))
            Text("Updated \(timeAgoText)").font(.system(size: 14)).foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white)
    }
    
    private var filterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(["All Deals", "Hotels", "Hostels", "Under $100"], id: \.self) { cat in
                    FilterChipView(title: cat, isActive: viewModel.selectedFilter == cat)
                        .onTapGesture {
                            withAnimation { viewModel.applyFilter(cat) }
                        }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
    }
    
    private var dealsGrid: some View {
        LazyVStack(spacing: 16) {
            ForEach(viewModel.deals) { deal in
                DealCardView(deal: deal)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 100)
    }
    
    private var notificationBanner: some View {
        HStack {
            Image(systemName: "bell.fill")
            VStack(alignment: .leading) {
                Text("New deal alert!").bold()
                Text("3 rooms available within 5 km").font(.caption)
            }
            Spacer()
            Button("View") { }.underline()
        }
        .padding()
        .background(Color.blue)
        .foregroundColor(.white)
    }
}

// MARK: - Supporting Components

struct FilterChipView: View {
    let title: String
    var isActive: Bool = false
    
    var body: some View {
        Text(title)
            .font(.system(size: 14, weight: .medium))
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isActive ? Color.blue : Color.white)
            .foregroundColor(isActive ? .white : Color.gray)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.gray.opacity(0.2), lineWidth: isActive ? 0 : 1)
            )
    }
}
struct DealCardView: View {
    let deal: Deal
    @State private var isFavorite = false
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var distance: Double {
        // We use the ID's hash to make sure the distance is the same every time
        // for this specific hotel, but random enough to look real.
        return Double(abs(deal.id.hashValue % 50)) / 10.0 + 0.5
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // MARK: - Image Section
            ZStack(alignment: .topTrailing) {
                KFImage(URL(string: deal.imageUrl))
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
                    .clipped()
                
                // Top Left: Discount Badge
                Text("-\(deal.discountPercentage)%")
                    .font(.system(size: 13, weight: .bold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(20)
                    .padding(12)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                
                // Top Right: Favorite Button
                Button {
                    authViewModel.toggleFavourite(dealId: deal.id ?? "")
                } label: {
                    let isCurrentlyFavourited = authViewModel.currentUser?.favourites.contains(deal.id ?? "") ?? false
                    
                    Image(systemName: isCurrentlyFavourited ? "heart.fill" : "heart")
                        .font(.system(size: 18))
                        .foregroundColor(isFavorite ? .red : .gray)
                        .padding(10)
                        .background(Color.white.opacity(0.9))
                        .clipShape(Circle())
                        .shadow(radius: 2)
                }
                .padding(12)
                
                // Bottom Left: Availability Badge
                Text("Only \(deal.roomsLeft) left")
                    .font(.system(size: 13, weight: .bold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(20)
                    .padding(12)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
            }
            
            // MARK: - Content Section
            VStack(alignment: .leading, spacing: 12) {
                // Title and Rating
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(deal.title)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.black)
                        
                        Text(deal.roomName)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Rating Badge (Figma Style)
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 12))
                        Text(String(format: "%.1f", deal.rating))
                            .font(.system(size: 14, weight: .bold))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(8)
                }
                
                // Distance/Location
                HStack(spacing: 4) {
                    Image(systemName: "mappin.circle")
                    Text("\(String(format: "%.1f", distance)) km away")
                }
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                
                // Pricing
                HStack(alignment: .bottom, spacing: 6) {
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text("$\(deal.price)")
                            .font(.system(size: 24, weight: .bold))
                        Text("/night")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    
                    Text("$\(deal.originalPrice)")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .strikethrough()
                        .padding(.bottom, 2)
                }
            }
            .padding(16)
        }
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
    }
    
}
