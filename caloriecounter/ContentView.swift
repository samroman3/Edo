//
//  ContentView.swift
//  caloriecounter
//
//  Created by Sam Roman on 11/24/23.
//

import SwiftUI
//import GoogleMobileAds

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var dataStore: NutritionDataStore
    @StateObject private var purchaseManager = PurchaseManager.shared

    var body: some View {
        VStack {
            MainView()
                .environmentObject(MealSelectionViewModel(dataStore: dataStore, context: viewContext))
            if !purchaseManager.isAdRemoved {
                EmptyView()
                    .frame(height: 50)
            }
        }
    }
}
