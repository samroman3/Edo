//
//  DailySummaryView.swift
//  caloriecounter
//
//  Created by Sam Roman on 12/7/23.
//

import SwiftUI

struct DailySummaryView: View {
    @ObservedObject private var dailyLogManager: DailyLogManager
    @ObservedObject private var nutritionDataStore: NutritionDataStore
    
    @ObservedObject private var viewModel: DailySummaryViewModel
    
    init(dailyLogManager: DailyLogManager, dataStore: NutritionDataStore) {
        self.dailyLogManager = dailyLogManager
        self.nutritionDataStore = dataStore
        
        self.viewModel = DailySummaryViewModel(dailyLogManager: dailyLogManager)
        
    }
    
    var body: some View {
        ScrollView(showsIndicators: false){
            VStack {
                Divider().background(AppTheme.textColor)
                
                VStack(spacing: 10) {
                    // Macro percentages view
                    Spacer()
                    
                    MacronutrientView(summaryViewModel: viewModel)
                    Divider().background(AppTheme.textColor)
                    HStack {
                        MacroPieView(
                            percentages: withAnimation { dailyLogManager.getPercentages(for: viewModel.selectedMacro) }
                        )
                        .padding(.vertical)
                        .frame(maxWidth: 200, maxHeight: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .shadow(radius: 5)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(MealType.allCases.filter { $0 != .water }, id: \.self) { mealType in
                                MealSummaryRow(
                                    mealType: mealType,
                                    macroType: viewModel.selectedMacro,
                                    value: Int(dailyLogManager.totals(for: viewModel.selectedMacro, mealType: mealType))
                                ).frame(minWidth: 80)
                            }
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                    }
                    .padding(.horizontal)
                }
            }
        }.onAppear(){
            dailyLogManager.refreshData()
        }
    }
    
    private func macroColor() -> Color {
        switch viewModel.selectedMacro {
        case .calories: return AppTheme.sageGreen
        case .carbs: return AppTheme.goldenrod
        case .fats: return AppTheme.carrot
        case .protein: return AppTheme.lavender
        }
    }
    
    struct MealSummaryRow: View {
        let mealType: MealType
        let macroType: MacroType
        let value: Int
        
        private var iconColor: Color {
            switch mealType {
            case .breakfast: return AppTheme.lime
            case .lunch: return .mint
            case .dinner: return .indigo
            case .snack: return .pink
            case .water: return .black
            }
        }
        
        private var label: String {
            switch macroType {
            case .calories: return "Cal"
            case .protein: return "Prot"
            case .carbs: return "Carbs"
            case .fats: return "Fats"
            }
        }
        
        var body: some View {
            VStack() {
                HStack{
                    Image(systemName: "circle.fill")
                        .foregroundColor(iconColor)
                    Text("\(mealType.rawValue):")
                        .font(AppTheme.standardBookBody)
                        .foregroundColor(AppTheme.textColor)
                }
                    Text("\(value) \(label)")
                    .font(AppTheme.standardBookCaption)
                        .foregroundColor(AppTheme.textColor)
            }
            .padding(.vertical, 4)
            .padding(.horizontal)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

enum MacroType {
    case calories, protein, carbs, fats
}

