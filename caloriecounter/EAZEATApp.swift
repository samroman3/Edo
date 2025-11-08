import SwiftUI

@main
struct EAZEATApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject var dataStore = NutritionDataStore(context: PersistenceController.shared.container.viewContext)
    @StateObject var userSettingsManager = UserSettingsManager(context: PersistenceController.shared.container.viewContext)

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(dataStore)
                .environmentObject(userSettingsManager)
                .environmentObject(AppState.shared)
        }
    }
}
