
import SwiftUI
import CoreData
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct roomRushApp: App {
    @StateObject var authViewModel = AuthViewModel()
    @StateObject var homeViewModel = HomeViewModel()
    @StateObject var networkMonitor = NetworkMonitor()
    
    //making this variable private bc i don't want any reassigning to happen in any case
    @StateObject private var locationManager = LocationManager()
    
    let persistenceController = PersistenceController.shared
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .environmentObject(homeViewModel)
                .environmentObject(networkMonitor)
                .environmentObject(locationManager)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
