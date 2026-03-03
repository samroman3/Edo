import SwiftUI

@main
struct EAZEATApp: App {
    private let persistenceController: PersistenceController
    @StateObject private var dataStore: NutritionDataStore
    @StateObject private var userSettingsManager: UserSettingsManager
    @StateObject private var dailyLogManager: DailyLogManager
    @StateObject private var weeklyLogManager: WeeklyLogManager
    @StateObject private var mealSelectionViewModel: MealSelectionViewModel
    @StateObject private var themeManager: ThemeManager

    init() {
        let persistenceController = PersistenceController.shared
        let context = persistenceController.container.viewContext
        let dataStore = NutritionDataStore(context: context)
        let userSettingsManager = UserSettingsManager(context: context)

        self.persistenceController = persistenceController
        _dataStore = StateObject(wrappedValue: dataStore)
        _userSettingsManager = StateObject(wrappedValue: userSettingsManager)
        _dailyLogManager = StateObject(wrappedValue: DailyLogManager(context: context, userSettings: userSettingsManager))
        _weeklyLogManager = StateObject(wrappedValue: WeeklyLogManager(context: context))
        _mealSelectionViewModel = StateObject(wrappedValue: MealSelectionViewModel(dataStore: dataStore, context: context))
        _themeManager = StateObject(wrappedValue: ThemeManager.shared)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .id(themeManager.selectedThemeID)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(dataStore)
                .environmentObject(userSettingsManager)
                .environmentObject(dailyLogManager)
                .environmentObject(weeklyLogManager)
                .environmentObject(mealSelectionViewModel)
                .environmentObject(themeManager)
                .environmentObject(AppState.shared)
        }
    }
}
