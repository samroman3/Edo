//
//  NutritionDataStore.swift
//  caloriecounter
//
//  Created by Sam Roman on 11/24/23.
//

import Foundation
import Combine
import CoreData
import WidgetKit

struct NutritionEntrySummary: Identifiable, Hashable {
    let id: UUID
    let name: String
    let calories: Double
    let protein: Double
    let carbs: Double
    let fat: Double
    let isFavorite: Bool
    let timestamp: Date
}

class NutritionDataStore: ObservableObject {
    let context: NSManagedObjectContext
    private let timestampKey = "timeStamp"
    private static let multiImageMetadataPrefix = "images:"

    
    private let userDefaults: UserDefaults
    
    private let appGroupIdentifier = "group.com.samroman.caloriecounter"
    
    init(context: NSManagedObjectContext) {
        self.context = context
        if let groupDefaults = UserDefaults(suiteName: appGroupIdentifier) {
                   self.userDefaults = groupDefaults
               } else {
                   fatalError("Failed to initialize UserDefaults with App Group")
               }
    }
    
    // Create a new entry
    func createEntry(date: Date, mealType: String, calories: Double, protein: Double, carbs: Double, fat: Double) {
        let dailyLog = fetchOrCreateDailyLog(for: date)
        let meal = fetchOrCreateMeal(in: dailyLog, type: mealType)
        
        let newEntry = NutritionEntry(context: context)
        newEntry.id = UUID()
        newEntry.timestamp = Date()
        newEntry.calories = calories
        newEntry.protein = protein
        newEntry.carbs = carbs
        newEntry.fat = fat
        
        meal.addToEntries(newEntry) // Use the correct method name
        saveContext()
    }
    
    private func fetchOrCreateDailyLog(for date: Date) -> DailyLog {
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone.local
        
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)
        
        let request: NSFetchRequest<DailyLog> = DailyLog.fetchRequest()
        request.predicate = NSPredicate(format: "(date >= %@) AND (date < %@)", startOfDay as NSDate, endOfDay! as NSDate)
        
        do {
            let results = try context.fetch(request)
            if let existingLog = results.first {
                return existingLog
            }
        } catch {
            print("Error fetching DailyLog: \(error)")
        }
        
