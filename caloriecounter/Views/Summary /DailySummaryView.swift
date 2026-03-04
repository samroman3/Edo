//
//  DailySummaryView.swift
//  caloriecounter
//
//  Created by Sam Roman on 12/7/23.
//
import SwiftUI

enum DisplayMode {
    case rings, bars
}

struct DailySummaryView: View {
    @ObservedObject private var dailyLogManager: DailyLogManager
    @ObservedObject private var viewModel: DailySummaryViewModel
    @EnvironmentObject var weeklyLogManager: WeeklyLogManager
    @State private var displayMode: DisplayMode = .bars
    @State private var isPieChartExpanded: Bool = false
    
    init(dailyLogManager: DailyLogManager) {
        self.dailyLogManager = dailyLogManager
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
            weeklySnapshotCard
                .padding(.horizontal)
            
            ScrollView(showsIndicators: false) {
                VStack {
                    Divider().background(AppTheme.textColor)
                    
                    VStack(spacing: 10) {
                        Group {
                            switch displayMode {
                            case .rings:
                                MacronutrientView(summaryViewModel: viewModel)
                                    .environmentObject(dailyLogManager)
                            case .bars:
                                BarDisplayView(summaryViewModel: viewModel)
                                    .environmentObject(dailyLogManager)
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
                                    percentages: dailyLogManager.getPercentages(for: viewModel.selectedMacro)
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
                    .padding(.horizontal, 16)
                }
            }
            .onAppear {
                dailyLogManager.refreshData()
                refreshWeeklySnapshot()
            }
            .onChange(of: dailyLogManager.selectedDate) { _, _ in
                refreshWeeklySnapshot()
            }
        }
    }
    
    private func cycleDisplayMode() {
        switch displayMode {
        case .rings:
            displayMode = .bars
        case .bars:
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

    private var weeklySnapshotCard: some View {
        HStack(spacing: 12) {
            snapshotMetric(title: "7-Day Avg", value: averageText, tint: macroColor())
            snapshotMetric(title: "Days Logged", value: "\(loggedDaysCount)/7", tint: AppTheme.goldenrod)
            snapshotMetric(title: "Streak", value: "\(currentLoggingStreak)d", tint: AppTheme.sageGreen)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private func snapshotMetric(title: String, value: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(AppTheme.standardBookCaption)
                .foregroundStyle(AppTheme.textColor.opacity(0.7))
            Text(value)
                .font(AppTheme.standardBookBody)
                .foregroundStyle(tint)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var trailingWeekDates: [Date] {
        let calendar = Calendar.current
        return (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: -offset, to: dailyLogManager.selectedDate)
        }.reversed()
    }

    private var loggedDaysCount: Int {
        trailingWeekDates.reduce(0) { partialResult, date in
            partialResult + (weeklyLogManager.totalNutrients(for: date, macro: .calories) > 0 ? 1 : 0)
        }
    }

    private var currentLoggingStreak: Int {
        var streak = 0

        for date in trailingWeekDates.reversed() {
            if weeklyLogManager.totalNutrients(for: date, macro: .calories) > 0 {
                streak += 1
            } else {
                break
            }
        }

        return streak
    }

    private var averageValue: Double {
        let loggedDates = trailingWeekDates.filter { weeklyLogManager.totalNutrients(for: $0, macro: viewModel.selectedMacro) > 0 }
        guard !loggedDates.isEmpty else {
            return 0
        }

        let total = loggedDates.reduce(0.0) { partialResult, date in
            partialResult + weeklyLogManager.totalNutrients(for: date, macro: viewModel.selectedMacro)
        }

        return total / Double(loggedDates.count)
    }

    private var averageText: String {
        switch viewModel.selectedMacro {
        case .calories:
            return "\(Int(averageValue)) cal"
        case .protein:
            return "\(Int(averageValue))g prot"
        case .carbs:
            return "\(Int(averageValue))g carbs"
        case .fats:
            return "\(Int(averageValue))g fats"
        }
    }

    private func refreshWeeklySnapshot() {
        weeklyLogManager.fetchWeeklyLogs(from: dailyLogManager.selectedDate)
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
