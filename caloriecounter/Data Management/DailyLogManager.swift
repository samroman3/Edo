//
//  DailyLogManager.swift
//  caloriecounter
//
//  Created by Sam Roman on 11/25/23.
//

import Foundation
import CoreData
import SwiftUI
import WidgetKit

class DailyLogManager: ObservableObject {
    @Published var selectedDate: Date
    @Published var meals: [Meal] = []
    private var context: NSManagedObjectContext
    
    var userSettingsManager: UserSettingsManager
    
    @Published var calorieGoal: Double = 0.0
    @Published var proteinGoal: Double = 0.0
    @Published var fatGoal: Double = 0.0
    @Published var carbGoal: Double = 0.0
    
    @Published var breakfastCalories: Double = 0.0
    @Published var lunchCalories: Double = 0.0
    @Published var dinnerCalories: Double = 0.0
    @Published var snackCalories: Double = 0.0
    
    @Published var breakfastCarbs = 0.0
    @Published var lunchCarbs = 0.0
    @Published var dinnerCarbs = 0.0
    @Published var snackCarbs = 0.0
    
    @Published var breakfastProtein = 0.0
    @Published var lunchProtein = 0.0
    @Published var dinnerProtein = 0.0
    @Published var snackProtein = 0.0
    
    @Published var breakfastFats = 0.0
    @Published var lunchFats = 0.0
    @Published var dinnerFats = 0.0
    @Published var snackFats = 0.0
    
    @Published var waterIntake: Double = 0.0
    @Published var waterIntakeGoal: Double = 2.7

 
    @Published var totalGramsCarbs: Double = 0.0
    @Published var totalGramsProtein: Double = 0.0
    @Published var totalGramsFats: Double = 0.0
    
    
    var totalCaloriesConsumed: Double {
        return breakfastCalories + lunchCalories + dinnerCalories + snackCalories
    }
    
    private lazy var initialMacros: [String: Double] = {
        var initialMacros: [String: Double] = [:]

        initialMacros["Carbs"] = totalGramsCarbs
        initialMacros["Fats"] = totalGramsFats
        initialMacros["Protein"] = totalGramsProtein

        return initialMacros
    }()
    
