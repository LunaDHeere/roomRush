import SwiftUI

struct OfflinePopup: View {
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "wifi.slash")
                .foregroundColor(.white)
                .font(.system(size: 18, weight: .bold))
            
            VStack(alignment: .leading, spacing: 2) {
                Text("You're offline")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                Text("Showing cached deals from your last visit.")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.8))
            }
            Spacer()
        }
        .padding()
        .background(Color.red.opacity(0.9))
        .cornerRadius(12)
        .shadow(radius: 4)
        .padding(.horizontal)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}
