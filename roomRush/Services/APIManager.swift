
import Foundation
import Combine

class APIManager: ObservableObject {
    private let apiKey = "NEaU5esMuHjZGBSHTtGrtbZoA9D2RSDi"
    private let apiSecret = "QSa6KF0TPxl9DPSx"
    private var accessToken: String?

    // Step 1: Get the Token
    func getAccessToken() async throws -> String {
        if let token = accessToken { return token } // Return existing if valid
        
        let url = URL(string: "https://test.api.amadeus.com/v1/security/oauth2/token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let body = "grant_type=client_credentials&client_id=\(apiKey)&client_secret=\(apiSecret)"
        request.httpBody = body.data(using: .utf8)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(TokenResponse.self, from: data)
        
        self.accessToken = response.access_token
        return response.access_token
    }

    // Step 2: Fetch Hotels by GPS
    func fetchHotels(lat: Double, lon: Double) async throws -> [AmadeusHotel] {
        let token = try await getAccessToken()
        
        let urlString = "https://test.api.amadeus.com/v1/reference-data/locations/hotels/by-geocode?latitude=\(lat)&longitude=\(lon)&radius=5&radiusUnit=KM"
        
        guard let url = URL(string: urlString) else { return [] }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        // Attempt to decode
        let response = try JSONDecoder().decode(HotelResponse.self, from: data)
        
        // --- TEST LOGS ---
        print("--- AMADEUS TEST START ---")
        print("Found \(response.data.count) hotels near you.")
        for hotel in response.data {
            print("🏨 Name: \(hotel.name) | ID: \(hotel.hotelId)")
        }
        print("--- AMADEUS TEST END ---")
        // -----------------
        
        return response.data
    }
}

// Helper struct for Token
struct TokenResponse: Codable {
    let access_token: String
}

struct HotelResponse: Codable {
    let data: [AmadeusHotel]
}

struct AmadeusHotel: Codable {
    let name: String
    let hotelId: String
    let geoCode: AmadeusGeoCode
    
    // We can use these to create our Deal objects
    struct AmadeusGeoCode: Codable {
        let latitude: Double
        let longitude: Double
    }
}