    @Published var macros: [String: Double] = [:]
    
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
                break
            }
        }
    }
    
    func calculateMealProtein() {
        // Clear previous values
        breakfastProtein = 0.0
        lunchProtein = 0.0
        dinnerProtein = 0.0
        snackProtein = 0.0

        // Calculate calories for each meal
        if meals.isEmpty {
            return
        }
        for meal in meals {
            let totalProtein = meal.entries?.allObjects.reduce(0) { (result, entry) in
                guard let entry = entry as? NutritionEntry else { return result }
                let protein = entry.protein
                return result + protein
            }
            switch meal.type {
            case MealType.breakfast.rawValue:
                breakfastProtein = totalProtein ?? 0.0
            case MealType.lunch.rawValue:
                lunchProtein = totalProtein ?? 0.0
            case MealType.dinner.rawValue:
                dinnerProtein = totalProtein ?? 0.0
            case MealType.snack.rawValue:
                snackProtein = totalProtein ?? 0.0
            default:
                break
            }
        }
    }
    
    func calculateMealCarbs() {
        // Clear previous values
        breakfastCarbs = 0.0
        lunchCarbs = 0.0
        dinnerCarbs = 0.0
        snackCarbs = 0.0

        // Calculate calories for each meal
        if meals.isEmpty {
            return
        }
        for meal in meals {
            let totalCarbs = meal.entries?.allObjects.reduce(0) { (result, entry) in
                guard let entry = entry as? NutritionEntry else { return result }
                let carbs = entry.carbs
                return result + carbs
            }
            switch meal.type {
            case MealType.breakfast.rawValue:
                breakfastCarbs = totalCarbs ?? 0.0
            case MealType.lunch.rawValue:
                lunchCarbs = totalCarbs ?? 0.0
            case MealType.dinner.rawValue:
                dinnerCarbs = totalCarbs ?? 0.0
            case MealType.snack.rawValue:
                snackCarbs = totalCarbs ?? 0.0
            default:
                break
            }
        }
    }
    
    func calculateMealFats() {
        // Clear previous values
        breakfastFats = 0.0
        lunchFats = 0.0
        dinnerFats = 0.0
        snackFats = 0.0

        // Calculate calories for each meal
        if meals.isEmpty {
            return
        }
        for meal in meals {
            let totalFats = meal.entries?.allObjects.reduce(0) { (result, entry) in
                guard let entry = entry as? NutritionEntry else { return result }
                let fats = entry.fat
                return result + fats
            }
            switch meal.type {
            case MealType.breakfast.rawValue:
                breakfastFats = totalFats ?? 0.0
            case MealType.lunch.rawValue:
                lunchFats = totalFats ?? 0.0
            case MealType.dinner.rawValue:
                dinnerFats = totalFats ?? 0.0
            case MealType.snack.rawValue:
                snackFats = totalFats ?? 0.0
            default:
                break
            }
        }
    }
    
    func calculateMacronutrientTotals() {
        // Reset totals
        totalGramsCarbs = 0.0
        totalGramsProtein = 0.0
        totalGramsFats = 0.0

        // Iterate over all meals and their nutrition entries
        for meal in meals {
            meal.entries?.forEach { entry in
                guard let nutritionEntry = entry as? NutritionEntry else { return }
                totalGramsCarbs += nutritionEntry.carbs
                totalGramsProtein += nutritionEntry.protein
                totalGramsFats += nutritionEntry.fat
            }
        }
        macros["Carbs"] = totalGramsCarbs
        macros["Fats"] = totalGramsFats
        macros["Protein"] = totalGramsProtein
    }
    
    public func totals(for macroType: MacroType, mealType: MealType) -> Double {
        switch macroType {
        case .calories:
           return calories(for: mealType)
        case .protein:
            return protein(for: mealType)
        case .carbs:
            return carbs(for: mealType)
        case .fats:
            return fats(for: mealType)
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
    
    public func protein(for mealType: MealType) -> Double {
        switch mealType {
        case MealType.breakfast:
            return breakfastProtein
        case MealType.lunch:
            return lunchProtein
        case MealType.dinner:
           return dinnerProtein
        case MealType.snack:
           return snackProtein
        case MealType.water:
            return 0.0
        }
       }

    public func carbs(for mealType: MealType) -> Double {
        switch mealType {
        case MealType.breakfast:
            return breakfastCarbs
        case MealType.lunch:
            return lunchCarbs
        case MealType.dinner:
           return dinnerCarbs
        case MealType.snack:
           return snackCarbs
        case MealType.water:
            return 0.0
        }
       }
    
    public func fats(for mealType: MealType) -> Double {
        switch mealType {
        case MealType.breakfast:
            return breakfastFats
        case MealType.lunch:
            return lunchFats
        case MealType.dinner:
           return dinnerFats
        case MealType.snack:
           return snackFats
        case MealType.water:
            return 0.0
        }
       }
    
    public func getPercentages(for macro: MacroType) -> (Double,Double,Double,Double) {
        switch macro {
        case .calories:
            return (breakfastCalPercentage,lunchCalPercentage,dinnerCalPercentage,snackCalPercentage)
        case .protein:
            return (breakfastProteinPercentage,lunchProteinPercentage, dinnerProteinPercentage,snackProteinPercentage)
        case .carbs:
            return (breakfastCarbPercentage, lunchCarbPercentage, dinnerCarbPercentage, snackCarbPercentage)
        case .fats:
            return (breakfastFatsPercentage,lunchFatsPercentage,dinnerFatsPercentage,snackFatsPercentage)
        }
    }
    var breakfastCalPercentage: Double {
        return breakfastCalories / calorieGoal
    }

    var lunchCalPercentage: Double {
        return lunchCalories / calorieGoal
    }

    var dinnerCalPercentage: Double {
        return dinnerCalories / calorieGoal
    }

    var snackCalPercentage: Double {
        return snackCalories / calorieGoal
    }
    
    var breakfastCarbPercentage: Double {
        return breakfastCarbs / carbGoal
    }

    var lunchCarbPercentage: Double {
        return lunchCarbs / carbGoal
    }

    var dinnerCarbPercentage: Double {
        return dinnerCarbs / carbGoal
    }

    var snackCarbPercentage: Double {
        return snackCarbs / carbGoal
    }
    
    var breakfastProteinPercentage: Double {
        return breakfastProtein / proteinGoal
    }

    var lunchProteinPercentage: Double {
        return lunchProtein / proteinGoal
    }

    var dinnerProteinPercentage: Double {
        return dinnerProtein / proteinGoal
    }

    var snackProteinPercentage: Double {
        return snackProtein / proteinGoal
    }
    
    var breakfastFatsPercentage: Double {
        return breakfastFats / fatGoal
    }

    var lunchFatsPercentage: Double {
        return lunchFats / fatGoal
    }

    var dinnerFatsPercentage: Double {
        return dinnerFats / fatGoal
    }

    var snackFatsPercentage: Double {
        return snackFats / fatGoal
    }
    
    private let userDefaults: UserDefaults
    
    private let appGroupIdentifier = "group.com.samroman.caloriecounter"
    
    init(context: NSManagedObjectContext, userSettings: UserSettingsManager, initialDate: Date = Date()) {
        self.context = context
        self.selectedDate = initialDate
        self.userSettingsManager = userSettings
        if let groupDefaults = UserDefaults(suiteName: appGroupIdentifier) {
                   self.userDefaults = groupDefaults
               } else {
                   fatalError("Failed to initialize UserDefaults with App Group")
               }
        self.macros = initialMacros

        refreshData()
    }
    func saveDataForWidget() {
        userDefaults.set(totalCaloriesConsumed, forKey: "totalCaloriesConsumed")
        userDefaults.set(calorieGoal, forKey: "calorieGoal")
        userDefaults.set(totalGramsProtein, forKey: "totalGramsProtein")
        userDefaults.set(proteinGoal, forKey: "proteinGoal")
        userDefaults.set(totalGramsCarbs, forKey: "totalGramsCarbs")
        userDefaults.set(carbGoal, forKey: "carbGoal")
        userDefaults.set(totalGramsFats, forKey: "totalGramsFats")
        userDefaults.set(fatGoal, forKey: "fatGoal")
        
        // Save individual meal calories
        userDefaults.set(breakfastCalories, forKey: "breakfastCalories")
        userDefaults.set(lunchCalories, forKey: "lunchCalories")
        userDefaults.set(dinnerCalories, forKey: "dinnerCalories")
        userDefaults.set(snackCalories, forKey: "snackCalories")
        
        userDefaults.set(waterIntake, forKey: "currentWaterIntake")
        userDefaults.set(waterIntakeGoal, forKey: "waterIntakeGoal")
        WidgetCenter.shared.reloadAllTimelines()
    }

    func updateSelectedDate(newDate: Date) {
        selectedDate = newDate
        refreshData()
    }
    
    func refreshData(completion: (() -> Void)? = nil) {
        fetchDailyLogForSelectedDate()
        fetchGoalsFromDailyLog()
        updateGoalsBasedOnDate()
        calculateAllMeals()
        calculateMacronutrientTotals()
        saveDataForWidget()
        completion?()
    }
    
    private func calculateAllMeals() {
        calculateMealCalories()
        calculateMealProtein()
        calculateMealCarbs()
        calculateMealFats()
    }
    
    // Fetch goals based on the selected date
    func updateGoalsBasedOnDate() {
        let calendar = Calendar.current
        if calendar.isDateInToday(selectedDate) || selectedDate > Date() {
            // Use current goals from UserSettingsManager
            calorieGoal = userSettingsManager.dailyCaloricNeeds
            proteinGoal = userSettingsManager.proteinGoal
            carbGoal = userSettingsManager.carbsGoal
            fatGoal = userSettingsManager.fatGoal
        } else {
            // Fetch from CoreData if available (for past dates)
            fetchGoalsFromDailyLog()
        }
    }
    

    private func fetchGoalsFromDailyLog() {
        let request: NSFetchRequest<DailyLog> = DailyLog.fetchRequest()
        let startOfDay = Calendar.current.startOfDay(for: selectedDate)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        
        request.predicate = NSPredicate(format: "(date >= %@) AND (date < %@)", startOfDay as NSDate, endOfDay as NSDate)
        
        do {
            let results = try context.fetch(request)
            if let dailyLog = results.first {
                // Check if the goals exist and are greater than 0, otherwise reset to default
                if dailyLog.calGoal > 0 {
                    calorieGoal = dailyLog.calGoal
                } else {
                    calorieGoal = userSettingsManager.dailyCaloricNeeds
                }

                if dailyLog.protGoal > 0 {
                    proteinGoal = dailyLog.protGoal
                } else {
                    proteinGoal = userSettingsManager.proteinGoal
                }

                if  dailyLog.carbGoal > 0 {
                    carbGoal = dailyLog.carbGoal
                } else {
                    carbGoal = userSettingsManager.carbsGoal
                }

                if dailyLog.fatsGoal > 0 {
                    fatGoal = dailyLog.fatsGoal
                } else {
                    fatGoal = userSettingsManager.fatGoal
                }

                // Update meals from the found log
//                meals = Array(dailyLog.meals as? Set<Meal> ?? [])
            } else {
                // No log found, use user settings
                resetToDefaultGoals()
            }
        } catch {
            print("Error fetching DailyLog for goals: \(error)")
            resetToDefaultGoals()
        }
    }
    
    private func resetToDefaultGoals() {
        calorieGoal = userSettingsManager.dailyCaloricNeeds
        proteinGoal = userSettingsManager.proteinGoal
        carbGoal = userSettingsManager.carbsGoal
        fatGoal = userSettingsManager.fatGoal
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
