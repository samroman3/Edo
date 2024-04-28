//
//  NutritionDataStore.swift
//  caloriecounter
//
//  Created by Sam Roman on 11/24/23.
//

import Foundation
import Combine
import CoreData

class NutritionDataStore: ObservableObject {
    let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // Create a new entry
    func createEntry(date: Date, mealType: String, calories: Double, protein: Double, carbs: Double, fat: Double) {
        let dailyLog = fetchOrCreateDailyLog(for: date)
        let meal = fetchOrCreateMeal(in: dailyLog, type: mealType)
        
        let newEntry = NutritionEntry(context: context)
        newEntry.id = UUID()
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
        
//        newEntry.timestamp = date
        
        if let entries = meal.entries as? Set<NutritionEntry>, !entries.contains(newEntry) {
            meal.addToEntries(newEntry)
        }
        
        saveContext()
    }
    
    func updateWaterIntake(intake: Double, date: Date) {
        let dailyLog = fetchOrCreateDailyLog(for: date)
        dailyLog.waterIntake = intake
        saveContext()
    }
    
    func resetWaterIntake(date: Date) {
        let dailyLog = fetchOrCreateDailyLog(for: date)
        dailyLog.waterIntake = 0.0
        saveContext()
    }
    
    
    
    
    // Read entries for a specific date
    func readEntries(for date: Date) -> [NutritionEntry] {
        let request: NSFetchRequest<NutritionEntry> = NutritionEntry.fetchRequest()
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
        let favoritePredicate = NSPredicate(format: "favorite == %@", NSNumber(value: true))
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
    
    do {
        let entries = try context.fetch(request)
        return entries
    } catch {
        print("Error fetching entries: \(error)")
        return []
    }
}
    
    // Update an existing entry
    func updateEntry(_ entry: NutritionEntry) {
        // Update entry properties as needed
        saveContext()
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
}

