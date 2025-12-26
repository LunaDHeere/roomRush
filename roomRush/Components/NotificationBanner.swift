
import SwiftUI

struct NotificationBanner: View {
    var body: some View {
        HStack {
            Image(systemName: "bell.fill")
            VStack(alignment: .leading) {
                Text("New deal alert!").bold()
                Text("3 rooms available within 5 km").font(.caption)
            }
            Spacer()
            Button("View") { 
                // Action logic here
            }.underline()
        }
        .padding()
        .background(Color.blue)
        .foregroundColor(.white)
    }
}
