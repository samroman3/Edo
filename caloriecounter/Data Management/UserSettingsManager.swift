//
//  UserSettingsManager.swift
//  caloriecounter
//
//  Created by Sam Roman on 12/15/23.
//

import Foundation
import Combine
import CoreData

class UserSettingsManager: ObservableObject {
    let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func saveUserSettings(age: Int, weight: Double, height: Double, sex: String, activity: String, unitSystem: String) {
        // Fetch or create UserSettings entity
        let userSettings = fetchOrCreateUserSettings()

        // Set properties
        userSettings.age = Int16(age)
        userSettings.weight = weight
        userSettings.height = height
        userSettings.sex = sex
        userSettings.activity = activity
        userSettings.unitSystem = unitSystem

        // Save context
        saveContext()
        UserSettings.needsOnboarding = false
    }

    private func fetchOrCreateUserSettings() -> UserSettings {
        let request: NSFetchRequest<UserSettings> = UserSettings.fetchRequest()
        do {
            let results = try context.fetch(request)
            if let existingSettings = results.first {
                return existingSettings
            }
        } catch {
            print("Error fetching UserSettings: \(error)")
        }

        let newUserSettings = UserSettings(context: context)
        return newUserSettings
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
