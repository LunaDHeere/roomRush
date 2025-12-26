import Foundation
import FirebaseFirestore
import SwiftUI
import Combine

@MainActor // This protects the whole class from thread crashes
class HomeViewModel: ObservableObject {
    @Published var deals = [Deal]()
    @Published var allDeals = [Deal]()
    @Published var isLoading = false
    @Published var lastFetchTime: Date? = nil // Simple optional
    @Published var selectedFilter = "All Deals"
    @Published var showNotification = true
    
    private let apiManager = APIManager()
    private let db = Firestore.firestore()

    func testAmadeus(lat: Double, lon: Double, userCity: String) {
        self.isLoading = true
        print("DEBUG: Fetching Amadeus hotels...")
        
        Task {
            do {
                let amadeusHotels = try await apiManager.fetchHotels(lat: lat, lon: lon)
                
                let fetchedDeals = amadeusHotels.map { hotel in
                    Deal(
                        id: hotel.hotelId,
                        title: hotel.name,
                        roomName: "Last-Minute Special",
                        locationName: userCity,
                        price: Int.random(in: 85...140),
                        originalPrice: Int.random(in: 160...210),
                        roomsLeft: Int.random(in: 1...4),
                        rating: Double.random(in: 4.1...4.8),
                        imageUrl: "https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=800&q=80",
                        type: "Hotel",
                        latitude: hotel.geoCode.latitude,
                        longitude: hotel.geoCode.longitude
                    )
                }
                
                self.allDeals = fetchedDeals
                self.deals = fetchedDeals
                self.lastFetchTime = Date()
                self.isLoading = false
                print("✅ Successfully loaded \(self.deals.count) hotels")
                
            } catch {
                print("❌ API Error: \(error.localizedDescription)")
                self.isLoading = false
            }
        }
    }

    func applyFilter(_ filter: String) {
        self.selectedFilter = filter
        switch filter {
        case "Under $100":
            self.deals = allDeals.filter { $0.price < 100 }
        case "Hotels":
            self.deals = allDeals.filter { $0.type == "Hotel" }
        case "Hostels":
            self.deals = allDeals.filter { $0.type == "Hostel" }
        default:
            self.deals = allDeals
        }
    }
}

extension Date {
    func timeAgo() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}
