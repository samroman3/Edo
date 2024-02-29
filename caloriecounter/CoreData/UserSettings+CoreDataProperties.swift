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
    
    @NSManaged public var activity: String?
    @NSManaged public var age: Int16
    @NSManaged public var carbsGoal: Double
    @NSManaged public var dailyCalorieGoal: Double
    @NSManaged public var fatsGoal: Double
    @NSManaged public var height: Double
    @NSManaged public var id: UUID?
    @NSManaged public var profileImage: Data?
    @NSManaged public var proteinGoal: Double
    @NSManaged public var sex: String?
    @NSManaged public var unitSystem: String?
    @NSManaged public var userEmail: String?
    @NSManaged public var userName: String?
    @NSManaged public var weight: Double


static var needsOnboarding: Bool {
    get {
        UserDefaults.standard.bool(forKey: "NeedsOnboarding")  || !UserDefaults.standard.hasKey("NeedsOnboarding")
    }
    set {
        UserDefaults.standard.set(newValue, forKey: "NeedsOnboarding")
    }
}

}

extension UserSettings : Identifiable {
    
}

extension UserDefaults {
    func hasKey(_ key: String) -> Bool {
        return object(forKey: key) != nil
    }
}
