import Foundation
import Combine

@MainActor
class APIManager: ObservableObject {
    private var apiKey: String {
        return Bundle.main.object(forInfoDictionaryKey: "AmadeusAPIKey") as? String ?? ""
    }
    private var apiSecret: String {
        return Bundle.main.object(forInfoDictionaryKey: "AmadeusAPISecret") as? String ?? ""
    }
    private var accessToken: String?
    // Inside APIManager
    private var accessTokenTask: Task<String, Error>?

    // In APIManager.swift

    func getAccessToken() async throws -> String {
        // 1. Return existing token if valid
        if let token = accessToken { return token }
        
        // 2. Return existing running task if available
        if let task = accessTokenTask {
            return try await task.value
        }
        
        // 3. KEY FIX: Use 'Task.detached' with 'priority: .userInitiated'
        // This effectively "cuts the wire" between the View's lifecycle and the API call.
        // If the View dies, this task keeps running.
        let task = Task.detached(priority: .userInitiated) { [apiKey, apiSecret] in
            let url = URL(string: "https://test.api.amadeus.com/v1/security/oauth2/token")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.httpBody = "grant_type=client_credentials&client_id=\(apiKey)&client_secret=\(apiSecret)".data(using: .utf8)
            
            // standard URLSession request
            let (data, _) = try await URLSession.shared.data(for: request)
            let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
            return tokenResponse.access_token
        }
        
        self.accessTokenTask = task
        
        do {
            let token = try await task.value
            await MainActor.run {
                self.accessToken = token
                self.accessTokenTask = nil
            }
            return token
        } catch {
            await MainActor.run {
                self.accessTokenTask = nil
            }
            // If it was actually cancelled (rare with detached), retry once
            if (error as? URLError)?.code == .cancelled {
                print("⚠️ Token task was cancelled, retrying...")
                self.accessTokenTask = nil
                return try await getAccessToken()
            }
            throw error
        }
    }

    func fetchHotels(lat: Double, lon: Double) async throws -> [AmadeusHotel] {
        let token = try await getAccessToken()
        
        // Use %.4f to ensure the API doesn't get confused by high precision doubles
        let urlString = "https://test.api.amadeus.com/v1/reference-data/locations/hotels/by-geocode?latitude=\(String(format: "%.4f", lat))&longitude=\(String(format: "%.4f", lon))&radius=5&radiusUnit=KM"
        
        guard let url = URL(string: urlString) else { return [] }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        // Modern async call
        let (data, response) = try await URLSession.shared.data(for: request)

        if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
            let errorBody = String(data: data, encoding: .utf8) ?? ""
            print("❌ Server Error (\(httpResponse.statusCode)): \(errorBody)")
            
            // If token expired (401), clear it so we fetch a new one next time
            if httpResponse.statusCode == 401 { self.accessToken = nil }
        }

        let hotelResponse = try JSONDecoder().decode(HotelResponse.self, from: data)
        print("✅ Successfully decoded \(hotelResponse.data.count) hotels")
        return hotelResponse.data
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
