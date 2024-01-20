//
//  MealsView.swift
//  caloriecounter
//
//  Created by Sam Roman on 11/26/23.
//

import SwiftUI

struct MealsView: View {
    
    @ObservedObject var dailyLogManager: DailyLogManager
    @ObservedObject var mealSelectionViewModel: MealSelectionViewModel
    @ObservedObject var nutritionDataStore: NutritionDataStore
    
    func calculateTotalCalories(entries: [NutritionEntry]) -> Int {
        // Logic to calculate total calories
        entries.reduce(0) { $0 + Int($1.calories) }
    }
    
    
    
    @State private var expandedStates: [MealType: Bool] = Dictionary(uniqueKeysWithValues: MealType.allCases.map { ($0, false) })
    
    var body: some View {
        VStack {
            ScrollView{
                ForEach(MealType.allCases, id: \.self) { mealType in
                    let isExpandedBinding = Binding(
                        get: { self.expandedStates[mealType, default: true] },
                        set: { self.expandedStates[mealType] = $0 }
                    )
                    if let meal = dailyLogManager.meals.first(where: { $0.type == mealType.rawValue }) {
                        let entries = Array(meal.entries as? Set<NutritionEntry> ?? []).sorted { n1, n2 in
                            n1.calories < n2.calories
                        }
                        MealCardView(
                            mealType: mealType.displayName,
                            entries: entries,
                            isExpanded: isExpandedBinding,
                            onAddTapped: { mealSelectionViewModel.selectMealType(mealType.rawValue)}, onDeleteEntry: { entry in
                                deleteEntry(entry)})
                        if !entries.isEmpty {
                            ChevronView(isExpanded: isExpandedBinding, totalCalories: calculateTotalCalories(entries: entries))
                                .padding(.horizontal)
                        }
                        Divider().background(AppTheme.lime)
                    }
                    else {
                        if mealType == .water {
                            WaterIntakeView(viewModel: WaterIntakeViewModel(dailyLogManager: dailyLogManager, nutritionDataStore: nutritionDataStore))
                        } else {
                            PlaceholderMealView(
                                mealType: mealType.displayName,
                                onAddTapped: { mealSelectionViewModel.selectMealType(mealType.rawValue) }
                            )
                        }
                        Divider().background(AppTheme.lime)
                        
                    }
                    
                }
               
            }
        }
    }
    private func deleteEntry(_ entry: NutritionEntry) {
        nutritionDataStore.deleteEntry(entry)
        dailyLogManager.fetchDailyLogForSelectedDate()
        
    }
    
    struct PlaceholderMealView: View {
        let mealType: String
        var onAddTapped: () -> Void
        
        var body: some View {
            VStack() {
                HStack {
                    Text(mealType)
                        .font(.largeTitle)
                        .fontWeight(.light)
                        .foregroundStyle(AppTheme.lime)
                    Spacer()
                    Button(action: onAddTapped) {
                        Image(systemName: "plus.circle")
                            .resizable()
                            .tint(Color.blue)
                            .frame(width: 30, height: 30)
                            .foregroundStyle(AppTheme.lime)
                    }
                    .padding(.vertical)
                }
                .padding(.horizontal)
                .contentShape(Rectangle())
            }
            
        }
    }
}





//#Preview {
//    MealsView()
//}
