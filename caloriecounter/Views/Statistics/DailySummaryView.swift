//
//  DailySummaryView.swift
//  caloriecounter
//
//  Created by Sam Roman on 12/7/23.
//

import SwiftUI

struct DailySummaryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var dailyLogManager: DailyLogManager
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
                TopBarView(dailyLogManager: dailyLogManager, nutritionDataStore: nutritionDataStore, selectedDate: $dailyLogManager.selectedDate, onDateTapped: {
                    withAnimation {
                        dailyLogManager.updateSelectedDate(newDate: Date())
                    }
                }, onCalendarTapped: {}, entryType: .summary)
                .frame(maxWidth: .infinity)
                
                HStack {
                    VStack(alignment: .center) {
                        Text("\(Int(totalCaloriesConsumed)) calories")
                            .font(.title3)
                            .foregroundColor(.black)
                            .fontWeight(.light)
                        Text(String(format: "%.2f%% of goal", (totalCaloriesConsumed / calorieGoal) * 100))
                            .font(.subheadline)
                            .foregroundColor(.black)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(AppTheme.lime)
                    // Card for calorie goal
                    VStack(alignment: .center) {
                        Text("\(Int(calorieGoal)) calories")
                            .font(.title3)
                            .fontWeight(.light)
                            .foregroundStyle(AppTheme.lime)
                        Text("goal")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.lime)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(AppTheme.grayExtra)
                }
                .edgesIgnoringSafeArea(.top)
                // Meal breakdown display
                ForEach(MealType.allCases, id: \.self) { mealType in
                    MealSummaryRow(mealType: mealType, calories: Int(dailyLogManager.calories(for: mealType)))
                }
                Spacer()
                CalorieRingView(
                    breakfastPercentage: breakfastPercentage,
                    lunchPercentage: lunchPercentage,
                    dinnerPercentage: dinnerPercentage,
                    snacksPercentage: snacksPercentage
                )
                Spacer()
                MacronutrientView()
                Spacer()
            }
        }
        .background(AppTheme.prunes)
        
        .onAppear {
            // Fetch data when the view appears
            dailyLogManager.refreshData()
            breakfastPercentage = dailyLogManager.breakfastPercentage
            lunchPercentage = dailyLogManager.lunchPercentage
            dinnerPercentage = dailyLogManager.dinnerPercentage
            snacksPercentage = dailyLogManager.snackPercentage
            totalCaloriesConsumed = dailyLogManager.totalCaloriesConsumed
            calorieGoal = dailyLogManager.calorieGoal
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
                .foregroundColor(AppTheme.milk)
            Spacer()
            Text("\(calories) cal")
                .font(.subheadline)
                .foregroundColor(AppTheme.milk)
        }
        .padding(.horizontal)
    }
}

