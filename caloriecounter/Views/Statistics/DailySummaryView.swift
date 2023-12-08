//
//  DailySummaryView.swift
//  caloriecounter
//
//  Created by Sam Roman on 12/7/23.
//

import SwiftUI

struct DailySummaryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var dateSelectionManager: DateSelectionManager
    @EnvironmentObject private var mealSelectionViewModel: MealSelectionViewModel
    @EnvironmentObject private var nutritionDataStore: NutritionDataStore
    
    @State var breakfastPercentage = 0.0
    @State var lunchPercentage = 0.0
    @State var dinnerPercentage = 0.0
    @State var snacksPercentage = 0.0
    @State var totalCaloriesConsumed = 0.0
    @State var calorieGoal = 1900.0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                TopBarView(dateSelectionManager: dateSelectionManager, nutritionDataStore: nutritionDataStore, selectedDate: $dateSelectionManager.selectedDate, onDateTapped: {
                    withAnimation {
                        dateSelectionManager.updateSelectedDate(newDate: Date())
                    }
                }, onCalendarTapped: {})
                .frame(maxWidth: .infinity)

                // Daily calorie goal and intake display
                HStack {
                    VStack(alignment: .leading) {
                        Text(String(Int(totalCaloriesConsumed)))
                            .font(.title)
                            .fontWeight(.bold)
                        Text(String(format: "%.2f%% of goal", (totalCaloriesConsumed / calorieGoal) * 100))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("\(Int(calorieGoal)) calories")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("goal")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal)
                CalorieRingView(
                    breakfastPercentage: breakfastPercentage,
                    lunchPercentage: lunchPercentage,
                    dinnerPercentage: dinnerPercentage,
                    snacksPercentage: snacksPercentage
                )
                
                // Meal breakdown display
                ForEach(MealType.allCases, id: \.self) { mealType in
                    MealSummaryRow(mealType: mealType, calories: Int(dateSelectionManager.calories(for: mealType)))
                }
            }
        }
        .onAppear {
            // Fetch data when the view appears
            dateSelectionManager.refreshData()
            breakfastPercentage = dateSelectionManager.breakfastPercentage
            lunchPercentage = dateSelectionManager.lunchPercentage
            dinnerPercentage = dateSelectionManager.dinnerPercentage
            snacksPercentage = dateSelectionManager.snackPercentage
            totalCaloriesConsumed = dateSelectionManager.totalCaloriesConsumed
            calorieGoal = dateSelectionManager.calorieGoal
        }
    }
}

struct MealSummaryRow: View {
    let mealType: MealType
    let calories: Int
    
    var body: some View {
        HStack {
            Text(mealType.rawValue)
                .font(.headline)
            Spacer()
            Text("\(calories) cal")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding(.horizontal)
    }
}

