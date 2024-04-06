//
//  MealTypes.swift
//  caloriecounter
//
//  Created by Sam Roman on 11/26/23.
//

import Foundation

enum MealType: String, CaseIterable, Hashable {
    
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case snack = "Snacks"
    case water = "Water"
    
    var displayName: String {
            return self.rawValue
        }
}
