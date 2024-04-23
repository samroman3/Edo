//
//  Meal+CoreDataProperties.swift
//  caloriecounter
//
//  Created by Sam Roman on 11/25/23.
//
//

import Foundation
import CoreData


extension Meal {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Meal> {
        return NSFetchRequest<Meal>(entityName: "Meal")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var type: String?
    @NSManaged public var date: Date?
    @NSManaged public var entries: NSSet?
    @NSManaged public var dailyLog: DailyLog?

}

// MARK: Generated accessors for entries
extension Meal {

    @objc(addEntriesObject:)
    @NSManaged public func addToEntries(_ value: NutritionEntry)

    @objc(removeEntriesObject:)
    @NSManaged public func removeFromEntries(_ value: NutritionEntry)

    @objc(addEntries:)
    @NSManaged public func addToEntries(_ values: NSSet)

    @objc(removeEntries:)
    @NSManaged public func removeFromEntries(_ values: NSSet)
    

}

extension Meal : Identifiable {

}

extension Meal {
    var entriesArray: [NutritionEntry] {
        (entries as? Set<NutritionEntry> ?? []).sorted { _, _ in true }
    }
}
