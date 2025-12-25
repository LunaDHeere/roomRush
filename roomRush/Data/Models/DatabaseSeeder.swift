
import Foundation
import FirebaseFirestore

struct DatabaseSeeder {
    
    private let db = Firestore.firestore()
    
    // MARK: - Public Entry Point
    func seedIfNeeded() async {
        let settingsRef = db.collection("settings").document("seed")
        
        do {
            let snapshot = try await settingsRef.getDocument()
            
            if snapshot.exists {
                print("Database already seeded")
                return
            }
            
            try await seedUsers()
            try await seedDeals()
            try await settingsRef.setData(["seeded": true])
            print("Database seeded successfully")
            
        } catch {
            print("Seeding failed: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Seed Users
    private func seedUsers() async throws {
        let users = [
            User(id: "user_1", fullname: "Sarah Jenkins", email: "sarah@example.com", bookingsCount: 5, savedCount: 12, totalSavedMoney: "$1,200"),
            User(id: "user_2", fullname: "Michael Chen", email: "m.chen@tech.com", bookingsCount: 2, savedCount: 4, totalSavedMoney: "$450"),
            User(id: "user_3", fullname: "Alex Rivera", email: "alex@design.io", bookingsCount: 15, savedCount: 30, totalSavedMoney: "$4,200"),
            User(id: "user_4", fullname: "Emma Wilson", email: "emma.w@columbia.edu", bookingsCount: 0, savedCount: 8, totalSavedMoney: "$150"),
            User(id: "user_5", fullname: "Guest User", email: "guest@roomrush.com", bookingsCount: 1, savedCount: 1, totalSavedMoney: "$50")
        ]
        
        for user in users {
            try db.collection("users")
                .document(user.id)
                .setData(from: user)
        }
    }
    
    // MARK: - seed deals
    private func seedDeals() async throws {
        let deals = [
            Deal(title: "Martin's Patershof",
                 roomName: "Cosy Church Room",
                 locationName: "Mechelen Center",
                 price: 145,
                 originalPrice: 210,
                 roomsLeft: 2,
                 rating: 4.8,
                 imageUrl: "https://images.unsplash.com/photo-1542314831-068cd1dbfeeb",
                 type: "Hotel",
                 latitude: 51.0264,
                 longitude: 4.4733),
            
            Deal(title: "Vixx Hotel",
                 roomName: "Luxury Suite with Sauna",
                 locationName: "Mechelen Center",
                 price: 180,
                 originalPrice: 250,
                 roomsLeft: 1,
                 rating: 4.9,
                 imageUrl: "https://images.unsplash.com/photo-1520250497591-112f2f40a3f4",
                 type: "Boutique",
                 latitude: 51.0285,
                 longitude: 4.4795)
        ]
        
        for deal in deals {
            _ = try db.collection("deals").addDocument(from: deal)
        }
    }
}
