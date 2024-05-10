//
//  MacronutrientView.swift
//  caloriecounter
//
//  Created by Sam Roman on 1/18/24.
//

import SwiftUI

struct MacronutrientView: View {
    @ObservedObject var summaryViewModel: DailySummaryViewModel
    @EnvironmentObject var dailyLogManager: DailyLogManager
    
    var body: some View {
        VStack {
            HStack() {
                MacronutrientRingView(isSelected: summaryViewModel.selectedMacro == .calories , label: "Calories", consumed: dailyLogManager.totalCaloriesConsumed , goal: dailyLogManager.calorieGoal, color: AppTheme.sageGreen).onTapGesture {
                    withAnimation(.bouncy){
                        summaryViewModel.selectedMacro = .calories
                    }
                }
                MacronutrientRingView(isSelected: summaryViewModel.selectedMacro == .protein, label: "Protein", consumed: dailyLogManager.totalGramsProtein, goal: dailyLogManager.proteinGoal, color: AppTheme.lavender).onTapGesture {
                    withAnimation(.bouncy) {
                        summaryViewModel.selectedMacro = .protein
                    }
                }
            }.padding()

            HStack{
                MacronutrientRingView(isSelected: summaryViewModel.selectedMacro == .carbs, label: "Carbs", consumed: dailyLogManager.totalGramsCarbs, goal: dailyLogManager.carbGoal, color: AppTheme.goldenrod).onTapGesture {
                    withAnimation(.bouncy) {
                        summaryViewModel.selectedMacro = .carbs
                    }
                }
                MacronutrientRingView(isSelected: summaryViewModel.selectedMacro == .fats, label: "Fats", consumed: dailyLogManager.totalGramsFats, goal: dailyLogManager.fatGoal, color: AppTheme.carrot).onTapGesture {
                    withAnimation(.bouncy) {
                        summaryViewModel.selectedMacro = .fats
                    }
                }
            }.padding()
        }
    }
}

struct MacronutrientRingView: View {
    var isSelected: Bool
    var label: String
    var consumed: Double
    var goal: Double
    var color: Color
    
    var body: some View {
        VStack {
            RingView(consumed: consumed, goal: goal, color: isSelected ? AppTheme.milk : color, isSelected: isSelected).shadow(radius: 4, x: 2, y: 4)
            Spacer()
            // Display the label and the current number/goal below the ring
            VStack(spacing: 10) {
                Text(label)
                    .font(AppTheme.standardBookBody)
                    .foregroundStyle(AppTheme.textColor)
                MacroLabel.shared.labelView(macro: label.lowercased(), value: Text("\(consumed, specifier: "%.1f")/\(goal, specifier: "%.1f")g"))
            }
                
        }.padding()
        .background(isSelected ? color.opacity(0.5) : .clear)
        .clipShape(.rect(cornerRadius: 25))
    }
}

struct RingView: View {
    var consumed: Double
    var goal: Double
    var color: Color
    var isSelected: Bool
    
    var percentageFilled: String {
        let percentage = (consumed / goal) * 100
        return String(format: "%.1f%%", percentage)
    }
    
    var body: some View {
        ZStack {
            // Base circle
            Circle()
                .stroke(lineWidth: 8)
                .opacity(0.5)
                .foregroundColor(AppTheme.dynamicGray)
            
            // Filled portion of the circle
            Circle()
                .trim(from: 0, to: min(CGFloat(consumed / goal), 1))
                .stroke(color, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .rotationEffect(.degrees(-90))
            
            // Display the percentage in the middle of the ring
            Text(percentageFilled)
                .font(.caption)
                .fontWeight(.bold)
        }
        .frame(width: 80, height: 80)
        .overlay(
            // Overlay for the portion exceeding 100%
            GeometryReader { geometry in
                let radius = geometry.size.width / 2
                let excessPercentage = min(max((consumed - goal) / goal, 0), 1)
                
                // Calculate start and end angles for the excess portion
                let startAngle = Angle(degrees: 360 * (1 - excessPercentage) - 90)
                let endAngle = Angle(degrees: 360 * -90)
                if consumed > goal {
                    Path { path in
                        path.addArc(center: CGPoint(x: radius, y: radius), radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
                    }
                    .trim(from: 0, to: 1)
                    .stroke(style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [5]))
                    .foregroundColor(AppTheme.grayExtra)
                }
            }
        )
    }
}

