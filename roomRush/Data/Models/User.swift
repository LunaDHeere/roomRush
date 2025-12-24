import Foundation

struct User: Codable, Identifiable {
    var id: String
    var fullname: String
    var email: String
    var bookingsCount: Int = 0
    var savedCount: Int = 0
    var totalSavedMoney: String = "$0"
    
    var initials: String {
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: fullname) {
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
        return ""
    }
}
