
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
    
    struct AmadeusGeoCode: Codable {
        let latitude: Double
        let longitude: Double
    }
    struct AmadeusAddress: Codable {
            let cityName: String?
        }
}

struct AnyCodable: Codable {}
