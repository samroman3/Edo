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
    @State private var prevTab: Tab = .diary
    
    var body: some View {
        VStack {
            if selectedTab != .profile {
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
                    .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .leading)))
            case .statistics:
                DailySummaryView(viewModel: DailySummaryViewModel(dailyLogManager: dailyLogManager))
                    .transition(.asymmetric(insertion: (prevTab == .diary) ? .move(edge: .trailing) : .move(edge: .leading), removal: (prevTab == .diary) ? .move(edge: .leading) : .move(edge: .trailing)))
            case .profile:
                ProfileView()
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .trailing)))
            }
            // Custom Tab Bar
            HStack(spacing: 50) {
                TabBarButton(icon: "square", selectedIcon: "square.fill", tab: .diary, selectedTab: $selectedTab, prevTab: $prevTab, color: AppTheme.sageGreen)
                TabBarButton(icon: "triangle", selectedIcon: "triangle.fill", tab: .statistics, selectedTab: $selectedTab, prevTab: $prevTab, color: AppTheme.lavender)
                TabBarButton(icon: "circle", selectedIcon: "circle.fill", tab: .profile, selectedTab: $selectedTab, prevTab: $prevTab, color: AppTheme.carrot)
                
            }
            .padding(.horizontal)
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
    @Binding var prevTab: CustomTabBarView.Tab
    let color: Color
    
    var body: some View {
        Image(systemName: selectedTab == tab ? selectedIcon : icon)
            .foregroundColor(color)
            .imageScale(.medium)
            .font(.system(size: 25))
            .onTapGesture {
                withAnimation(.spring(.smooth)) {
                    HapticFeedbackProvider.impact()
                    prevTab = selectedTab
                    print(prevTab)
                    selectedTab = tab
                    
                }

            }
    }
}

#Preview {
    CustomTabBarView()
}
