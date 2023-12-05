//
//  NutrientProgressView.swift
//  caloriecounter
//
//  Created by Sam Roman on 11/24/23.
//

import SwiftUI

struct NutrientProgressView: View {
    // Dummy data for progress
    let progress: (calories: Double, protein: Double, carbs: Double, fat: Double) = (798.57 / 2200, 45.15 / 65, 78.96 / 325, 21.39 / 90)
    
    var body: some View {
        ZStack {
            CircleProgressView(progress: progress.calories, thickness: 20, color: Color.green)
            CircleProgressView(progress: progress.protein, thickness: 15, color: Color.red)
                .padding(20) // padding should be equal to the thickness of the outer circle
            CircleProgressView(progress: progress.carbs, thickness: 10, color: Color.blue)
                .padding(35) // sum of thicknesses of outer and this circle
            CircleProgressView(progress: progress.fat, thickness: 5, color: Color.yellow)
                .padding(45) // sum of thicknesses of all outer circles
        }
        .frame(width: 150, height: 150) // Adjust the frame size as needed
    }
}

struct CircleProgressView: View {
    var progress: Double
    var thickness: CGFloat
    var color: Color
    
    var body: some View {
        Circle()
            .stroke(lineWidth: thickness)
            .opacity(0.3)
            .foregroundColor(Color.gray)
            .overlay(
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(style: StrokeStyle(lineWidth: thickness, lineCap: .round))
                    .foregroundColor(color)
                    .rotationEffect(Angle(degrees: 270))
            )
    }
}
//
//#Preview {
//    NutrientProgressView()
//}
