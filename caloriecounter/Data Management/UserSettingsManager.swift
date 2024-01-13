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
    
    init(context: NSManagedObjectContext) {
        self.context = context
        self.loadUserSettings()
    }

    func loginUser(email: String, password: String) -> Bool {
        let request: NSFetchRequest<UserSettings> = UserSettings.fetchRequest()
        request.predicate = NSPredicate(format: "userEmail == %@", email)

        do {
            let results = try context.fetch(request)
            if let user = results.first, user.userPassword == password {
                UserDefaults.standard.set(true, forKey: "isLoggedIn")
                UserDefaults.standard.set(email, forKey: "loggedInUserEmail")
                return true
            }
        } catch {
            print("Login error: \(error)")
        }

        return false
    }
    
    func loadUserSettings() {
        userSettings = fetchOrCreateUserSettings()
        if let settings = userSettings {
            DispatchQueue.main.async {
                self.age = Int(settings.age)
                self.weight = settings.weight
                self.height = settings.height
                self.sex = settings.sex
                self.activity = settings.activity
                self.unitSystem = settings.unitSystem
                self.userName = settings.userName
                self.userEmail = settings.userEmail
                self.profileImage = settings.profileImage?.uiImage
            }
        }
    }
    
    func uploadProfileImage(_ image: UIImage) {
        let settings = fetchOrCreateUserSettings()
        let imageData = image.jpegData(compressionQuality: 1.0)
        settings.profileImage = imageData as NSData?
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
