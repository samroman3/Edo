//
//  DiaryView.swift
//  caloriecounter
//
//  Created by Sam Roman on 12/5/23.
//

import SwiftUI

struct DiaryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var dailyLogManager: DailyLogManager
    @EnvironmentObject private var mealSelectionViewModel: MealSelectionViewModel
    @EnvironmentObject private var nutritionDataStore: NutritionDataStore
    @EnvironmentObject private var userSettingsManager: UserSettingsManager
    @State private var showingAddItemForm = false
    
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center) {
                MealsView(dailyLogManager: dailyLogManager, mealSelectionViewModel: mealSelectionViewModel, nutritionDataStore: nutritionDataStore)
                    .frame(maxWidth: .infinity)
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $mealSelectionViewModel.showingAddItemForm) {
                
                AddItemFormView(
                    isPresented: $mealSelectionViewModel.showingAddItemForm,
                    selectedDate: dailyLogManager.selectedDate,
                    mealType: $mealSelectionViewModel.currentMealType,
                    dataStore: nutritionDataStore,
                    onDismiss: {
                        dailyLogManager.refreshData()
                    }).presentationBackground(Material.ultraThickMaterial)
                
            }
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Ensures NavigationView uses the full width on iPads
    }}
