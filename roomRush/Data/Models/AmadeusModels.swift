
struct TokenResponse: Codable, Sendable {
    let access_token: String
}

struct HotelResponse: Codable, Sendable {
    let data: [AmadeusHotel]
    let meta: [String: AnyCodable]?
}

struct AmadeusHotel: Codable, Sendable {
    let name: String
    let hotelId: String
    let geoCode: AmadeusGeoCode
    let address: AmadeusAddress?
    
    struct AmadeusGeoCode: Codable, Sendable {
        let latitude: Double
        let longitude: Double
    }
    struct AmadeusAddress: Codable, Sendable {
            let cityName: String?
        }
}

struct AnyCodable: Codable, Sendable {}
