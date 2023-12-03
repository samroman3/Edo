//
//  MealCardView.swift
//  caloriecounter
//
//  Created by Sam Roman on 11/24/23.

import SwiftUI
import CoreData

struct MealCardView: View {
    let mealType: String
    let entries: [NutritionEntry]
    @Binding var isExpanded: Bool
    var onAddTapped: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(mealType)
                    .font(.largeTitle)
                    .fontWeight(.light)
                    .foregroundStyle(AppTheme.lime)
                Spacer()
                Button(action: onAddTapped) {
                    Image(systemName: "plus.circle")
                        .resizable()
                        .tint(Color.blue)
                        .foregroundStyle(AppTheme.lime)
                        .frame(width: 30, height: 30)
                }
                .padding(.vertical)
            }
            .padding(.horizontal)
            .contentShape(Rectangle())
            if isExpanded {
                ForEach(entries, id: \.self) { entry in
                    HStack {
                        NutritionEntryView(entry: entry)
                    }
                    .padding(.horizontal)
                }
            }
        }
    }


}

struct ChevronView: View {
    var isExpanded: Binding<Bool>
    var totalCalories: Int
    
    var body: some View {
        VStack {
            Image(systemName: isExpanded.wrappedValue ? "chevron.up" : "chevron.down")
                .foregroundStyle(AppTheme.lime)
            Text("\(totalCalories) calories")
                .font(.caption)
                .foregroundStyle(AppTheme.lime)
        }
        .onTapGesture {
            withAnimation {
                isExpanded.wrappedValue.toggle()
            }
        }
    }
}



//#Preview {
//    MealEntryView()
//}
