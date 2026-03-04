//
//  StackedBarChartView.swift
//  caloriecounter
//
//  Created by Sam Roman on 7/20/24.
//
import SwiftUI

struct StackedBarChartView: View {
    @EnvironmentObject var weeklyLogManager: WeeklyLogManager
    @EnvironmentObject var dailyLogManager: DailyLogManager
    @ObservedObject var summaryViewModel: DailySummaryViewModel
    
    private let chartHeight: CGFloat = 260
    
    var body: some View {
        VStack(spacing: 8) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .bottom, spacing: 18) {
                    ForEach((0..<7).reversed(), id: \.self) { index in
                        let date = Calendar.current.date(byAdding: .day, value: -index, to: dailyLogManager.selectedDate)!
                        let dailyCalories = weeklyLogManager.totalNutrients(for: date, macro: .calories)
                        let calorieGoal = dailyLogManager.calorieGoal
                        let carbCalories = weeklyLogManager.totalNutrients(for: date, macro: .carbs) * 4
                        let proteinCalories = weeklyLogManager.totalNutrients(for: date, macro: .protein) * 4
                        let fatCalories = weeklyLogManager.totalNutrients(for: date, macro: .fats) * 9
                        
                        VStack(spacing: 10) {
                            Text(dateFormatter.string(from: date))
                                .font(.caption)
                                .foregroundColor(AppTheme.textColor)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                            
                            HStack(spacing: 8) {
                                StackedBar(
                                    data: [
                                        carbCalories,
                                        proteinCalories,
                                        fatCalories
                                    ],
                                    colors: [AppTheme.goldenrod, AppTheme.lavender, AppTheme.carrot],
                                    maxHeight: chartHeight,
                                    calorieGoal: calorieGoal
                                )
                                
                                Bar(
                                    value: dailyCalories,
                                    maxValue: calorieGoal,
                                    color: AppTheme.sageGreen,
                                    maxHeight: chartHeight
                                )
                            }
                        }
                    }
                }
                .padding(.horizontal, 12)
                .frame(height: chartHeight + 48, alignment: .bottom)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .onAppear {
            weeklyLogManager.fetchWeeklyLogs(from: dailyLogManager.selectedDate)
        }
        .onChange(of: dailyLogManager.selectedDate) { _, newDate in
            weeklyLogManager.fetchWeeklyLogs(from: newDate)
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter
    }
}

struct StackedBar: View {
    var data: [Double]
    var colors: [Color]
    var maxHeight: CGFloat
    var calorieGoal: Double
    
    var total: Double {
        data.reduce(0, +)
    }
    
    var body: some View {
        VStack {
            if total > 0 {
                VStack(spacing: 0) {
                    ForEach(0..<data.count, id: \.self) { index in
                        Rectangle()
                            .fill(colors[index % colors.count])
                            .frame(width: 22, height: segmentHeight(for: data[index]))
                    }
                }
                .frame(width: 22)
                .clipShape(RoundedRectangle(cornerRadius: 5))
            } else {
                Rectangle()
                    .fill(Color.gray)
                    .frame(width: 22, height: maxHeight)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
            }
        }
        .frame(maxHeight: maxHeight)
    }

    private func segmentHeight(for value: Double) -> CGFloat {
        guard calorieGoal > 0 else {
            return 0
        }
        return CGFloat(value / calorieGoal) * maxHeight
    }
}

struct Bar: View {
    var value: Double
    var maxValue: Double
    var color: Color
    var maxHeight: CGFloat
    
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: 22, height: barHeight)
            .clipShape(RoundedRectangle(cornerRadius: 5))
            .frame(maxHeight: maxHeight)
    }

    private var barHeight: CGFloat {
        guard maxValue > 0 else {
            return 0
        }
        return CGFloat(value / maxValue) * maxHeight
    }
}
