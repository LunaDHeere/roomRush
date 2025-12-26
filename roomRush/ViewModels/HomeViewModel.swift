import Foundation
import FirebaseFirestore
import SwiftUI
import Combine

@MainActor
class HomeViewModel: ObservableObject {
    @Published var deals = [Deal]()
    @Published private var allDeals = [Deal]()
    @Published var isLoading = false
    @Published var lastFetchTime: Date? = nil
    @Published var selectedFilter = "All Deals"
    @Published var showNotification = true
    
    private let apiManager = APIManager()
    
    func fetchDeals(lat: Double, lon: Double, city: String) async {
        self.isLoading = true
        defer { self.isLoading = false }
        
        do {
            // 1. Fetch real data from Amadeus
            let amadeusHotels = try await apiManager.fetchHotels(lat: lat, lon: lon)
            
            // 2. Map Amadeus hotels to your Deal model
            let fetchedDeals = amadeusHotels.map { hotel in
                Deal(
                    id: hotel.hotelId,
                    title: hotel.name,
                    roomName: "Last-Minute Special",
                    locationName: city,
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
            
            // 3. Update state
            self.allDeals = fetchedDeals
            self.lastFetchTime = Date()
            self.applyFilter(selectedFilter)
            
        } catch {
            print("❌ API Error: \(error.localizedDescription)")
            
            // FALLBACK: If the API fails (like your current Quota Limit error),
            // we load this "Mock" data so you can still present your app for your exam.
            let fallbackDeals = [
                Deal(
                    id: "OFFLINE_1",
                    title: "Grand Hotel Mechelen (Exam Fallback)",
                    roomName: "Deluxe Suite",
                    locationName: city,
                    price: 99,
                    originalPrice: 190,
                    roomsLeft: 2,
                    rating: 4.7,
                    imageUrl: "https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=800&q=80",
                    type: "Hotel",
                    latitude: lat,
                    longitude: lon
                ),
                Deal(
                    id: "OFFLINE_2",
                    title: "River Hostel",
                    roomName: "Dormitory",
                    locationName: city,
                    price: 45,
                    originalPrice: 65,
                    roomsLeft: 5,
                    rating: 4.2,
                    imageUrl: "https://images.unsplash.com/photo-1555854816-808226a3f14b?auto=format&fit=crop&w=800&q=80",
                    type: "Hostel",
                    latitude: lat + 0.005,
                    longitude: lon + 0.005
                )
            ]
            
            self.allDeals = fallbackDeals
            self.applyFilter(selectedFilter)
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
