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
            VStack(spacing: 20) {
                TopBarView(dailyLogManager: dailyLogManager, nutritionDataStore: nutritionDataStore, selectedDate: $dailyLogManager.selectedDate, onDateTapped: {
                    withAnimation {
                        dailyLogManager.updateSelectedDate(newDate: Date())
                        dailyLogManager.refreshData {
                            viewModel.refreshViewData()
                        }
                    }
                }, onCalendarTapped: {}, entryType: .summary)
                .frame(maxWidth: .infinity)
                
                HStack {
                    VStack(alignment: .center) {
                        Text("\(Int(viewModel.totalCaloriesConsumed)) calories")
                            .font(.title3)
                            .foregroundColor(.black)
                            .fontWeight(.light)
                        Text(String(format: "%.2f%% of goal", (viewModel.totalCaloriesConsumed / viewModel.calorieGoal) * 100))
                            .font(.subheadline)
                            .foregroundColor(.black)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(AppTheme.basic)
                    // Card for calorie goal
                    VStack(alignment: .center) {
                        Text("\(Int(viewModel.calorieGoal)) calories")
                            .font(.title3)
                            .fontWeight(.light)
                            .foregroundStyle(AppTheme.basic)
                        Text("goal")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.basic)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(AppTheme.grayExtra)
                }
                .edgesIgnoringSafeArea(.top)
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
                )
                ForEach(MealType.allCases.filter { $0 != .water }, id: \.self) { mealType in
                    MealSummaryRow(mealType: mealType, calories: Int(dailyLogManager.calories(for: mealType)))
                }
            }
        }
        .background(AppTheme.prunes)
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
                   return AppTheme.carrot
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
                    .foregroundColor(AppTheme.milk)
                Spacer()
                Text("\(calories) cal")
                    .font(.subheadline)
                    .foregroundColor(AppTheme.milk)
            }
            .padding(.horizontal)
        }
    }
}


