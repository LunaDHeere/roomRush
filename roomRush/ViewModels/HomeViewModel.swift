
import Foundation
import FirebaseFirestore
import Combine
import SwiftUI

@MainActor
class HomeViewModel: ObservableObject {
    @Published var deals = [Deal]()
    @Published var isLoading = false
    @Published var showNotification = true
    
    private let db = Firestore.firestore()
    
    func fetchDeals() {
        self.isLoading = true
        
        db.collection("deals").getDocuments { snapshot, error in
            Task { @MainActor in
                self.isLoading = false
                if let error = error {
                    print("Error fetching deals: \(error.localizedDescription)")
                    return
                }
                
                self.deals = snapshot?.documents.compactMap { document in
                    try? document.data(as: Deal.self)
                } ?? []
            }
        }
    }
}
