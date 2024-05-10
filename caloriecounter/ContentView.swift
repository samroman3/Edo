//
//  ContentView.swift
//  caloriecounter
//
//  Created by Sam Roman on 11/24/23.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var dataStore: NutritionDataStore
    
    var body: some View {
        MainView()
            .environmentObject(MealSelectionViewModel(dataStore: dataStore, context: viewContext))

    }
}
