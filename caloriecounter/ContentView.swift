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
    
    

    var body: some View {
        MainView()
        .environmentObject(DateSelectionManager(context: viewContext))
        .environmentObject(MealSelectionViewModel(dataStore: NutritionDataStore(context: viewContext), context: viewContext))
        .environmentObject(NutritionDataStore(context: viewContext))
        .environmentObject(AppState.shared)
    }
}






//#Preview {
//    ContentView()
//        .modelContainer(for: Item.self, inMemory: true)
//}
