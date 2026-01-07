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
    private var accessTokenTask: Task<String, Error>?

    func getAccessToken() async throws -> String {
        if let token = accessToken { return token }

        if let task = accessTokenTask {
            return try await task.value
        }

        let task = Task(priority: .userInitiated) { [apiKey, apiSecret] in
            let url = URL(string: "https://test.api.amadeus.com/v1/security/oauth2/token")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.httpBody = "grant_type=client_credentials&client_id=\(apiKey)&client_secret=\(apiSecret)".data(using: .utf8)
 
            let (data, _) = try await URLSession.shared.data(for: request)
            let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
            return tokenResponse.access_token
        }
        
        self.accessTokenTask = task
        
        do {
            let token = try await task.value
            self.accessToken = token
            self.accessTokenTask = nil
            return token
        } catch {
            self.accessTokenTask = nil
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
        let urlString = "https://test.api.amadeus.com/v1/reference-data/locations/hotels/by-geocode?latitude=\(String(format: "%.4f", lat))&longitude=\(String(format: "%.4f", lon))&radius=5&radiusUnit=KM"
        
        guard let url = URL(string: urlString) else { return [] }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
            let errorBody = String(data: data, encoding: .utf8) ?? ""
            print("❌ Server Error (\(httpResponse.statusCode)): \(errorBody)")
            
            if httpResponse.statusCode == 401 { self.accessToken = nil }
        }

        let hotelResponse = try JSONDecoder().decode(HotelResponse.self, from: data)
        print("✅ Successfully decoded \(hotelResponse.data.count) hotels")
        return hotelResponse.data
    }
}
