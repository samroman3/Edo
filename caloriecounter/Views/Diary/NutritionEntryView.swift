//
//  NutritionEntryView.swift
//  caloriecounter
//
//  Created by Sam Roman on 11/25/23.
//

import SwiftUI
import UIKit

struct NutritionEntryView: View {
    let entry: NutritionEntry

    private var primaryMealImage: UIImage? {
        NutritionDataStore.storedImageData(for: entry).first.flatMap { UIImage(data: $0) }
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top, spacing: 12) {
                if let primaryMealImage {
                    Image(uiImage: primaryMealImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 64, height: 64)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(AppTheme.grayLight.opacity(0.6), lineWidth: 1)
                        )
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(entry.name)
                        .font(AppTheme.standardBookBody)
                    HStack {
                        HStack{
                            Text("*")
                                .font(.title2)
                                .foregroundStyle(AppTheme.sageGreen)
                            Text("\(entry.calories, specifier: "%.1f")g")
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
                }
            }
            Divider().background(AppTheme.textColor)

        }
        .padding(.vertical, 4)
        .padding(.horizontal)
    }
}

//#Preview {
//    NutritionEntryView()
//}
