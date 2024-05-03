//
//  MacronutrientView.swift
//  caloriecounter
//
//  Created by Sam Roman on 1/18/24.
//

import SwiftUI

struct MacronutrientView: View {
    @State var carbGoal: Double
    @State var fatGoal: Double
    @State var proteinGoal: Double
    @State var calorieGoal: Double
    @State var macros: (calories: Double, carbs: Double, protein: Double, fat: Double)
    @ObservedObject var summaryViewModel: DailySummaryViewModel
    
    var body: some View {
        VStack {
            HStack() {
                MacronutrientRingView(isSelected: summaryViewModel.selectedMacro == .calories , label: "Calories", consumed: macros.calories , goal: calorieGoal, color: AppTheme.sageGreen).onTapGesture {
                    withAnimation(.bouncy){
                        summaryViewModel.selectedMacro = .calories
                    }
                }
                MacronutrientRingView(isSelected: summaryViewModel.selectedMacro == .protein, label: "Protein", consumed: macros.protein, goal: proteinGoal, color: AppTheme.lavender).onTapGesture {
                    withAnimation(.bouncy) {
                        summaryViewModel.selectedMacro = .protein
                    }
                }
            }.padding()

            HStack{
                MacronutrientRingView(isSelected: summaryViewModel.selectedMacro == .carbs, label: "Carbs", consumed: macros.carbs, goal: carbGoal, color: AppTheme.goldenrod).onTapGesture {
                    withAnimation(.bouncy) {
                        summaryViewModel.selectedMacro = .carbs
                    }
                }
                MacronutrientRingView(isSelected: summaryViewModel.selectedMacro == .fats, label: "Fats", consumed: macros.fat, goal: fatGoal, color: AppTheme.carrot).onTapGesture {
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
            RingView(consumed: consumed, goal: goal, color: isSelected ? AppTheme.milk : color, isSelected: isSelected)
            // Display the label and the current number/goal below the ring
            VStack {
                Text(label)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(AppTheme.textColor)
                MacroLabel.shared.labelView(macro: label.lowercased(), value: Text("\(consumed, specifier: "%.1f")/\(goal, specifier: "%.1f")g").foregroundStyle(AppTheme.textColor))
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
            return String(format: "%.1f%%", min(percentage, 100))
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 8)
                .opacity(0.5)
                .foregroundColor(AppTheme.grayDark)
            
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
    }
}
//
//#Preview {
//    MacronutrientView()
//}
