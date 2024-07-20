//
//  WeeklyLogManager.swift
//  caloriecounter
//
//  Created by Sam Roman on 7/20/24.
//
import Foundation
import CoreData

class WeeklyLogManager: ObservableObject {
    @Published var weeklyLogs: [DailyLog] = []
    private var context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func fetchWeeklyLogs(from date: Date) {
        let calendar = Calendar.current
        let startOfWeek = calendar.date(byAdding: .day, value: -6, to: date)!
        
        let request: NSFetchRequest<DailyLog> = DailyLog.fetchRequest()
        request.predicate = NSPredicate(format: "date >= %@ AND date <= %@", startOfWeek as NSDate, date as NSDate)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        do {
            weeklyLogs = try context.fetch(request)
        } catch {
            print("Error fetching weekly logs: \(error)")
        }
    }
    
    func totalNutrients(for date: Date, macro: MacroType) -> Double {
        guard let dailyLog = weeklyLogs.first(where: { Calendar.current.isDate($0.date!, inSameDayAs: date) }) else {
            return 0
        }
        
        var total = 0.0
        for meal in dailyLog.meals as? Set<Meal> ?? [] {
            for entry in meal.entries as? Set<NutritionEntry> ?? [] {
                switch macro {
                case .calories:
                    total += entry.calories
                case .protein:
                    total += entry.protein
                case .carbs:
                    total += entry.carbs
                case .fats:
                    total += entry.fat
                }
            }
        }
        return total
    }
    
    func totalNutrients(for date: Date, mealType: MealType, macro: MacroType) -> Double {
        guard let dailyLog = weeklyLogs.first(where: { Calendar.current.isDate($0.date!, inSameDayAs: date) }) else {
            return 0
        }
        
        guard let meal = (dailyLog.meals as? Set<Meal>)?.first(where: { $0.type == mealType.rawValue }) else {
            return 0
        }
        
        var total = 0.0
        for entry in meal.entries as? Set<NutritionEntry> ?? [] {
            switch macro {
            case .calories:
                total += entry.calories
            case .protein:
                total += entry.protein
            case .carbs:
                total += entry.carbs
            case .fats:
                total += entry.fat
            }
        }
        return total
    }
}

