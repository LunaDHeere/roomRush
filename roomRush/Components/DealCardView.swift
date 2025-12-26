import SwiftUI
import Kingfisher

struct DealCardView: View {
    let deal: Deal
    let isFavourited: Bool
    let onToggleFavourite: () -> Void
    
    // Logic for randomized distance based on the hotel ID
    var distance: Double {
        Double(abs(deal.id.hashValue % 50)) / 10.0 + 0.5
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // MARK: - Image & Badges
            ZStack(alignment: .topTrailing) {
                KFImage(URL(string: deal.imageUrl))
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
                    .clipped()
                
                // Discount Badge (Top Left)
                badgeView(text: "-\(deal.discountPercentage)%", color: .red, alignment: .topLeading)
                
                // Favorite Button (Top Right)
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
                
                // Availability Badge (Bottom Left)
                badgeView(text: "Only \(deal.roomsLeft) left", color: .green, alignment: .bottomLeading)
            }
            
            // MARK: - Details
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(deal.title)
                            .font(.system(size: 18, weight: .semibold))
                        Text(deal.roomName)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    ratingBadge
                }
                
                Label("\(String(format: "%.1f", distance)) km away", systemImage: "mappin.circle")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                
                priceRow
            }
            .padding(16)
        }
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
    }
    
    // MARK: - Helper Subviews
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
                Text("$\(deal.price)").font(.system(size: 24, weight: .bold))
                Text("/night").font(.system(size: 14)).foregroundColor(.secondary)
            }
            Text("$\(deal.originalPrice)")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .strikethrough()
                .padding(.bottom, 2)
        }
    }
}
