//
//  MealSelectionViewModel.swift
//  caloriecounter
//
//  Created by Sam Roman on 11/25/23.
//

import Foundation
import CoreData
//
class MealSelectionViewModel: ObservableObject {
    @Published var currentMealType: String = ""
    @Published var showingAddItemForm: Bool = false
    @Published var selectedEntry: NutritionEntry?
    private var dataStore: NutritionDataStore
    private var viewContext: NSManagedObjectContext

    init(dataStore: NutritionDataStore, context: NSManagedObjectContext) {
        self.dataStore = dataStore
        self.viewContext = context
    }

    func selectMealType(_ mealType: String) {
        currentMealType = mealType
        showingAddItemForm = true
    }
    
    func selectEntry(_ entry: NutritionEntry) {
        selectedEntry = entry
    }
    
    func deleteEntry(_ entry: NutritionEntry) {
        dataStore.deleteEntry(entry)
    }
    
    // Add other methods as needed for updating entries, etc.
}
