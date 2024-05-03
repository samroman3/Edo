//
//  DailySummaryView.swift
//  caloriecounter
//
//  Created by Sam Roman on 12/7/23.
//

import SwiftUI

struct DailySummaryView: View {
    @EnvironmentObject private var dailyLogManager: DailyLogManager
    @EnvironmentObject private var mealSelectionViewModel: MealSelectionViewModel
    @EnvironmentObject private var nutritionDataStore: NutritionDataStore
    
    @ObservedObject private var viewModel: DailySummaryViewModel
    
    init(viewModel: DailySummaryViewModel) {
        
        self.viewModel = viewModel
    }
    var body: some View {
        ScrollView {
            Divider().background(AppTheme.textColor)
            VStack(spacing: 10) {
                HStack {
                    VStack(alignment: .center) {
                        Text("\(Int(viewModel.totalCaloriesConsumed)) calories")
                            .font(.title3)
                            .foregroundStyle(AppTheme.textColor)
                            .fontWeight(.light)
                        Text(String(format: "%.2f%% of goal", (viewModel.totalCaloriesConsumed / viewModel.calorieGoal) * 100))
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.textColor)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    // Card for calorie goal
                    VStack(alignment: .center) {
                        Text("\(Int(viewModel.calorieGoal)) calories")
                            .font(.title3)
                            .fontWeight(.light)
                            .foregroundStyle(AppTheme.reverse)
                        Text("goal")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.reverse)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                     .background(AppTheme.sageGreen)

                }
                .edgesIgnoringSafeArea(.all)
                //Macro percentages
                Spacer()
                MacronutrientView(carbGoal: dailyLogManager.carbGoal,
                                  fatGoal: dailyLogManager.fatGoal,
                                  proteinGoal: dailyLogManager.proteinGoal,
                                  macros: (dailyLogManager.totalGramsCarbs, dailyLogManager.totalGramsProtein, dailyLogManager.totalGramsFats))

                Spacer()
                CalorieRingView(
                    breakfastPercentage: viewModel.breakfastPercentage,
                    lunchPercentage: viewModel.lunchPercentage,
                    dinnerPercentage: viewModel.dinnerPercentage,
                    snacksPercentage: viewModel.snacksPercentage
                ).padding()
                Spacer()
                ForEach(MealType.allCases.filter { $0 != .water }, id: \.self) { mealType in
                    MealSummaryRow(mealType: mealType, calories: Int(dailyLogManager.calories(for: mealType)))
                }
            }
        }
        .onAppear {
                   dailyLogManager.refreshData {
                       viewModel.refreshViewData()
                   }
               }
               .onReceive(dailyLogManager.$selectedDate) { _ in
                   dailyLogManager.refreshData {
                       viewModel.refreshViewData()
                   }
               }
    }
    
    struct MealSummaryRow: View {
        let mealType: MealType
        let calories: Int
        
        private var iconColor: Color {
               switch mealType {
               case .breakfast:
                   return AppTheme.peach
               case .lunch:
                   return AppTheme.lavender
               case .dinner:
                   return AppTheme.skyBlue
               case .snack:
                   return AppTheme.teal
               case .water:
                   return .black
               }
           }
        
        var body: some View {
            HStack {
                Image(systemName: "circle.fill")
                    .foregroundColor(iconColor)
                Text(mealType.rawValue)
                    .font(.headline)
                    .foregroundColor(AppTheme.textColor)
                Spacer()
                Text("\(calories) cal")
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textColor)
            }
            .padding(.horizontal)
        }
    }
}


