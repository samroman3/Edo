//
//  DailySummaryViewModel.swift
//  caloriecounter
//
//  Created by Sam Roman on 2/3/24.
//

import SwiftUI

class DailySummaryViewModel: ObservableObject {
    @Published var breakfastCalPercentage = 0.0
    @Published var lunchCalPercentage = 0.0
    @Published var dinnerCalPercentage = 0.0
    @Published var snacksCalPercentage = 0.0
    
    @Published var breakfastProteinPercentage = 0.0
    @Published var lunchProteinPercentage = 0.0
    @Published var dinnerProteinPercentage = 0.0
    @Published var snacksProteinPercentage = 0.0
    
    @Published var breakfastCarbsPercentage = 0.0
    @Published var lunchCarbsPercentage = 0.0
    @Published var dinnerCarbsPercentage = 0.0
    @Published var snacksCarbsPercentage = 0.0
    
    @Published var breakfastFatsPercentage = 0.0
    @Published var lunchFatsPercentage = 0.0
    @Published var dinnerFatsPercentage = 0.0
    @Published var snacksFatsPercentage = 0.0
    
    @Published var totalCaloriesConsumed = 0.0
    @Published var calorieGoal = 1900.0

    @Published var selectedMacro: MacroType = .calories
    
    private var dailyLogManager: DailyLogManager

    init(dailyLogManager: DailyLogManager) {
        self.dailyLogManager = dailyLogManager
        refreshViewData()
    }

    func refreshViewData() {
        
        totalCaloriesConsumed = dailyLogManager.totalCaloriesConsumed
        calorieGoal = dailyLogManager.calorieGoal
        
    }
}
