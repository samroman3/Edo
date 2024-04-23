//
//  Recipe+CoreDataProperties.swift
//  caloriecounter
//
//  Created by Sam Roman on 4/21/24.
//
//

import Foundation
import CoreData


extension Recipe {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Recipe> {
        return NSFetchRequest<Recipe>(entityName: "Recipe")
    }

    @NSManaged public var mealType: String?
    @NSManaged public var servingSize: String?
    @NSManaged public var entries: NSOrderedSet?
    @NSManaged public var favorite: Bool
    @NSManaged public var meal: Meal?

}

// MARK: Generated accessors for entries
extension Recipe {

    @objc(insertObject:inEntriesAtIndex:)
    @NSManaged public func insertIntoEntries(_ value: NutritionEntry, at idx: Int)

    @objc(removeObjectFromEntriesAtIndex:)
    @NSManaged public func removeFromEntries(at idx: Int)

    @objc(insertEntries:atIndexes:)
    @NSManaged public func insertIntoEntries(_ values: [NutritionEntry], at indexes: NSIndexSet)

    @objc(removeEntriesAtIndexes:)
    @NSManaged public func removeFromEntries(at indexes: NSIndexSet)

    @objc(replaceObjectInEntriesAtIndex:withObject:)
    @NSManaged public func replaceEntries(at idx: Int, with value: NutritionEntry)

    @objc(replaceEntriesAtIndexes:withEntries:)
    @NSManaged public func replaceEntries(at indexes: NSIndexSet, with values: [NutritionEntry])

    @objc(addEntriesObject:)
    @NSManaged public func addToEntries(_ value: NutritionEntry)

    @objc(removeEntriesObject:)
    @NSManaged public func removeFromEntries(_ value: NutritionEntry)

    @objc(addEntries:)
    @NSManaged public func addToEntries(_ values: NSOrderedSet)

    @objc(removeEntries:)
    @NSManaged public func removeFromEntries(_ values: NSOrderedSet)

}

extension Recipe : Identifiable {

}
