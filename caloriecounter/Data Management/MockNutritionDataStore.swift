//
//  MockNutritionDataStore.swift
//  caloriecounter
//
//  Created by Sam Roman on 5/5/24.
//

import Foundation
import CoreData

struct SimpleNutritionEntry: Identifiable, Hashable {
    let id: UUID
    let name: String
    let calories: Double
    let protein: Double
    let carbs: Double
    let fats: Double
}

// Mock NutritionDataStore for preview purposes
class MockNutritionDataStore: NutritionDataStore {

    
    func fetchEntries(favorites: Bool, nameSearch: String? = nil) -> [SimpleNutritionEntry] {
        // Return dummy entries based on the nameSearch parameter
        let dummyEntries = [
            SimpleNutritionEntry(id: UUID(), name: "Apple", calories: 95, protein: 0.5, carbs: 25, fats: 0.3),
            SimpleNutritionEntry(id: UUID(), name: "Banana", calories: 105, protein: 1.3, carbs: 27, fats: 0.3),
            SimpleNutritionEntry(id: UUID(), name: "Carrot", calories: 25, protein: 0.6, carbs: 6, fats: 0.1),
            SimpleNutritionEntry(id: UUID(), name: "Date", calories: 20, protein: 0.2, carbs: 5, fats: 0.03)
        ]
        
        if let nameSearch = nameSearch, !nameSearch.isEmpty {
            return dummyEntries.filter { $0.name.lowercased().contains(nameSearch.lowercased()) }
        }
        return dummyEntries
    }
}
