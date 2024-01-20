//
//  MacronutrientView.swift
//  caloriecounter
//
//  Created by Sam Roman on 1/18/24.
//

import SwiftUI

struct MacronutrientView: View {
    // Example macronutrient data
    let macronutrients = [("Carbs", 0.6), ("Protein", 0.2), ("Fat", 0.2)]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(macronutrients, id: \.0) { nutrient in
                HStack {
                    Text(nutrient.0)
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .frame(width: geometry.size.width, height: 20)
                                .opacity(0.3)
                                .foregroundColor(AppTheme.grayDark)
                            
                            Rectangle()
                                .frame(width: min(CGFloat(nutrient.1) * geometry.size.width, geometry.size.width), height: 20)
                                .foregroundColor(AppTheme.carrot)
                                .animation(.linear, value: nutrient.1)
                        }
                    }
                    .frame(height: 20)
                    Text("\(Int(nutrient.1 * 100))%")
                }
            }
        }
        .padding()
        .background(AppTheme.grayExtra)
        .cornerRadius(15)
        .padding(.horizontal)
        .shadow(radius: 5)
    }
}


#Preview {
    MacronutrientView()
}
