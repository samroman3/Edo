//
//  DailyLogManager.swift
//  caloriecounter
//
//  Created by Sam Roman on 11/25/23.
//

import Foundation
import CoreData

class DailyLogManager: ObservableObject {
    @Published var selectedDate: Date
    @Published var meals: [Meal] = []
    private var context: NSManagedObjectContext
    @Published var calorieGoal: Double = 1900.0 // This could also come from user settings
    @Published var breakfastCalories: Double = 0.0
    @Published var lunchCalories: Double = 0.0
    @Published var dinnerCalories: Double = 0.0
    @Published var snackCalories: Double = 0.0
    @Published var waterIntake: Double = 0.0
 
    var totalCaloriesConsumed: Double {
        return breakfastCalories + lunchCalories + dinnerCalories + snackCalories
    }

    func calculateMealCalories() {
        // Clear previous values
        breakfastCalories = 0.0
        lunchCalories = 0.0
        dinnerCalories = 0.0
        snackCalories = 0.0

        // Calculate calories for each meal
        if meals.isEmpty {
            return
        }
        for meal in meals {
            let totalCalories = meal.entries?.allObjects.reduce(0) { (result, entry) in
                guard let entry = entry as? NutritionEntry else { return result }
                let calories = entry.calories
                return result + calories
            }
            switch meal.type {
            case MealType.breakfast.rawValue:
                breakfastCalories = totalCalories ?? 0.0
            case MealType.lunch.rawValue:
                lunchCalories = totalCalories ?? 0.0
            case MealType.dinner.rawValue:
                dinnerCalories = totalCalories ?? 0.0
            case MealType.snack.rawValue:
                snackCalories = totalCalories ?? 0.0
            default:
                break // Handle unknown meal types if necessary
            }
        }
    }
    
    public func calories(for mealType: MealType) -> Double {
        switch mealType {
        case MealType.breakfast:
            return breakfastCalories
        case MealType.lunch:
            return lunchCalories
        case MealType.dinner:
           return dinnerCalories
        case MealType.snack:
           return snackCalories
        case MealType.water:
            return 0.0
        }
       }

    var breakfastPercentage: Double {
        return breakfastCalories / calorieGoal
    }

    var lunchPercentage: Double {
        return lunchCalories / calorieGoal
    }

    var dinnerPercentage: Double {
        return dinnerCalories / calorieGoal
    }

    var snackPercentage: Double {
        return snackCalories / calorieGoal
    }

    // Call this method whenever the selected date changes or when the meals have been updated.
    func refreshData() {
        fetchDailyLogForSelectedDate()
        calculateMealCalories()
    }
    init(context: NSManagedObjectContext, initialDate: Date = Date()) {
        self.context = context
        self.selectedDate = initialDate
        fetchDailyLogForSelectedDate()
    }

    func updateSelectedDate(newDate: Date) {
        selectedDate = newDate
        fetchDailyLogForSelectedDate()
        calculateMealCalories()
    }

    func fetchDailyLogForSelectedDate() {
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone.local

        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)

        let fetchRequest: NSFetchRequest<DailyLog> = DailyLog.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "(date >= %@) AND (date < %@)", startOfDay as NSDate, endOfDay! as NSDate)

        do {
            let results = try context.fetch(fetchRequest)
            if let dailyLog = results.first {
                // DailyLog exists, update meals and waterIntake
                meals = Array(dailyLog.meals as? Set<Meal> ?? [])
                waterIntake = dailyLog.waterIntake
            } else {
                // No DailyLog found, create a new one
                let newDailyLog = DailyLog(context: context)
                newDailyLog.date = startOfDay
                saveContext()
                meals = [] // Initialize meals as empty for new log
                waterIntake = 0.0
            }
        } catch {
            print("Error fetching DailyLog: \(error)")
        }
    }


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


