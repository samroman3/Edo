//
//  Item.swift
//  caloriecounter
//
//  Created by Sam Roman on 11/24/23.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
