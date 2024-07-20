//
//  MainView.swift
//  caloriecounter
//
//  Created by Sam Roman on 12/14/23.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var userSettingsManager: UserSettingsManager
    @EnvironmentObject var nutritionDataStore: NutritionDataStore

    @State private var iCloudAvailable: Bool?

    var body: some View {
        Group {
            if let iCloudAvailable = iCloudAvailable {
                if iCloudAvailable {
                    if !appState.hasCompletedOnboarding {
                        OnboardingView(onOnboardingComplete: {
                            appState.completeOnboarding()
                            userSettingsManager.loadUserSettings()
                        })
                    } else {
                        CustomTabBarView()
                            .environmentObject(DailyLogManager(context: nutritionDataStore.context, userSettings: userSettingsManager))
                            .environmentObject(WeeklyLogManager(context: nutritionDataStore.context))
                            .environmentObject(nutritionDataStore)
                    }
                } else {
                    iCloudRequiredView()
                }
            } else {
                // Placeholder view while checking iCloud availability
                ProgressView()
                    .onAppear {
                        userSettingsManager.checkiCloudAvailability { available in
                            iCloudAvailable = available
                        }
                    }
            }
        }
    }
}
