//
//  BarDisplayView.swift
//  caloriecounter
//
//  Created by Sam Roman on 7/20/24.
//
import SwiftUI

struct BarDisplayView: View {
    @ObservedObject var summaryViewModel: DailySummaryViewModel
    @EnvironmentObject var dailyLogManager: DailyLogManager
    
    var body: some View {
        VStack(spacing: 20) {
            ForEach([MacroType.calories, .protein, .carbs, .fats], id: \.self) { macroType in
                MacroBarView(isSelected: summaryViewModel.selectedMacro == macroType, macroType: macroType)
                    .onTapGesture {
                        withAnimation(.bouncy) {
                            summaryViewModel.selectedMacro = macroType
                        }
                    }
            }
        }
        .padding()
    }
}

struct MacroBarView: View {
    var isSelected: Bool
    let macroType: MacroType
    @EnvironmentObject var dailyLogManager: DailyLogManager
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(macroType.rawValue.capitalized)
                    .font(AppTheme.standardBookBody)
                    .foregroundColor(AppTheme.textColor)
                Spacer()
                macroConsumed()
                    .font(AppTheme.standardBookBody)
                    .foregroundColor(AppTheme.textColor)
            }
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .frame(width: geometry.size.width, height: 20)
                        .opacity(0.3)
                        .foregroundColor(AppTheme.dynamicGray)
                    Rectangle()
                        .frame(width: min(CGFloat(self.percentage()) * geometry.size.width, geometry.size.width), height: 20)
                        .foregroundColor(self.color())
                        .animation(.linear)
                    Text("\(Int(self.percentage() * 100))%")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.textColor)
                        .frame(width: geometry.size.width, height: 20, alignment: .leading)
                        .padding(.leading, max(min(CGFloat(self.percentage()) * geometry.size.width - 30, geometry.size.width - 100), 5))
                        .animation(.none)
                }
            }
            .frame(height: 20)
            .background(isSelected ? self.color().opacity(0.5) : .clear)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            
            if isSelected {
                VStack(alignment: .leading) {
                    ForEach(MealType.allCases.filter { $0 != .water }, id: \.self) { mealType in
                        MealBarView(macroType: macroType, mealType: mealType)
                    }
                }
            }
        }
        .padding(.vertical, 10)
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
    
    private func macroConsumed() -> Text {
        switch macroType {
        case .calories:
            return Text("\(Int(dailyLogManager.totalCaloriesConsumed))g / \(Int(dailyLogManager.calorieGoal))g")
        case .protein:
            return Text("\(Int(dailyLogManager.totalGramsProtein))g / \(Int(dailyLogManager.proteinGoal))g")
        case .carbs:
            return Text("\(Int(dailyLogManager.totalGramsCarbs))g / \(Int(dailyLogManager.carbGoal))g")
        case .fats:
            return Text("\(Int(dailyLogManager.totalGramsFats))g / \(Int(dailyLogManager.fatGoal))g")
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

struct MealBarView: View {
    let macroType: MacroType
    let mealType: MealType
    @EnvironmentObject var dailyLogManager: DailyLogManager
    
    private let labelWidth: CGFloat = 80 // Fixed width for meal type labels

    var body: some View {
           HStack {
               Text(mealType.rawValue.capitalized)
                   .font(AppTheme.standardBookBody)
                   .foregroundColor(AppTheme.textColor)
                   .frame(width: labelWidth, alignment: .leading) // Set fixed width for labels
               GeometryReader { geometry in
                   ZStack(alignment: .leading) {
                       Rectangle()
                           .frame(width: geometry.size.width, height: 20)
                           .opacity(0.3)
                           .foregroundColor(AppTheme.dynamicGray)
                       Rectangle()
                           .frame(width: min(CGFloat(self.percentage()) * geometry.size.width, geometry.size.width), height: 20)
                           .foregroundColor(self.color())
                           .animation(.linear)
                           // Text outside the bar if the percentage is less than 50%
                           Text("\(self.macroValue())")
                               .font(.caption)
                               .fontWeight(.bold)
                               .foregroundColor(AppTheme.textColor)
                               .frame(width: geometry.size.width, height: 20, alignment: .leading)
                               .padding(.leading, 5)
                               .animation(.none)
                   }
               }
               .frame(height: 20)
               .clipShape(RoundedRectangle(cornerRadius: 10))
           }
       }
    
    private func percentage() -> CGFloat {
        switch macroType {
        case .calories:
            return CGFloat(dailyLogManager.calories(for: mealType) / dailyLogManager.calorieGoal)
        case .protein:
            return CGFloat(dailyLogManager.protein(for: mealType) / dailyLogManager.proteinGoal)
        case .carbs:
            return CGFloat(dailyLogManager.carbs(for: mealType) / dailyLogManager.carbGoal)
        case .fats:
            return CGFloat(dailyLogManager.fats(for: mealType) / dailyLogManager.fatGoal)
        }
    }
    
    private func macroValue() -> String {
        switch macroType {
        case .calories:
            return "\(Int(dailyLogManager.calories(for: mealType))) Cal"
        case .protein:
            return "\(Int(dailyLogManager.protein(for: mealType)))g"
        case .carbs:
            return "\(Int(dailyLogManager.carbs(for: mealType)))g"
        case .fats:
            return "\(Int(dailyLogManager.fats(for: mealType)))g"
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
