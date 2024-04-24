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
                HStack{
                    Text("*")
                        .font(.title2)
                        .foregroundStyle(AppTheme.sageGreen)
                    Text("\(entry.calories, specifier: "%.1f") cal")
                }
                HStack{
                    Text("*")
                        .font(.title2)
                        .foregroundStyle(AppTheme.softPurple)
                    Text("\(entry.protein, specifier: "%.1f")g prot")
                }
                HStack{
                    Text("*")
                        .font(.title2)
                        .foregroundStyle(AppTheme.goldenrod)
                    Text("\(entry.carbs, specifier: "%.1f")g carbs")
                }
                HStack{
                    Text("*")
                        .font(.title2)
                        .foregroundStyle(AppTheme.carrot)
                    Text("\(entry.fat, specifier: "%.1f")g fats")
                }
            }
            .font(.caption)
            .foregroundColor(.primary)
            Divider().background(AppTheme.textColor)

        }
        .padding(.vertical, 4)
        .padding(.horizontal)
    }
}

//#Preview {
//    NutritionEntryView()
//}
