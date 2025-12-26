
import Foundation
import Combine

class APIManager: ObservableObject {
    private let apiKey = "NEaU5esMuHjZGBSHTtGrtbZoA9D2RSDi"
    private let apiSecret = "QSa6KF0TPxl9DPSx"
    private var accessToken: String?
    
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
        
        // We force coordinates to 4 decimal places as some APIs are picky
        let urlString = "https://test.api.amadeus.com/v1/reference-data/locations/hotels/by-geocode?latitude=\(String(format: "%.4f", lat))&longitude=\(String(format: "%.4f", lon))&radius=5&radiusUnit=KM"
        
        guard let url = URL(string: urlString) else { return [] }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Check for HTTP errors (like 400 or 401) before decoding
        if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
            let errorBody = String(data: data, encoding: .utf8) ?? "Unknown Error"
            print("❌ Server Error (\(httpResponse.statusCode)): \(errorBody)")
        }
        
        do {
            let response = try JSONDecoder().decode(HotelResponse.self, from: data)
            print("✅ Successfully decoded \(response.data.count) hotels")
            return response.data
        } catch {
            // This is the magic line: it prints what the API ACTUALLY sent
            if let rawJSON = String(data: data, encoding: .utf8) {
                print("❌ Raw JSON received: \(rawJSON)")
            }
            print("❌ Decoding Error: \(error)")
            throw error
        }
    }
}

// Helper struct for Token
struct TokenResponse: Codable {
    let access_token: String
}

struct HotelResponse: Codable {
    let data: [AmadeusHotel]
    let meta: [String: AnyCodable]?
}

struct AmadeusHotel: Codable {
    let name: String
    let hotelId: String
    let geoCode: AmadeusGeoCode
    let address: AmadeusAddress?
    // We can use these to create our Deal objects
    struct AmadeusGeoCode: Codable {
        let latitude: Double
        let longitude: Double
    }
    struct AmadeusAddress: Codable {
            let cityName: String?
        }
}

struct AnyCodable: Codable {}
