//
//  DateSelectionManager.swift
//  caloriecounter
//
//  Created by Sam Roman on 11/25/23.
//

import Foundation
import CoreData

class DateSelectionManager: ObservableObject {
    @Published var selectedDate: Date
    @Published var meals: [Meal] = []
    private var context: NSManagedObjectContext

    init(context: NSManagedObjectContext, initialDate: Date = Date()) {
        self.context = context
        self.selectedDate = initialDate
        fetchDailyLogForSelectedDate()
    }

    func updateSelectedDate(newDate: Date) {
        selectedDate = newDate
        fetchDailyLogForSelectedDate()
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
                // DailyLog exists, update meals
                meals = Array(dailyLog.meals as? Set<Meal> ?? [])
            } else {
                // No DailyLog found, create a new one
                let newDailyLog = DailyLog(context: context)
                newDailyLog.date = startOfDay
                saveContext()
                meals = [] // Initialize meals as empty for new log
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


