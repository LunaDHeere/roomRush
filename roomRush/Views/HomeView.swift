import SwiftUI
import Combine
import Kingfisher
import Foundation

struct HomeView: View {
    @StateObject var viewModel = HomeViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var timeAgoText: String = "just now"
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // MARK: - Notification Banner
                if viewModel.showNotification {
                    HStack(spacing: 12) {
                        Image(systemName: "bell.fill")
                            .font(.system(size: 18))
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("New deal alert!")
                                .font(.system(size: 14, weight: .bold))
                            Text("3 rooms available within 5 km")
                                .font(.system(size: 13))
                        }
                        
                        Spacer()
                        
                        Button("View") { }
                            .font(.system(size: 13, weight: .semibold))
                            .underline()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(LinearGradient(colors: [.blue, Color(red: 0.1, green: 0.4, blue: 0.9)], startPoint: .leading, endPoint: .trailing))
                    .foregroundColor(.white)
                }
                
                // MARK: - Header
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.and.ellipse")
                            .foregroundColor(.blue)
                        Text(authViewModel.currentUser?.city ?? "location can't be found.")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 24)
                    
                    Text("Last-Minute Deals")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text("Available rooms near you • Updated \(timeAgoText)")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
                .background(Color.white)
                .shadow(color: .black.opacity(0.03), radius: 5, y: 2)
                
                // MARK: - Filter Chips
                let categories = ["All Deals", "Hotels", "Hostels", "Under $100"]

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(categories, id: \.self) { category in
                            FilterChipView(
                                title: category,
                                isActive: viewModel.selectedFilter == category
                            )
                            .onTapGesture {
                                // This makes the transition look smooth!
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    viewModel.applyFilter(category)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.vertical, 16)
                
                // MARK: - Deals Grid
                if viewModel.isLoading {
                    ProgressView().padding(.top, 50)
                } else {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.deals) { deal in
                            DealCardView(deal: deal)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 100)
                }
            }
        }
        .background(Color(red: 0.97, green: 0.97, blue: 0.98))
        .onAppear {
            if let _ = authViewModel.currentUser?.city {
                viewModel.testAmadeus(lat: 51.0259, lon: 4.4776)
            }
            updateTimeText()
        }
        .onReceive(timer) { _ in
            updateTimeText()
        }
        .onChange(of: viewModel.deals.count) { oldValue, newValue in
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
                    Text("\(String(format: "%.1f", 1.2)) km away") // Example distance logic
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
