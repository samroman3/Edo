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

    
    var body: some View {
        Group {
            if !appState.hasCompletedOnboarding {
                OnboardingView(onOnboardingComplete: {
                    appState.completeOnboarding()
                    userSettingsManager.loadUserSettings()
                })
            } else {
                CustomTabBarView()
                    .environmentObject(DailyLogManager(context: nutritionDataStore.context, userSettings: userSettingsManager))
                    .environmentObject(nutritionDataStore)
            }
        }
    }
}
