
import Foundation
import FirebaseFirestore
import Combine
import SwiftUI

@MainActor
class HomeViewModel: ObservableObject {
    @Published var deals = [Deal]()
    @Published var isLoading = false
    @Published var showNotification = true
    @Published var lastFetchTime : Date?
    @Published var allDeals = [Deal]()
    @Published var selectedFilter = "All Deals"
    
    private let apiManager = APIManager()
    private let db = Firestore.firestore()
    
    
    func fetchDeals() {
        self.isLoading = true
        
        db.collection("deals").getDocuments { snapshot, error in
            Task { @MainActor in
                self.isLoading = false
                if let error = error {
                    print("Error fetching deals: \(error.localizedDescription)")
                    return
                }
                
                self.deals = snapshot?.documents.compactMap { document in
                    try? document.data(as: Deal.self)
                } ?? []
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
            // Note: Amadeus mostly returns Hotels, so this might be empty unless you seed it
            self.deals = allDeals.filter { $0.type == "Hostel" }
        default:
            self.deals = allDeals // "All Deals" shows everything
        }
    }
    
    func testAmadeus(lat: Double, lon: Double) {
        self.isLoading = true
        self.deals.removeAll()
        
        Task {
            do {
                let amadeusHotels = try await apiManager.fetchHotels(lat: lat, lon: lon)
                
                // This is the magic part: turning Amadeus data into RoomRush Deals
                let fetchedDeals = amadeusHotels.map { hotel in
                    Deal(
                        id: hotel.hotelId,
                        title: hotel.name,
                        roomName: "Last-Minute Special",
                        locationName: "Mechelen",
                        price: Int.random(in: 85...140), // Real pricing needs a 2nd API call, so we use random for now
                        originalPrice: Int.random(in: 160...210),
                        roomsLeft: Int.random(in: 1...4),
                        rating: Double.random(in: 4.1...4.8),
                        imageUrl: "https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=800&q=80",
                        type: "Hotel",
                        latitude: hotel.geoCode.latitude,
                        longitude: hotel.geoCode.longitude
                    )
                }
                self.lastFetchTime = Date()
                self.isLoading = false
                self.allDeals = fetchedDeals
                self.deals = fetchedDeals
                print("✅ UI Updated with \(self.deals.count) real hotels!")
            } catch {
                print("❌ Error mapping data: \(error)")
                self.isLoading = false
            }
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
