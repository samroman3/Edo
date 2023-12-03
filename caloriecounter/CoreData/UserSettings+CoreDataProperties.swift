//
//  UserSettings+CoreDataProperties.swift
//  caloriecounter
//
//  Created by Sam Roman on 11/24/23.
//
//

import Foundation
import CoreData


extension UserSettings {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserSettings> {
        return NSFetchRequest<UserSettings>(entityName: "UserSettings")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var dailyCalorieGoal: Double

}

extension UserSettings : Identifiable {

}
