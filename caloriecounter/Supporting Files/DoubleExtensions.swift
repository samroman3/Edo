//
//  DoubleExtensions.swift
//  caloriecounter
//
//  Created by Sam Roman on 12/8/23.
//

import Foundation

extension Double {
    func formattedAsString() -> String {
        return String(format: "%.2f", self)
    }
    
    func formattedAsPrettyString() -> String {
        return String(format: "%.1f", self)
    }
}
