//
//  AppState.swift
//  caloriecounter
//
//  Created by Sam Roman on 1/11/24.
//

import Foundation

class AppState: ObservableObject {
    static let shared = AppState()

    @Published var hasCompletedOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding")
        }
    }
    
    @Published var iCloudConsentGiven: Bool {
        didSet {
            UserDefaults.standard.set(iCloudConsentGiven, forKey: "iCloudConsentGiven")
        }
    }

    init() {
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        iCloudConsentGiven = UserDefaults.standard.bool(forKey: "iCloudConsentGiven")
    }
    
    func completeOnboarding() {
        hasCompletedOnboarding = true
    }

    func giveiCloudConsent() {
        iCloudConsentGiven = true
    }
}

