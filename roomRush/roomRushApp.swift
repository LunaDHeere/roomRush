//
//  roomRushApp.swift
//  roomRush
//
//  Created by Amina Iqbal on 22/12/2025.
//

import SwiftUI
import CoreData

@main
struct roomRushApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
