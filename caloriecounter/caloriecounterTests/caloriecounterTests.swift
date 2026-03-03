//
//  caloriecounterTests.swift
//  caloriecounterTests
//
//  Created by Sam Roman on 11/24/23.
//

import CoreData
import XCTest
@testable import caloriecounter

final class caloriecounterTests: XCTestCase {
    private var persistenceController: PersistenceController!
    private var context: NSManagedObjectContext!
    private var dataStore: NutritionDataStore!
    private var userSettingsManager: UserSettingsManager!

    override func setUpWithError() throws {
        persistenceController = PersistenceController(inMemory: true)
        context = persistenceController.container.viewContext
        dataStore = NutritionDataStore(context: context)
        userSettingsManager = UserSettingsManager(context: context)
    }

    override func tearDownWithError() throws {
        dataStore = nil
        userSettingsManager = nil
        context = nil
        persistenceController = nil
    }

    func testReadEntriesFiltersByRequestedDay() throws {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        addEntry(name: "Today Oats", date: today, mealType: .breakfast, calories: 320)
        addEntry(name: "Yesterday Pasta", date: yesterday, mealType: .dinner, calories: 510)

        let entries = dataStore.readEntries(for: today)

        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entries.first?.name, "Today Oats")
    }

    func testQuickEntriesAreConsolidatedByMostRecentName() throws {
        let now = Date()

        addEntry(name: "Greek Yogurt", date: now, mealType: .breakfast, calories: 120, isFavorite: true)
        let olderEntry = try XCTUnwrap(dataStore.readEntries(for: now).first)
        olderEntry.timestamp = now.addingTimeInterval(-60)
        try context.save()

        addEntry(name: "Greek Yogurt", date: now, mealType: .snack, calories: 140, protein: 17, carbs: 9, fat: 4, isFavorite: true)

        let quickEntries = dataStore.recentQuickEntries(limit: 5)

        XCTAssertEqual(quickEntries.count, 1)
        XCTAssertEqual(quickEntries.first?.name, "Greek Yogurt")
        XCTAssertEqual(quickEntries.first?.calories, 140)
    }

    func testPercentagesReturnZeroWhenGoalsAreUnset() throws {
        let manager = DailyLogManager(context: context, userSettings: userSettingsManager)

        manager.calorieGoal = 0
        manager.proteinGoal = 0
        manager.carbGoal = 0
        manager.fatGoal = 0
        manager.breakfastCalories = 400
        manager.breakfastProtein = 30
        manager.breakfastCarbs = 45
        manager.breakfastFats = 10

        XCTAssertEqual(manager.getPercentages(for: .calories).0, 0)
        XCTAssertEqual(manager.getPercentages(for: .protein).0, 0)
        XCTAssertEqual(manager.getPercentages(for: .carbs).0, 0)
        XCTAssertEqual(manager.getPercentages(for: .fats).0, 0)
    }

    func testThemeManagerAppliesAndPersistsPreset() throws {
        let suiteName = "ThemeManagerTests-\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defaults.removePersistentDomain(forName: suiteName)

        let manager = ThemeManager(userDefaults: defaults)
        manager.apply(.forest)

        XCTAssertEqual(manager.selectedThemeID, AppTheme.ThemeOption.forest.rawValue)
        XCTAssertEqual(defaults.string(forKey: "selectedThemeID"), AppTheme.ThemeOption.forest.rawValue)
        XCTAssertEqual(manager.selectedTheme.name, "Forest")
    }

    func testEstimatedMaintenanceCaloriesUsesUpdatedActivityMultiplier() throws {
        userSettingsManager.age = 30
        userSettingsManager.weight = 72.6
        userSettingsManager.height = 178
        userSettingsManager.sex = "Male"
        userSettingsManager.activity = "Lightly Active"

        let maintenance = userSettingsManager.estimatedMaintenanceCalories(adjustment: 0)

        XCTAssertEqual(maintenance.rounded(), 2371, accuracy: 2)
    }

    func testHealthyWeightRangeTextRespectsUnitPreference() throws {
        userSettingsManager.saveUserSettings(
            age: 30,
            weight: 72.6,
            height: 178,
            sex: "Male",
            activity: "Lightly Active",
            unitSystem: "imperial",
            userName: "",
            userEmail: ""
        )

        XCTAssertEqual(userSettingsManager.healthyWeightRangeText(), "129-174 lb")
    }

    func testOpenFoodFactsDecoderMapsMacros() throws {
        let payload = """
        {
          "products": [
            {
              "code": "12345",
              "product_name": "Protein Bar",
              "brands": "EAZEAT",
              "nutriments": {
                "energy-kcal_serving": 210,
                "proteins_serving": 20,
                "carbohydrates_serving": 18,
                "fat_serving": 7
              }
            }
          ]
        }
        """.data(using: .utf8)!

        let service = OpenFoodFactsSearchService()
        let results = try service.decodeSearchResults(from: payload)

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "Protein Bar")
        XCTAssertEqual(results.first?.calories, 210)
        XCTAssertEqual(results.first?.protein, 20)
        XCTAssertEqual(results.first?.carbs, 18)
        XCTAssertEqual(results.first?.fat, 7)
        XCTAssertEqual(results.first?.barcode, "12345")
    }

    func testUSDABasicFoodSearchFindsGenericFoods() throws {
        let service = USDABasicFoodSearchService()
        let results = service.searchProducts(matching: "rice")

        XCTAssertFalse(results.isEmpty)
        XCTAssertEqual(results.first?.sourceName, "USDA Basics")
        XCTAssertTrue(results.contains(where: { $0.name == "White Rice" || $0.name == "Brown Rice" }))
    }

    private func addEntry(
        name: String,
        date: Date,
        mealType: MealType,
        calories: Double,
        protein: Double = 14,
        carbs: Double = 30,
        fat: Double = 8,
        isFavorite: Bool = false
    ) {
        dataStore.addEntryToMealAndDailyLog(
            date: date,
            mealType: mealType.rawValue,
            name: name,
            calories: calories,
            protein: protein,
            carbs: carbs,
            fat: fat,
            servingUnit: "Serving",
            servingSize: "1",
            userNotes: "",
            mealPhoto: Data(),
            mealPhotoLink: nil,
            isFavorite: isFavorite
        )
    }
}
