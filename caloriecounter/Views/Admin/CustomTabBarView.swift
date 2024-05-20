//
//  CustomTabBarView.swift
//  caloriecounter
//
//  Created by Sam Roman on 12/5/23.
//

import SwiftUI

struct CustomTabBarView: View {
    
    @EnvironmentObject private var dailyLogManager: DailyLogManager
    @EnvironmentObject private var nutritionDataStore: NutritionDataStore
    @State private var selectedTab: Tab = .diary
    
    @State var profileEditing: Bool = false
    
    var body: some View {
        VStack {
            if selectedTab != .profile /*&& selectedTab != .quick */{
                TopBarView(dailyLogManager: dailyLogManager, nutritionDataStore: nutritionDataStore, selectedDate: $dailyLogManager.selectedDate, onDateTapped: {
                    withAnimation {
                        dailyLogManager.updateSelectedDate(newDate: Date())
                    }
                }, onCalendarTapped: {})
                .frame(maxWidth: .infinity)
            }
            switch selectedTab {
            case .diary:
                DiaryView()
            case .statistics:
                DailySummaryView(dailyLogManager: dailyLogManager, dataStore: nutritionDataStore)
            case .profile:
                ProfileView(profileEditing: $profileEditing)
//            case .quick:
//                BarcodeScannerView()
            }
            if !profileEditing {
                // Custom Tab Bar
                HStack(spacing: 50) {
                    TabBarButton(icon: "square", selectedIcon: "square.fill", tab: .diary, selectedTab: $selectedTab, color: AppTheme.sageGreen)
//                    TabBarButton(icon: "bolt", selectedIcon: "bolt.fill", tab: .quick, selectedTab: $selectedTab, color: AppTheme.goldenrod)
                    TabBarButton(icon: "circle", selectedIcon: "circle.fill", tab: .statistics, selectedTab: $selectedTab, color: AppTheme.lavender)
                    TabBarButton(icon: "triangle", selectedIcon: "triangle.fill", tab: .profile, selectedTab: $selectedTab, color: AppTheme.carrot)
                    
                }
                .padding(.horizontal)
            }
        }.onAppear(){
            dailyLogManager.refreshData()
        }
    }
    
    enum Tab {
        case diary, statistics, profile
    }
}

struct TabBarButton: View {
    let icon: String
    let selectedIcon: String
    let tab: CustomTabBarView.Tab
    @Binding var selectedTab: CustomTabBarView.Tab
    let color: Color
    
    var body: some View {
        Image(systemName: selectedTab == tab ? selectedIcon : icon)
            .foregroundColor(color)
            .imageScale(.medium)
            .font(.system(size: 25))
            .onTapGesture {
                withAnimation(.snappy) {
                    HapticFeedbackProvider.impact()
                    selectedTab = tab
                }

            }
    }
}

#Preview {
    CustomTabBarView()
}
