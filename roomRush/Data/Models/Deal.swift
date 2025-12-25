import Foundation
import FirebaseFirestore

struct Deal: Identifiable, Codable, Sendable {
    @DocumentID var id: String?
    var title: String        // Hotel Name
    var roomName: String     // e.g. "Deluxe Double Room"
    var locationName: String
    var price: Int           // Current Price
    var originalPrice: Int   // Price before discount
    var roomsLeft: Int       // e.g. 3
    var rating: Double
    var imageUrl: String
    var type: String
    var latitude: Double
    var longitude: Double
    
    // Helper to calculate discount percentage
    var discountPercentage: Int {
        let diff = originalPrice - price
        return Int((Double(diff) / Double(originalPrice)) * 100)
    }
}
