import Foundation

struct User: Codable, Identifiable {
    let id: String
    var fullname: String
    var email: String
    var favourites : [String] = []
    var hasCompletedOnboarding: Bool = false
    var city: String = ""
    
    var initials: String {
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: fullname) {
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
        return ""
    }
}
