
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
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Text("Last-Minute Deals")
                .font(.title2.bold())
                .foregroundColor(.black)
            Text(timeAgo)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white)
    }
}
