//
//  NutritionEntry+CoreDataProperties.swift
//  caloriecounter
//
//  Created by Sam Roman on 11/25/23.
//
//

import Foundation
import CoreData


extension NutritionEntry: Identifiable {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NutritionEntry> {
        return NSFetchRequest<NutritionEntry>(entityName: "NutritionEntry")
    }

    @NSManaged public var calories: Double
    @NSManaged public var carbs: Double
    @NSManaged public var fat: Double
    @NSManaged public var id: UUID
    @NSManaged public var protein: Double
    @NSManaged public var name: String
    @NSManaged public var meals: Meal
    

}

