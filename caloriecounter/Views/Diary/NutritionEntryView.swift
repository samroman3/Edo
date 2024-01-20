//
//  NutritionEntryView.swift
//  caloriecounter
//
//  Created by Sam Roman on 11/25/23.
//

import SwiftUI

struct NutritionEntryView: View {
    let entry: NutritionEntry
    var body: some View {
        VStack(alignment: .leading) {
            Text(entry.name)
                .font(.headline)
            HStack {
                Text("Calories: \(entry.calories, specifier: "%.1f")")
                Text("Protein: \(entry.protein, specifier: "%.1f")g")
                Text("Carbs: \(entry.carbs, specifier: "%.1f")g")
                Text("Fat: \(entry.fat, specifier: "%.1f")g")
            }
            .font(.caption)
            .foregroundColor(.primary)
            Divider().background(AppTheme.lime)

        }
        .padding(.vertical, 4)
        .padding(.horizontal)
    }
}

//#Preview {
//    NutritionEntryView()
//}
