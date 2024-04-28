//
//  UserSettingsManager.swift
//  caloriecounter
//
//  Created by Sam Roman on 12/15/23.
//

import Combine
import CoreData
import UIKit

class UserSettingsManager: ObservableObject {
    private let context: NSManagedObjectContext
    private var userSettings: UserSettings?
    
    @Published var profileImage: UIImage?
    @Published var age: Int = 0
    @Published var weight: Double = 0.0
    @Published var height: Double = 0.0
    @Published var sex: String = ""
    @Published var activity: String = ""
    @Published var unitSystem: String = ""
    @Published var userName: String = ""
    @Published var userEmail: String = ""
    
    @Published var dailyCaloricNeeds: Double = 0.0
    @Published var proteinGoal: Double = 0.0
    @Published var carbsGoal: Double = 0.0
    @Published var fatGoal: Double = 0.0
    @Published var dietaryPlan: String = ""
    
    init(context: NSManagedObjectContext) {
        self.context = context
        self.loadUserSettings()
        NotificationCenter.default.addObserver(self, selector: #selector(ubiquitousKeyValueStoreDidChange(_:)), name: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: NSUbiquitousKeyValueStore.default)

    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }


    @objc private func ubiquitousKeyValueStoreDidChange(_ notification: Notification) {
        // Handle changes as needed, for example, reload flags
    }

    
    //Mark: Key Value iCloud Markers
    
    func saveOnboardingCompletedFlag(isCompleted: Bool) {
        NSUbiquitousKeyValueStore.default.set(isCompleted, forKey: "onboardingCompleted")
        NSUbiquitousKeyValueStore.default.synchronize()
    }

    func saveConsentFlag(isGiven: Bool) {
        NSUbiquitousKeyValueStore.default.set(isGiven, forKey: "consentGiven")
        NSUbiquitousKeyValueStore.default.synchronize()
    }
    
    func isOnboardingCompleted() -> Bool {
        return NSUbiquitousKeyValueStore.default.bool(forKey: "onboardingCompleted")
    }

    func isConsentGiven() -> Bool {
        return NSUbiquitousKeyValueStore.default.bool(forKey: "consentGiven")
    }
    
    private func clearUserSettings() {
          DispatchQueue.main.async {
              self.profileImage = nil
              self.age = 0
              self.weight = 0.0
              self.height = 0.0
              self.sex = ""
              self.activity = ""
              self.unitSystem = ""
              self.userName = ""
              self.userEmail = ""
          }
      }

    
    func loadUserSettings() {
        userSettings = fetchOrCreateUserSettings()
        if let settings = userSettings {
            DispatchQueue.main.async {
                self.age = Int(settings.age)
                self.weight = settings.weight
                self.height = settings.height
                self.sex = settings.sex ?? ""
                self.activity = settings.activity ?? ""
                self.unitSystem = settings.unitSystem ?? "metric"
                self.userName = settings.userName ?? ""
                self.userEmail = settings.userEmail ?? ""
            }
        }
    }
    
    func uploadProfileImage(_ image: UIImage) {
//        let settings = fetchOrCreateUserSettings()
//        let imageData = image.jpegData(compressionQuality: 1.0)
//        settings.profileImage = imageData as NSData?
        saveContext()
    }
    
    func calculateBMI() -> Double? {
        guard let settings = userSettings, settings.height > 0, settings.weight > 0 else { return nil }
        let heightInMeters = settings.height / 100 // Convert cm to m
        return settings.weight / (heightInMeters * heightInMeters)
    }
    
    func saveUserSettings(age: Int, weight: Double, height: Double, sex: String, activity: String, unitSystem: String, userName: String, userEmail: String) {
        let settings = fetchOrCreateUserSettings()
        settings.age = Int16(age)
        settings.weight = weight
        settings.height = height
        settings.sex = sex
        settings.activity = activity
        settings.unitSystem = unitSystem
        settings.userName = userName
        settings.userEmail = userEmail
        saveContext()
    }
    
    func saveDietaryGoals(caloricNeeds: Double, protein: Double, carbs: Double, fat: Double) {
        let settings = fetchOrCreateUserSettings()
        settings.dailyCalorieGoal = caloricNeeds
        settings.proteinGoal = protein
        settings.carbsGoal = carbs
        settings.fatsGoal = fat
        
        saveContext() // Make sure to save the context
    }
    
    private func fetchOrCreateUserSettings() -> UserSettings {
        if let settings = userSettings {
            return settings
        } else {
            let request: NSFetchRequest<UserSettings> = UserSettings.fetchRequest()
            do {
                let results = try context.fetch(request)
                if let existingSettings = results.first {
                    userSettings = existingSettings
                    return existingSettings
                }
            } catch {
                print("Error fetching UserSettings: \(error)")
            }
            let newUserSettings = UserSettings(context: context)
            userSettings = newUserSettings
            return newUserSettings
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

// Helper extension to convert NSData to UIImage
extension NSData {
    var uiImage: UIImage? { UIImage(data: self as Data) }
}
