import SwiftUI
import Kingfisher
import CoreLocation

struct DealCardView: View {
    let deal: Deal
    let isFavourited: Bool
    let onToggleFavourite: () -> Void
    let userLat: Double
    let userLon: Double
    
    @Environment(\.openURL) var openURL
    @AppStorage("useMiles") private var useMiles = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                KFImage(URL(string: deal.imageUrl))
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
                    .clipped()

                badgeView(text: "-\(deal.discountPercentage)%", color: .red, alignment: .topLeading)
                Button(action: onToggleFavourite) {
                    Image(systemName: isFavourited ? "heart.fill" : "heart")
                        .font(.system(size: 18))
                        .foregroundColor(isFavourited ? .red : .gray)
                        .padding(10)
                        .background(Color.white.opacity(0.9))
                        .clipShape(Circle())
                        .shadow(radius: 2)
                }
                .padding(12)
                badgeView(text: "Only \(deal.roomsLeft) left", color: .green, alignment: .bottomLeading)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(deal.title)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.black)
                        Text(deal.roomName)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    ratingBadge
                }
                
                Label(deal.distance(from: userLat, userLon, useMiles: useMiles), systemImage: "mappin.circle")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
                
                priceRow
            }
            .padding(16)
        }
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
        .onTapGesture {
            openBookingCom()
        }
    }
        private func openBookingCom() {
            let hotelLocation = CLLocation(latitude: deal.latitude, longitude: deal.longitude)
            let geocoder = CLGeocoder()
            
            geocoder.reverseGeocodeLocation(hotelLocation) { placemarks, error in
                var cityToSearch = deal.locationName
                if let placemark = placemarks?.first, let locality = placemark.locality {
                    cityToSearch = locality
                }

                let query = "\(deal.title) \(cityToSearch)"
                var components = URLComponents(string: "https://www.booking.com/searchresults.html")
                components?.queryItems = [
                    URLQueryItem(name: "ss", value: query),
                    URLQueryItem(name: "latitude", value: String(deal.latitude)),
                    URLQueryItem(name: "longitude", value: String(deal.longitude))
                ]
                if let url = components?.url {
                    openURL(url)
                }
            }
        }
    
    private func badgeView(text: String, color: Color, alignment: Alignment) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .bold))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(color)
            .foregroundColor(.white)
            .cornerRadius(20)
            .padding(12)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
    }
    
    private var ratingBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill").font(.system(size: 12))
            Text(String(format: "%.1f", deal.rating))
                .font(.system(size: 14, weight: .bold))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.blue.opacity(0.1))
        .foregroundColor(.blue)
        .cornerRadius(8)
    }
    
    private var priceRow: some View {
        HStack(alignment: .bottom, spacing: 6) {
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text("$\(deal.price)").font(.system(size: 24, weight: .bold)).foregroundColor(.gray)
                Text("/night").font(.system(size: 14)).foregroundColor(.gray)
            }
            Text("$\(deal.originalPrice)")
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .strikethrough()
                .padding(.bottom, 2)
        }
    }
}