        let newLog = DailyLog(context: context)
        newLog.date = startOfDay // Set to start of day
        return newLog
    }
    
    private func fetchOrCreateMeal(in dailyLog: DailyLog, type: String) -> Meal {
        let existingMeals = dailyLog.meals as? Set<Meal> ?? []
        if let existingMeal = existingMeals.first(where: { $0.type == type }) {
            return existingMeal
        }
        
        let newMeal = Meal(context: context)
        newMeal.id = UUID()
        newMeal.type = type
        newMeal.date = dailyLog.date ?? Date() // cannot fail - needs handling
        dailyLog.addToMeals(newMeal)
        
        return newMeal
    }
    
    
    func addEntryToMealAndDailyLog(date: Date, mealType: String, name: String, calories: Double, protein: Double, carbs: Double, fat: Double, servingUnit: String, servingSize: String, userNotes: String, mealPhoto: Data, mealPhotoLink: String?, isFavorite: Bool) {
        let dailyLog = fetchOrCreateDailyLog(for: date)
        let meal = fetchOrCreateMeal(in: dailyLog, type: mealType)
        
        let newEntry = NutritionEntry(context: context)
        newEntry.id = UUID()
        newEntry.timestamp = Date()
        newEntry.calories = calories
        newEntry.name = name
        newEntry.protein = protein
        newEntry.carbs = carbs
        newEntry.fat = fat
        newEntry.servingSize = servingSize
        newEntry.servingUnit = servingUnit
        newEntry.userNotes = userNotes
        newEntry.mealPhoto = mealPhoto
        newEntry.mealPhotoLink = mealPhotoLink ?? ""
        newEntry.isFavorite = isFavorite
                
        meal.addToEntries(newEntry)
        saveContext()
    }
    
    func updateWaterIntake(intake: Double, date: Date) {
        let dailyLog = fetchOrCreateDailyLog(for: date)
        dailyLog.waterIntake = intake
        saveContext()
        userDefaults.set(intake, forKey: "currentWaterIntake")
    }
    
    func resetWaterIntake(date: Date) {
        let dailyLog = fetchOrCreateDailyLog(for: date)
        dailyLog.waterIntake = 0.0
        saveContext()
        userDefaults.set(0.0, forKey: "currentWaterIntake")
        WidgetCenter.shared.reloadTimelines(ofKind:"WaterIntakeWidget")
    }
    
    
    

    // Read entries for a specific date
    func readEntries(for date: Date) -> [NutritionEntry] {
        let request: NSFetchRequest<NutritionEntry> = NutritionEntry.fetchRequest()
        let (startOfDay, endOfDay) = dayBounds(for: date)
        request.predicate = NSPredicate(format: "(meals.date >= %@) AND (meals.date < %@)", startOfDay as NSDate, endOfDay as NSDate)
        request.sortDescriptors = [NSSortDescriptor(key: timestampKey, ascending: false)]
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching data: \(error)")
            return []
        }
    }

    func fetchEntries(favorites: Bool, nameSearch: String? = nil) -> [NutritionEntry] {
        let request: NSFetchRequest<NutritionEntry> = NutritionEntry.fetchRequest()
        var predicates: [NSPredicate] = []
        
        // Adding a predicate to filter for favorite entries
        if favorites {
            let favoritePredicate = NSPredicate(format: "isFavorite == %@", NSNumber(value: true))
            predicates.append(favoritePredicate)
        }
        
        // Adding a predicate to filter by name if nameSearch is not nil and not empty
        if let nameSearch = nameSearch, !nameSearch.isEmpty {
            let namePredicate = NSPredicate(format: "name CONTAINS[cd] %@", nameSearch)
            predicates.append(namePredicate)
        }
        
        // Combine all predicates
        if !predicates.isEmpty {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }
        request.sortDescriptors = [NSSortDescriptor(key: timestampKey, ascending: false)]
        
        do {
            let entries = try context.fetch(request)
            return entries
        } catch {
            print("Error fetching entries: \(error)")
            return []
        }
    }

    func fetchConsolidatedEntries(favorites: Bool = false, nameSearch: String? = nil) -> [NutritionEntrySummary] {
        let request: NSFetchRequest<NutritionEntry> = NutritionEntry.fetchRequest()
        var predicates: [NSPredicate] = []

        if favorites {
            let favoritePredicate = NSPredicate(format: "isFavorite == %@", NSNumber(value: true))
            predicates.append(favoritePredicate)
        }

        if let nameSearch = nameSearch, !nameSearch.isEmpty {
            let namePredicate = NSPredicate(format: "name CONTAINS[cd] %@", nameSearch)
            predicates.append(namePredicate)
        }

        request.sortDescriptors = [NSSortDescriptor(key: timestampKey, ascending: false)]
        if !predicates.isEmpty {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }

        do {
            let entries = try context.fetch(request)
            return consolidate(entries: entries)

        } catch {
            print("Error fetching entries for consolidation: \(error)")
            return []
        }
    }

    func recentQuickEntries(limit: Int = 6, favoritesOnly: Bool = false) -> [NutritionEntrySummary] {
        var results = fetchConsolidatedEntries(favorites: favoritesOnly)
        if results.count > limit {
            results = Array(results.prefix(limit))
        }
        return results
    }

    func mostRecentEntrySummary(for mealType: String? = nil) -> NutritionEntrySummary? {
        let request: NSFetchRequest<NutritionEntry> = NutritionEntry.fetchRequest()
        if let mealType, !mealType.isEmpty {
            request.predicate = NSPredicate(format: "meals.type == %@", mealType)
        }
        request.sortDescriptors = [NSSortDescriptor(key: timestampKey, ascending: false)]
        request.fetchLimit = 1

        do {
            guard let entry = try context.fetch(request).first else {
                return nil
            }
            return makeSummary(from: entry)
        } catch {
            print("Error fetching most recent entry: \(error)")
            return nil
        }
    }

    func updateTodayGoals(caloricNeeds: Double, protein: Double, carbs: Double, fat: Double) {
        let date = Date()
        let dailyLog = fetchOrCreateDailyLog(for: date)

        // Update the goals
        dailyLog.calGoal = caloricNeeds
        dailyLog.protGoal = protein
        dailyLog.carbGoal = carbs
        dailyLog.fatsGoal = fat

        // Save the context to persist changes
        saveContext()
    }
    
    // Update an existing entry
    func updateEntry(_ entry: NutritionEntry) {
        // Update entry properties as needed
        saveContext()
    }

    func updateEntry(
        _ entry: NutritionEntry,
        name: String,
        calories: Double,
        protein: Double,
        carbs: Double,
        fat: Double,
        servingSize: String,
        servingUnit: String,
        userNotes: String,
        isFavorite: Bool,
        imageData: [Data]? = nil
    ) {
        entry.name = name
        entry.calories = calories
        entry.protein = protein
        entry.carbs = carbs
        entry.fat = fat
        entry.servingSize = servingSize
        entry.servingUnit = servingUnit
        entry.userNotes = userNotes
        entry.isFavorite = isFavorite
        if let imageData {
            let normalizedImages = Array(imageData.prefix(4))
            entry.mealPhoto = normalizedImages.first ?? Data()
            entry.mealPhotoLink = Self.encodedImageMetadata(from: normalizedImages)
        }
        entry.timestamp = Date()
        saveContext()
    }

    func moveEntry(_ entry: NutritionEntry, to mealType: String, on date: Date) {
        let dailyLog = fetchOrCreateDailyLog(for: date)
        let targetMeal = fetchOrCreateMeal(in: dailyLog, type: mealType)

        if let currentMeal = entry.meals as Meal? {
            currentMeal.removeFromEntries(entry)
        }

        targetMeal.addToEntries(entry)
        entry.timestamp = Date()
        saveContext()
    }

    func entry(with id: UUID) -> NutritionEntry? {
        let request: NSFetchRequest<NutritionEntry> = NutritionEntry.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1

        do {
            return try context.fetch(request).first
        } catch {
            print("Error fetching entry by id: \(error)")
            return nil
        }
    }
    
    // Delete an entry
    func deleteEntry(_ entry: NutritionEntry) {
        context.delete(entry)
        saveContext()
    }
    
    // Save any changes to the context
    private func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }

    private func dayBounds(for date: Date) -> (Date, Date) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? startOfDay
        return (startOfDay, endOfDay)
    }

    private func consolidate(entries: [NutritionEntry]) -> [NutritionEntrySummary] {
        var uniqueEntries: [String: NutritionEntrySummary] = [:]

        for entry in entries {
            let key = entry.name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            let summary = makeSummary(from: entry)

            if let existing = uniqueEntries[key] {
                if entry.timestamp > existing.timestamp {
                    uniqueEntries[key] = summary
                }
            } else {
                uniqueEntries[key] = summary
            }
        }

        return uniqueEntries
            .values
            .sorted { $0.timestamp > $1.timestamp }
    }

    private func makeSummary(from entry: NutritionEntry) -> NutritionEntrySummary {
        NutritionEntrySummary(
            id: entry.id,
            name: entry.name,
            calories: entry.calories,
            protein: entry.protein,
            carbs: entry.carbs,
            fat: entry.fat,
            isFavorite: entry.isFavorite,
            timestamp: entry.timestamp
        )
    }

    static func storedImageData(for entry: NutritionEntry) -> [Data] {
        storedImageData(primaryData: entry.mealPhoto, metadata: entry.mealPhotoLink)
    }

    static func storedImageData(primaryData: Data, metadata: String) -> [Data] {
        var images: [Data] = []

        if !primaryData.isEmpty {
            images.append(primaryData)
        }

        guard metadata.hasPrefix(multiImageMetadataPrefix) else {
            return Array(images.prefix(4))
        }

        let payload = String(metadata.dropFirst(multiImageMetadataPrefix.count))
        guard let payloadData = payload.data(using: .utf8),
              let encodedImages = try? JSONDecoder().decode([String].self, from: payloadData) else {
            return Array(images.prefix(4))
        }

        for encodedImage in encodedImages {
            guard let data = Data(base64Encoded: encodedImage), !data.isEmpty else {
                continue
            }
            images.append(data)
        }

        return Array(images.prefix(4))
    }

    static func encodedImageMetadata(from images: [Data]) -> String {
        let extraImages = Array(images.dropFirst().prefix(3))
        guard !extraImages.isEmpty,
              let payloadData = try? JSONEncoder().encode(extraImages.map { $0.base64EncodedString() }),
              let payload = String(data: payloadData, encoding: .utf8) else {
            return ""
        }

        return multiImageMetadataPrefix + payload
    }
}
