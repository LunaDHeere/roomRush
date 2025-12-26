
import SwiftUI

struct HeaderSection: View {
    let city: String
    let timeAgo: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: "mappin.and.ellipse")
                    .foregroundColor(.blue)
                Text(city)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            Text("Last-Minute Deals")
                .font(.system(size: 24, weight: .bold))
            Text("Updated \(timeAgo)")
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white)
    }
}
