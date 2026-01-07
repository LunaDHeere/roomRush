import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @AppStorage("useMiles") private var useMiles = false
    
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                LinearGradient(gradient: Gradient(colors: [Color.blue, Color(red: 0.1, green: 0.4, blue: 0.8)]), startPoint: .top, endPoint: .bottom)
                    .frame(height: 150)
                    .overlay(
                        VStack(alignment: .leading) {
                            Text("Profile")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(.white)
                            Text("Manage your account")
                                .font(.system(size: 14))
                                .foregroundColor(Color.blue.opacity(0.2))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.top, 20)
                    )
                
                VStack(spacing: 20) {
                    HStack(spacing: 15) {
                        Circle()
                            .fill(LinearGradient(gradient: Gradient(colors: [.blue.opacity(0.7), .blue]), startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 65, height: 65)
                            .overlay(Text(viewModel.currentUser?.initials ?? "??").foregroundColor(.white).bold())
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text(viewModel.currentUser?.fullname ?? "Guest User")
                                .font(.headline)
                                .foregroundColor(.black)
                            
                            Text(viewModel.currentUser?.email ?? "email@example.com")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
                    .padding(.top, -35)
                    VStack(spacing: 15) {
                        MenuSection(title: "Account") {
                            MenuItem(icon: "person", label: "Personal Information")
                            MenuItem(icon: "mappin", label: "Saved Locations")
                        }
                        
                        MenuSection(title: "Preferences") {
                            HStack {
                                Image(systemName: "ruler")
                                    .foregroundColor(.gray)
                                    .frame(width: 25)
                                
                                Text("Distance Unit")
                                    .foregroundColor(.black)
                                
                                Spacer()
                                
                                Toggle("", isOn: $useMiles)
                                    .labelsHidden()
                                
                                Text(useMiles ? "Miles" : "KM")
                                    .font(.caption)
                                    .bold()
                                    .foregroundColor(.blue)
                                    .frame(width: 35)
                            }
                            .padding()
                        }
                        
                        MenuSection(title: "Support") {
                            MenuItem(icon: "questionmark.circle", label: "Help & Support") {
                                if let url = URL(string: "https://github.com/LunaDHeere/roomRush") {
                                    UIApplication.shared.open(url)
                                }
                            }
                            
                            MenuItem(icon: "rectangle.portrait.and.arrow.right", label: "Sign Out", isDanger: true) {
                                viewModel.signOut()
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .background(Color(red: 0.98, green: 0.98, blue: 1.0))
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
        VStack(alignment: .leading, spacing: 10) {
            Text(title.uppercased()).font(.caption2).bold().foregroundColor(.gray).padding(.leading, 5)
            VStack(spacing: 0) { content }.background(Color.white).cornerRadius(20)
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
            HStack {
                Image(systemName: icon).foregroundColor(isDanger ? .red : .gray).frame(width: 25)
                Text(label).foregroundColor(isDanger ? .red : .black)
                Spacer()
                if let badge = badge {
                    Text(badge).font(.caption2).bold().padding(5).background(Color.blue).foregroundColor(.white).clipShape(Circle())
                }
                Image(systemName: "chevron.right").font(.caption).foregroundColor(.gray)
            }
            .padding()
        }
        Divider().padding(.leading, 50)
    }
}
