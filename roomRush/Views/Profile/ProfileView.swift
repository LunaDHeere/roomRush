import SwiftUI

struct ProfileView: View {
    @ObservedObject var viewModel: AuthViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // MARK: - Header
                ZStack(alignment: .bottomLeading) {
                    AppColors.primaryGradient
                        .frame(height: 160)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Profile")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                        Text("Manage your account")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
                
                VStack(spacing: 20) {
                    // MARK: - Profile Card
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(AppColors.avatarGradient)
                                .frame(width: 64, height: 64)
                            Image(systemName: "person.fill")
                                .font(.title)
                                .foregroundColor(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Guest User")
                                .font(.headline)
                            Text(viewModel.email.isEmpty ? "guest@example.com" : viewModel.email)
                                .foregroundColor(AppColors.secondaryText)
                        }
                        
                        Spacer()
                        
                        Button("Edit") {
                            // Edit Action
                        }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.blue)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                    .padding(.top, -30) // Overlaps header
                    
                    // MARK: - Stats
                    HStack(spacing: 12) {
                        StatCard(value: "12", label: "Bookings")
                        StatCard(value: "8", label: "Saved")
                        StatCard(value: "$342", label: "Saved")
                    }
                    
                    // MARK: - Menu Sections
                    VStack(spacing: 24) {
                        MenuSection(title: "Account") {
                            MenuItem(icon: "person", label: "Personal Information")
                            MenuItem(icon: "creditcard", label: "Payment Methods")
                            MenuItem(icon: "mappin.and.ellipse", label: "Saved Locations")
                        }
                        
                        MenuSection(title: "Preferences") {
                            MenuItem(icon: "bell", label: "Notifications", badge: "3")
                            MenuItem(icon: "gearshape", label: "App Settings")
                        }
                        
                        MenuSection(title: "Support") {
                            MenuItem(icon: "questionmark.circle", label: "Help & Support")
                            MenuItem(icon: "rectangle.portrait.and.arrow.right", label: "Sign Out", isDanger: true) {
                                viewModel.signOut()
                            }
                        }
                    }
                    .padding(.bottom, 30)
                }
                .padding(.horizontal, 20)
            }
        }
        .background(AppColors.screenBackground)
        .ignoresSafeArea(edges: .top)
    }
}

// MARK: - Supporting Components

struct StatCard: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 18, weight: .bold))
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
    }
}

struct MenuSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.gray)
                .kerning(1)
                .padding(.leading, 4)
            
            VStack(spacing: 0) {
                content
            }
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
        }
    }
}

struct MenuItem: View {
    let icon: String
    let label: String
    var badge: String? = nil
    var isDanger: Bool = false
    var action: (() -> Void)? = nil
    
    var body: some View {
        Button(action: { action?() }) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(isDanger ? AppColors.danger : .primary)
                    .frame(width: 24)
                
                Text(label)
                    .foregroundColor(isDanger ? .red : .primary)
                
                Spacer()
                
                if let badge = badge {
                    Text(badge)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.blue)
                        .clipShape(Capsule())
                }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.gray.opacity(0.5))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        Divider().padding(.leading, 50) // Matches Figma's inset divider
    }
}
