import Foundation
import FirebaseFirestore

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
}
