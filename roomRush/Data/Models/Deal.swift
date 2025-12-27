import Foundation
import FirebaseFirestore
import CoreLocation

struct Deal: Identifiable, Codable, Sendable {

    var id: String
    var title: String
    var roomName: String
    var locationName: String
    var price: Int
    var originalPrice: Int
    var roomsLeft: Int
    var rating: Double
    var imageUrl: String
    var type: String
    var latitude: Double
    var longitude: Double
    
    var discountPercentage: Int {
        let diff = originalPrice - price
        guard originalPrice > 0 else { return 0 }
        return Int((Double(diff) / Double(originalPrice)) * 100)
    }
    
    func distance(from userLat: Double, _ userLon: Double, useMiles: Bool) -> String {
            let userLocation = CLLocation(latitude: userLat, longitude: userLon)
            let hotelLocation = CLLocation(latitude: self.latitude, longitude: self.longitude)
            
            let distanceInMeters = userLocation.distance(from: hotelLocation)
            
            if useMiles {
                let miles = distanceInMeters / 1609.34
                return String(format: "%.1f miles away", miles)
            } else {
                let km = distanceInMeters / 1000.0
                return String(format: "%.1f km away", km)
            }
        }
    }
