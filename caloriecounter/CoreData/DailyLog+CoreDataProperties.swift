//
//  DailyLog+CoreDataProperties.swift
//  caloriecounter
//
//  Created by Sam Roman on 11/25/23.
//
//

import Foundation
import CoreData


extension DailyLog {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DailyLog> {
        return NSFetchRequest<DailyLog>(entityName: "DailyLog")
    }

    @NSManaged public var date: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var meals: NSSet?

}

// MARK: Generated accessors for meals
extension DailyLog {

    @objc(addMealsObject:)
    @NSManaged public func addToMeals(_ value: Meal)

    @objc(removeMealsObject:)
    @NSManaged public func removeFromMeals(_ value: Meal)

    @objc(addMeals:)
    @NSManaged public func addToMeals(_ values: NSSet)

    @objc(removeMeals:)
    @NSManaged public func removeFromMeals(_ values: NSSet)

}

extension DailyLog : Identifiable {

}
