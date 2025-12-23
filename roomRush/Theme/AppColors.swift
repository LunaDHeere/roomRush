import SwiftUI

enum AppColors {
    // Brand
    static let primary = Color.blue
    static let primarySoft = Color.blue.opacity(0.8)
    static let primaryGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color.blue,
            Color.blue.opacity(0.8)
        ]),
        startPoint: .top,
        endPoint: .bottom
    )

    static let avatarGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color.blue.opacity(0.6),
            Color.blue
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // Text
    static let secondaryText = Color.gray
    static let divider = Color.gray.opacity(0.3)

    // Backgrounds
    static let screenBackground = Color(red: 0.98, green: 0.98, blue: 0.98)
    static let cardBackground = Color.white

    // Status
    static let danger = Color.red
}
