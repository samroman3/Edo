//
//  DailySummaryViewModel.swift
//  caloriecounter
//
//  Created by Sam Roman on 2/3/24.
//

import SwiftUI

class DailySummaryViewModel: ObservableObject {

    @Published var selectedMacro: MacroType = .calories
    
    private var dailyLogManager: DailyLogManager

    init(dailyLogManager: DailyLogManager) {
        self.dailyLogManager = dailyLogManager
    }

}
