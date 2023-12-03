//
//  ContentView.swift
//  caloriecounter
//
//  Created by Sam Roman on 11/24/23.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var dateSelectionManager: DateSelectionManager
    @StateObject private var mealSelectionViewModel: MealSelectionViewModel
    @StateObject private var nutritionDataStore: NutritionDataStore
    @State private var showingAddItemForm = false
    
    let mealTypes = ["Breakfast", "Lunch", "Dinner", "Snacks"]
    
    
    
    init() {
        let context = PersistenceController.shared.container.viewContext
        let dataStore = NutritionDataStore(context: context)
        let dateManager = DateSelectionManager(context: context)
        _nutritionDataStore = StateObject(wrappedValue: dataStore)
        _dateSelectionManager = StateObject(wrappedValue: dateManager)
        _mealSelectionViewModel = StateObject(wrappedValue: MealSelectionViewModel(dataStore: dataStore, context: context))
        
    }

    
    private func colorForMealType(_ mealType: MealType) -> Color {
        switch mealType {
        case .breakfast:
            return Color.orange
        case .lunch:
            return Color.green
        case .dinner:
            return Color.blue
        case .snack:
            return Color.indigo
        }
    }
    
    private func progressForMealType(_ mealType: String) -> Float {
        // logic to calculate progress based on the meal type
        // percentage of daily calorie goal achieved. water intake etc
        // to be moved to model
        return 0.5
    }
    var body: some View {
        NavigationView {
            VStack(alignment: .center) {
                TopBarView(dateSelectionManager: dateSelectionManager, nutritionDataStore: nutritionDataStore, selectedDate: $dateSelectionManager.selectedDate, onDateTapped: {
                    withAnimation {
                        dateSelectionManager.updateSelectedDate(newDate: Date())
                    }
                }, onCalendarTapped: {})
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
    }
    }






//#Preview {
//    ContentView()
//        .modelContainer(for: Item.self, inMemory: true)
//}
