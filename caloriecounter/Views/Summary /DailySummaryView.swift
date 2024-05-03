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
                //Macro percentages
                Spacer()
                MacronutrientView(carbGoal: dailyLogManager.carbGoal,
                                  fatGoal: dailyLogManager.fatGoal,
                                  proteinGoal: dailyLogManager.proteinGoal, calorieGoal: dailyLogManager.calorieGoal,
                                  macros: (dailyLogManager.totalCaloriesConsumed,dailyLogManager.totalGramsCarbs, dailyLogManager.totalGramsProtein, dailyLogManager.totalGramsFats), summaryViewModel: viewModel)
                Divider().background(AppTheme.textColor)
                Spacer()
                HStack {
                    MacroRingView(
                        percentages: withAnimation {dailyLogManager.getPercentages(for: viewModel.selectedMacro)}
                    )
                    VStack{
                        ForEach(MealType.allCases.filter { $0 != .water }, id: \.self) { mealType in
                            MealSummaryRow(mealType: mealType, macroType: viewModel.selectedMacro, value: Int(dailyLogManager.totals(for: viewModel.selectedMacro, mealType: mealType)))
                        }
                    }.padding(.horizontal)
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
        let macroType: MacroType
        let value: Int
        
        private var iconColor: Color {
            switch mealType {
            case .breakfast:
                return AppTheme.peach
            case .lunch:
                return AppTheme.dustyRose
            case .dinner:
                return AppTheme.dustyBlue
            case .snack:
                return AppTheme.teal
            case .water:
                return .black
            }
        }
        private var label: String {
            switch macroType {
            case .calories:
                "Calories"
            case .protein:
                "Protein"
            case .carbs:
                "Carbs"
            case .fats:
                "Fats"
            }
        }
        
        var body: some View {
            VStack{
                HStack {
                    Image(systemName: "circle.fill")
                        .foregroundColor(iconColor)
                    Text("\(mealType.rawValue):")
                        .font(.headline)
                        .foregroundColor(AppTheme.textColor)
                }
                Text("\(value) \(label)")
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textColor)
            }
        }
    }
}

enum MacroType {
    case calories
    case protein
    case carbs
    case fats
}
