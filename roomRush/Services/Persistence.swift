
import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for i in 0..<10 {
            let newDeal = CachedDeal(context: viewContext)
            newDeal.id = "PREVIEW_\(i)"
                        newDeal.title = "Preview Hotel \(i)"
                        newDeal.roomName = "Luxury Suite"
                        newDeal.locationName = "Mechelen"
                        newDeal.price = 100 + Double(i * 10)
                        newDeal.originalPrice = 200
                        newDeal.roomsLeft = 3
                        newDeal.rating = 4.5
                        newDeal.imageUrl = "https://images.unsplash.com/photo-1566073771259-6a8506099945"
                        newDeal.type = "Hotel"
                        newDeal.latitude = 51.0259
                        newDeal.longitude = 4.4776
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "roomRush")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                print("❌ Core Data Error: \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
