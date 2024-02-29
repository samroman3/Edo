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

    var body: some View {
        Group {
            if !appState.hasCompletedOnboarding {
                OnboardingView(onOnboardingComplete: {
                    appState.completeOnboarding()
                    userSettingsManager.loadUserSettings()
                })
            } else {
                CustomTabBarView()
            }
        }
        .onAppear {
            // Perform iCloud availability check here and handle accordingly
        }
    }
}
