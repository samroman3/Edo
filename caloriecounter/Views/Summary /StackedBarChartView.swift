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
    
    private let barWidth: CGFloat = 20
    private let chartHeight: CGFloat = 200 // Fixed height for the chart
    
    var body: some View {
        VStack {
            Text("Weekly Stacked Bar Chart")
                .font(AppTheme.standardBookBody)
                .foregroundColor(AppTheme.textColor)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .bottom, spacing: 16) {
                    ForEach((0..<7).reversed(), id: \.self) { index in
                        let date = Calendar.current.date(byAdding: .day, value: -index, to: dailyLogManager.selectedDate)!
                        let dailyCalories = weeklyLogManager.totalNutrients(for: date, macro: .calories)
                        let calorieGoal = dailyLogManager.calorieGoal
                        
                        VStack {
                            Text(dateFormatter.string(from: date))
                                .font(.caption)
                                .foregroundColor(AppTheme.textColor)
                            
                            HStack(spacing: 8) {
                                StackedBar(
                                    data: [
                                        weeklyLogManager.totalNutrients(for: date, macro: .carbs),
                                        weeklyLogManager.totalNutrients(for: date, macro: .protein),
                                        weeklyLogManager.totalNutrients(for: date, macro: .fats)
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
                .frame(height: chartHeight)
            }
        }
        .padding()
        .onAppear {
            weeklyLogManager.fetchWeeklyLogs(from: dailyLogManager.selectedDate)
        }
        .onChange(of: dailyLogManager.selectedDate) { newDate in
            weeklyLogManager.fetchWeeklyLogs(from: newDate)
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
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
                            .frame(width: 20, height: CGFloat(data[index] / calorieGoal) * maxHeight)
                    }
                }
                .frame(width: 20)
                .clipShape(RoundedRectangle(cornerRadius: 5))
            } else {
                Rectangle()
                    .fill(Color.gray)
                    .frame(width: 20, height: maxHeight)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
            }
        }
        .frame(maxHeight: maxHeight)
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
            .frame(width: 20, height: CGFloat(value / maxValue) * maxHeight)
            .clipShape(RoundedRectangle(cornerRadius: 5))
            .frame(maxHeight: maxHeight)
    }
}
