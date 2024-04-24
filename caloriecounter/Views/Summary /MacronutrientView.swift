//
//  MacronutrientView.swift
//  caloriecounter
//
//  Created by Sam Roman on 1/18/24.
//

import SwiftUI

struct MacronutrientView: View {
    var carbGoal: Double
    var fatGoal: Double
    var proteinGoal: Double
    var macros: (carbs: Double, protein: Double, fat: Double)
    
    var body: some View {
        HStack(spacing: 20) {
            MacronutrientRingView(label: "Carbs", consumed: macros.carbs, goal: carbGoal, color: AppTheme.softPurple)
            MacronutrientRingView(label: "Protein", consumed: macros.protein, goal: proteinGoal, color: AppTheme.goldenrod)
            MacronutrientRingView(label: "Fat", consumed: macros.fat, goal: fatGoal, color: AppTheme.carrot)
        }
        .padding()
        .cornerRadius(15)
    }
}

struct MacronutrientRingView: View {
    var label: String
    var consumed: Double
    var goal: Double
    var color: Color
    
    var body: some View {
        VStack {
            RingView(consumed: consumed, goal: goal, color: color)
            // Display the label and the current number/goal below the ring
            VStack {
                Text(label)
                    .font(.title3)
                Text("\(consumed, specifier: "%.1f")/\(goal, specifier: "%.1f")g")
                    .font(.caption)
            }.padding(.horizontal)
                
        }
    }
}

struct RingView: View {
    var consumed: Double
    var goal: Double
    var color: Color
    
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
        }
        .frame(width: 80, height: 80)
    }
}
//
//#Preview {
//    MacronutrientView()
//}
