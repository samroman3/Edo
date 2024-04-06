//
//  DailySummaryViewModel.swift
//  caloriecounter
//
//  Created by Sam Roman on 2/3/24.
//

import SwiftUI

class DailySummaryViewModel: ObservableObject {
    @Published var breakfastPercentage = 0.0
    @Published var lunchPercentage = 0.0
    @Published var dinnerPercentage = 0.0
    @Published var snacksPercentage = 0.0
    @Published var totalCaloriesConsumed = 0.0
    @Published var calorieGoal = 1900.0

    private var dailyLogManager: DailyLogManager

    init(dailyLogManager: DailyLogManager) {
        self.dailyLogManager = dailyLogManager
        refreshViewData()
    }

    func refreshViewData() {
        breakfastPercentage = dailyLogManager.breakfastPercentage
        lunchPercentage = dailyLogManager.lunchPercentage
        dinnerPercentage = dailyLogManager.dinnerPercentage
        snacksPercentage = dailyLogManager.snackPercentage
        totalCaloriesConsumed = dailyLogManager.totalCaloriesConsumed
        calorieGoal = dailyLogManager.calorieGoal
    }
}
