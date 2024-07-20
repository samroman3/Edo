//
//  WaveDisplayView.swift
//  caloriecounter
//
//  Created by Sam Roman on 7/20/24.
//

import SwiftUI

struct WaveDisplayView: View {
    @EnvironmentObject var dailyLogManager: DailyLogManager
    
    var body: some View {
        VStack(spacing: 20) {
            ForEach([MacroType.calories, .protein, .carbs, .fats], id: \.self) { macroType in
                WaveView(macroType: macroType)
            }
        }
        .padding()
    }
}

struct WaveView: View {
    let macroType: MacroType
    @EnvironmentObject var dailyLogManager: DailyLogManager
    
    @State private var waveOffset = Angle(degrees: 0)
    
    var body: some View {
        VStack {
            Text(macroType.rawValue.capitalized)
                .font(AppTheme.standardBookBody)
                .foregroundColor(AppTheme.textColor)
            
            GeometryReader { geometry in
                ZStack {
                    Rectangle()
                        .fill(AppTheme.dynamicGray.opacity(0.3))
                        .frame(height: 100)
                }.background(
                    AnyView(
                        Wave(offSet: Angle(degrees: waveOffset.degrees), percent: self.percentage())
                            .fill(self.color())
                             .clipShape(Rectangle())
                             .animation(.linear(duration: 1.5).repeatForever(autoreverses: false))
                     ))
            }
            .frame(height: 100)
        }
    }
    
    private func percentage() -> CGFloat {
        switch macroType {
        case .calories:
            return CGFloat(dailyLogManager.totalCaloriesConsumed / dailyLogManager.calorieGoal)
        case .protein:
            return CGFloat(dailyLogManager.totalGramsProtein / dailyLogManager.proteinGoal)
        case .carbs:
            return CGFloat(dailyLogManager.totalGramsCarbs / dailyLogManager.carbGoal)
        case .fats:
            return CGFloat(dailyLogManager.totalGramsFats / dailyLogManager.fatGoal)
        }
    }
    
    private func color() -> Color {
        switch macroType {
        case .calories:
            return AppTheme.sageGreen
        case .protein:
            return AppTheme.lavender
        case .carbs:
            return AppTheme.goldenrod
        case .fats:
            return AppTheme.carrot
        }
    }
}
