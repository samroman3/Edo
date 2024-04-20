//
//  caloriecounterApp.swift
//  caloriecounter
//
//  Created by Sam Roman on 11/24/23.
//

import SwiftUI
import SwiftData

@main
struct caloriecounterApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject var dataStore = NutritionDataStore(context: PersistenceController.shared.container.viewContext)
    @StateObject var dailyLogManager = DailyLogManager(context: PersistenceController.shared.container.viewContext)
    @StateObject var userSettingsManager = UserSettingsManager(context: PersistenceController.shared.container.viewContext)

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(dataStore)
                .environmentObject(userSettingsManager)
                .environmentObject(dailyLogManager)
                .environmentObject(AppState.shared)
        }
    }
}

