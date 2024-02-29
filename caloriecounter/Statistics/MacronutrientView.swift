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
            MacronutrientRingView(label: "Carbs", consumed: macros.carbs, goal: carbGoal, color: AppTheme.lavender)
            MacronutrientRingView(label: "Protein", consumed: macros.protein, goal: proteinGoal, color: AppTheme.lime)
            MacronutrientRingView(label: "Fat", consumed: macros.fat, goal: fatGoal, color: AppTheme.carrot)
        }
        .padding()
        .background(AppTheme.grayExtra)
        .cornerRadius(15)
        .shadow(radius: 5)
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
                    .font(.caption)
                Text("\(consumed, specifier: "%.1f")/\(goal, specifier: "%.1f")g")
                    .font(.caption)
            }
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
                .stroke(lineWidth: 10)
                .opacity(0.3)
                .foregroundColor(color)
            
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


//struct MacronutrientView: View {
//    
//    @EnvironmentObject private var dailyLogManager: DailyLogManager
//    
//    // Example macronutrient data
//    let macronutrients = [("Carbs", 0.6), ("Protein", 0.2), ("Fat", 0.2)]
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 10) {
//            ForEach(macronutrients, id: \.0) { nutrient in
//                HStack {
//                    Text(nutrient.0)
//                    GeometryReader { geometry in
//                        ZStack(alignment: .leading) {
//                            Rectangle()
//                                .frame(width: geometry.size.width, height: 20)
//                                .opacity(0.3)
//                                .foregroundColor(AppTheme.grayDark)
//                            
//                            Rectangle()
//                                .frame(width: min(CGFloat(nutrient.1) * geometry.size.width, geometry.size.width), height: 20)
//                                .foregroundColor(AppTheme.carrot)
//                                .animation(.linear, value: nutrient.1)
//                        }
//                    }
//                    .frame(height: 20)
//                    Text("\(Int(nutrient.1 * 100))%")
//                }
//            }
//        }
//        .padding()
//        .background(AppTheme.grayExtra)
//        .cornerRadius(15)
//        .padding(.horizontal)
//        .shadow(radius: 5)
//    }
//}
//
//
//#Preview {
//    MacronutrientView()
//}
