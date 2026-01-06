import Foundation
import FirebaseFirestore
import SwiftUI
import Combine
import CoreData
import CoreLocation

@MainActor
class HomeViewModel: ObservableObject {
    @Published var deals = [Deal]()
    @Published private var allDeals = [Deal]()
    @Published var isLoading = false
    @Published var lastFetchTime: Date? = nil
    @Published var selectedFilter = "All Deals"
    @Published var showNotification = true
    @Published var isOffline = false
    
    private let apiManager = APIManager()
    private let container = PersistenceController.shared.container
    
    private let lastUpdateKey = "LastServiceUpdate"
    
    init() {
        // Load the persistent timestamp when the ViewModel is created
        if let savedDate = UserDefaults.standard.object(forKey: lastUpdateKey) as? Date {
            self.lastFetchTime = savedDate
        }
        loadFromCoreData()
    }
    
    func fetchDealsFromAPI(lat: Double, lon: Double, city: String) async {
        guard !isLoading else { return }
        
        self.isLoading = true
        self.isOffline = false
        defer{ self.isLoading = false}
        
        do{
            let amadeusHotels = try await apiManager.fetchHotels(lat: lat, lon: lon)
            
            let fetchedDeals = amadeusHotels.map {
                hotel in Deal(
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
            saveToCoreData(fetchedDeals)
            
            let now = Date()
            self.lastFetchTime = now
            UserDefaults.standard.set(now, forKey: lastUpdateKey)
            
            self.allDeals = fetchedDeals
            self.applyFilter(selectedFilter)
        } catch {
            self.isOffline = true
            loadFromCoreData()
        }
    }

    
    private func saveToCoreData(_ fetchedDeals: [Deal]) {
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = CachedDeal.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest) // Clear old cache
            for deal in fetchedDeals {
                let cached = CachedDeal(context: context)
                cached.id = deal.id
                cached.title = deal.title
                cached.roomName = deal.roomName
                cached.locationName = deal.locationName
                cached.price = Double(deal.price)
                cached.originalPrice = Double(deal.originalPrice)
                cached.roomsLeft = Int64(deal.roomsLeft)
                cached.rating = deal.rating
                cached.imageUrl = deal.imageUrl
                cached.type = deal.type
                cached.latitude = deal.latitude
                cached.longitude = deal.longitude
            }
            try context.save()
        } catch {
            print("❌ Core Data Save Error: \(error.localizedDescription)")
        }
    }
    
    private func loadFromCoreData() {
        let context = container.viewContext
        let request: NSFetchRequest<CachedDeal> = CachedDeal.fetchRequest()
        do {
            let results = try context.fetch(request)
            self.allDeals = results.map { cached in
                Deal(
                    id: cached.id ?? UUID().uuidString,
                    title: cached.title ?? "Unknown",
                    roomName: cached.roomName ?? "Standard Room",
                    locationName: cached.locationName ?? "Nearby",
                    price: Int(cached.price),
                    originalPrice: Int(cached.originalPrice),
                    roomsLeft: Int(cached.roomsLeft),
                    rating: cached.rating,
                    imageUrl: cached.imageUrl ?? "",
                    type: cached.type ?? "Hotel",
                    latitude: cached.latitude,
                    longitude: cached.longitude
                )
            }
            self.applyFilter(selectedFilter)
        } catch {
            print("❌ Core Data Load Error")
        }
    }
    
    // MARK: - Random Exam Fallback
    private func generateRandomMockDeals(lat: Double, lon: Double, city: String) {
        let hotelNames = ["Grand \(city) Inn", "The \(city) Plaza", "Riverside Suites", "Urban Nomad Hostel", "Blue Harbor Hotel"]
        
        let mockDeals = hotelNames.indices.map { i in
            let original = Int.random(in: 150...250)
            return Deal(
                id: "MOCK_\(i)",
                title: hotelNames[i],
                roomName: "Exam Fallback Room",
                locationName: city,
                price: Int(Double(original) * 0.6), // 40% discount
                originalPrice: original,
                roomsLeft: Int.random(in: 1...5),
                rating: Double.random(in: 4.0...4.9),
                imageUrl: "https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=800&q=80",
                type: i == 3 ? "Hostel" : "Hotel",
                latitude: lat + (Double.random(in: -0.01...0.01)),
                longitude: lon + (Double.random(in: -0.01...0.01))
            )
        }
        self.allDeals = mockDeals
        self.applyFilter(selectedFilter)
    }
    func updateLocationAndFetch(location: CLLocation?, city: String) async {
        guard let coord = location?.coordinate else { return }
        
        UserDefaults.standard.set(coord.latitude, forKey: "lastLat")
        UserDefaults.standard.set(coord.longitude, forKey: "lastLon")
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
    func refreshDeals(lat: Double, lon: Double, city: String) async {
        await fetchDealsFromAPI(lat: lat, lon: lon, city: city)
    }
}


extension Date {
    func friendlyLastUpdated() -> String {
        let secondsAgo = Int(Date().timeIntervalSince(self))
        
        if secondsAgo < 60 {
            return "Updated just now"
        }
        
        let minutesAgo = secondsAgo / 60
        
        if minutesAgo < 60 {
            return "Updated \(minutesAgo) minute\(minutesAgo == 1 ? "" : "s") ago"
        }
        
        let hoursAgo = minutesAgo / 60

        if hoursAgo < 24 {
            return "Updated \(hoursAgo) hour\(hoursAgo == 1 ? "" : "s") ago"
        }

        let daysAgo = hoursAgo / 24
        
        return "Updated \(daysAgo) day\(daysAgo == 1 ? "" : "s") ago"
        }
        }
