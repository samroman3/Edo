//
//  DailySummaryView.swift
//  caloriecounter
//
//  Created by Sam Roman on 12/7/23.
//
import SwiftUI

enum DisplayMode {
    case rings, bars, stackedBarChart
}

struct DailySummaryView: View {
    @ObservedObject private var dailyLogManager: DailyLogManager
    @ObservedObject private var nutritionDataStore: NutritionDataStore
    @ObservedObject private var viewModel: DailySummaryViewModel
    @EnvironmentObject var weeklyLogManager: WeeklyLogManager
    @State private var displayMode: DisplayMode = .bars
    @State private var isPieChartExpanded: Bool = false
    
    init(dailyLogManager: DailyLogManager, dataStore: NutritionDataStore) {
        self.dailyLogManager = dailyLogManager
        self.nutritionDataStore = dataStore
        self.viewModel = DailySummaryViewModel(dailyLogManager: dailyLogManager)
    }
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    withAnimation {
                        displayMode = .rings
                    }
                }) {
                    Image(systemName: "circle.grid.2x2")
                        .foregroundColor(displayMode == .rings ? AppTheme.textColor : .gray)
                        .padding()
                }
                Button(action: {
                    withAnimation {
                        displayMode = .bars
                    }
                }) {
                    Image(systemName: "chart.bar.doc.horizontal")
                        .foregroundColor(displayMode == .bars ? AppTheme.textColor : .gray)
                        .padding()
                }
                Button(action: {
                    withAnimation {
                        displayMode = .stackedBarChart
                    }
                }) {
                    Image(systemName: "chart.bar.fill")
                        .foregroundColor(displayMode == .stackedBarChart ? AppTheme.textColor : .gray)
                        .padding()
                }
                Spacer()
                Button(action: {
                    withAnimation {
                        isPieChartExpanded.toggle()
                    }
                }) {
                    Circle()
                        .fill(isPieChartExpanded ? AppTheme.textColor.opacity(0.3) : .clear)
                        .frame(width: 30, height: 30)
                        .overlay(
                            Image(systemName: "chart.pie")
                                .foregroundColor(isPieChartExpanded ? AppTheme.textColor : .gray)
                        )
                }
            }
            .padding(.horizontal)
            
            ScrollView(showsIndicators: false) {
                VStack {
                    Divider().background(AppTheme.textColor)
                    
                    VStack(spacing: 10) {
                        Spacer()
                        Group {
                            switch displayMode {
                            case .rings:
                                MacronutrientView(summaryViewModel: viewModel)
                                    .environmentObject(dailyLogManager)
                            case .bars:
                                BarDisplayView(summaryViewModel: viewModel)
                                    .environmentObject(dailyLogManager)
                            case .stackedBarChart:
                                StackedBarChartView(summaryViewModel: viewModel)
                                    .environmentObject(dailyLogManager)
                                    .environmentObject(weeklyLogManager)
                            }
                        }
                        .transition(.slide)
                        
                        Divider().background(AppTheme.textColor)
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(MealType.allCases.filter { $0 != .water }, id: \.self) { mealType in
                                    MealSummaryRow(
                                        mealType: mealType,
                                        macroType: viewModel.selectedMacro,
                                        value: Int(dailyLogManager.totals(for: viewModel.selectedMacro, mealType: mealType)),
                                        isPieChartShrunk: !isPieChartExpanded
                                    )
                                    .frame(minWidth: 80)
                                }
                            }
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                            
                            if isPieChartExpanded {
                                MacroPieView(
                                    percentages: withAnimation { dailyLogManager.getPercentages(for: viewModel.selectedMacro) }
                                )
                                .padding(.vertical)
                                .frame(maxWidth: 200, maxHeight: .infinity)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                .shadow(radius: 5)
                                .transition(.scale)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.horizontal)
                }
            }
            .onAppear {
                dailyLogManager.refreshData()
            }
        }
    }
    
    private func cycleDisplayMode() {
        switch displayMode {
        case .rings:
            displayMode = .bars
        case .bars:
            displayMode = .stackedBarChart
        case .stackedBarChart:
            displayMode = .rings
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
        var isPieChartShrunk: Bool
        
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
            VStack {
                HStack {
                    if isPieChartShrunk {
                        Image(systemName: "circle.fill")
                            .foregroundColor(iconColor)
                        VStack() {
                            Text("\(mealType.rawValue.capitalized)")
                                .font(AppTheme.standardBookBody)
                                .foregroundColor(AppTheme.textColor)
                                .multilineTextAlignment(.center)
                            Text("\(value) \(label)")
                                .font(AppTheme.standardBookCaption)
                                .foregroundColor(AppTheme.textColor)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                    } else {
                        VStack(alignment: .leading, spacing: 5) {
                            Image(systemName: "circle.fill")
                                .foregroundColor(iconColor)
                            Text("\(mealType.rawValue.capitalized)")
                                .font(AppTheme.standardBookBody)
                                .foregroundColor(AppTheme.textColor)
                            Text("\(value) \(label)")
                                .font(AppTheme.standardBookCaption)
                                .foregroundColor(AppTheme.textColor)
                        }
                        Spacer()
                    }
                }
                .padding(.vertical, 4)
                .padding(.horizontal)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }
}

enum MacroType: String {
    case calories, protein, carbs, fats
}
