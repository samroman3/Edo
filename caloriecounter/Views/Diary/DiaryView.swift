//
//  DiaryView.swift
//  caloriecounter
//
//  Created by Sam Roman on 12/5/23.
//

import SwiftUI

struct DiaryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var dateSelectionManager: DateSelectionManager
    @EnvironmentObject private var mealSelectionViewModel: MealSelectionViewModel
    @EnvironmentObject private var nutritionDataStore: NutritionDataStore
    @State private var showingAddItemForm = false
    
    let mealTypes = ["Breakfast", "Lunch", "Dinner", "Snacks"]

    
    var body: some View {
        NavigationView {
            VStack(alignment: .center) {
                TopBarView(dateSelectionManager: dateSelectionManager, nutritionDataStore: nutritionDataStore, selectedDate: $dateSelectionManager.selectedDate, onDateTapped: {
                    withAnimation {
                        dateSelectionManager.updateSelectedDate(newDate: Date())
                    }
                }, onCalendarTapped: {}, entryType: .diary)
                .frame(maxWidth: .infinity)
                Divider().background(AppTheme.lime)
                MealsView(dateSelectionManager: dateSelectionManager, mealSelectionViewModel: mealSelectionViewModel, nutritionDataStore: nutritionDataStore)
                .frame(maxWidth: .infinity)
            }
            .navigationBarHidden(true)
            .fullScreenCover(isPresented: $mealSelectionViewModel.showingAddItemForm) {
                AddItemFormView(isPresented: $mealSelectionViewModel.showingAddItemForm, selectedDate: dateSelectionManager.selectedDate, mealType: $mealSelectionViewModel.currentMealType, dataStore: NutritionDataStore(context: viewContext), onDismiss: {dateSelectionManager.fetchDailyLogForSelectedDate()})
                    
            }
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Ensures NavigationView uses the full width on iPads
    }}

//#Preview {
//    DiaryView()
//}
