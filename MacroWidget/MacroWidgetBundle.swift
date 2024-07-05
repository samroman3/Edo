//
//  MacroWidgetBundle.swift
//  MacroWidget
//
//  Created by Sam Roman on 7/4/24.
//

import WidgetKit
import SwiftUI

@main
struct MacroWidgetBundle: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        MacronutrientWidget()
        CaloriesWidget()
        ProteinWidget()
        CarbsWidget()
        FatsWidget()
        WaterIntakeWidget()
    }
}
