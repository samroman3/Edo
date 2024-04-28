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
    
    @NSManaged public var sugars: Double
    @NSManaged public var addedSugars: Double
    @NSManaged public var cholesterol: Double
    @NSManaged public var sodium: Double
    @NSManaged public var vitamins: [String: Double]
    @NSManaged public var minerals: [String: Double]
    @NSManaged public var servingSize: String
    @NSManaged public var servingUnit: String
    @NSManaged public var timestamp: Date
    @NSManaged public var isFavorite: Bool
    @NSManaged public var foodGroup: String
    @NSManaged public var userNotes: String
    @NSManaged public var mealPhoto: Data
    @NSManaged public var mealPhotoLink: String
    @NSManaged public var thumbnail: Data

    
    @NSManaged public var fiber: Double
    @NSManaged public var saturatedFat: Double
    @NSManaged public var transFat: Double
    @NSManaged public var OFFsource: String
    @NSManaged public var rating: Double

    
}

