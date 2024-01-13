//
//  MainView.swift
//  caloriecounter
//
//  Created by Sam Roman on 12/14/23.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var userSettingsManager: UserSettingsManager
    
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        CustomTabBarView()
//        if UserSettings.needsOnboarding {
//            OnboardingView(onOnboardingComplete: {
//                UserSettings.needsOnboarding = false
//            }, onLoginSuccess: { appState.login() })
//        } else if appState.isLoggedIn {
//            CustomTabBarView()
//        } else {
//            LoginSignupView(onLoginSuccess: { appState.login() })
//        }
    }
}
//#Preview {
//    MainView()
//}
