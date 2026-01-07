import SwiftUI

struct OfflinePopup: View {
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "wifi.slash")
                .foregroundColor(.white)
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("You're offline")
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                Text("Showing cached deals from your last visit.")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            Spacer()
        }
        .padding()
        .background(Color.red.opacity(0.9))
        .cornerRadius(12)
        .shadow(radius: 4)
        .padding(.horizontal)
        
        //could be removed because maybe i should just put this in the if statement in the parent view
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}
