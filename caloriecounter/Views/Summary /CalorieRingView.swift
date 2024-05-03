//
//  MacroRingView.swift
//  caloriecounter
//
//  Created by Sam Roman on 11/24/23.
//

import SwiftUI

struct MacroRingView: View {
    var percentages: (Double,Double,Double,Double)
    var totalCaloriesConsumed: Double {
        percentages.0 + percentages.1 + percentages.2 + percentages.3
    }
    
    func mealColor(mealType: MealType) -> Color {
           switch mealType {
           case .breakfast:
               return AppTheme.peach
           case .lunch:
               return AppTheme.dustyRose
           case .dinner:
               return AppTheme.dustyBlue
           case .snack:
               return AppTheme.teal
           case .water:
               return .black
           }
       }
    
    var body: some View {
        ZStack {
            // Breakfast
            if percentages.0 > 0 {
                RingSegmentView(color: mealColor(mealType: .breakfast), startPercentage: 0, endPercentage: percentages.0)
            }
            
            // Lunch
            if percentages.1 > 0 {
                RingSegmentView(color: mealColor(mealType: .lunch), startPercentage: percentages.0, endPercentage: percentages.0 + percentages.1)
            }
            
            // Dinner
            if percentages.2 > 0 {
                RingSegmentView(color: mealColor(mealType: .dinner), startPercentage: percentages.0 + percentages.1, endPercentage: percentages.0 + percentages.1 + percentages.2)
            }
            
            // Snacks
            if percentages.3 > 0 {
                RingSegmentView(color: mealColor(mealType: .snack), startPercentage: percentages.0 + percentages.1 + percentages.2, endPercentage: totalCaloriesConsumed)
            }
            
            // Calories left to consume
            if totalCaloriesConsumed < 1.0 {
                RingSegmentView(color: AppTheme.grayDark, startPercentage: totalCaloriesConsumed, endPercentage: 1.0)
            }
        }
        .padding()
    }
}

struct RingSegmentView: View {
    var color: Color
    var startPercentage: Double
    var endPercentage: Double
    var gapAngle: Double = 0.5 // degrees of separation between segments
    
    var body: some View {
        GeometryReader { geometry in
            let width: CGFloat = min(geometry.size.width, geometry.size.height)
            let center = CGPoint(x: width / 2, y: width / 2)
            let radius = width / 2
            
            // Adjust the start and end angles to create gaps
            let startAngle = Angle(degrees: 360 * startPercentage - 90 + gapAngle/2)
            let endAngle = Angle(degrees: 360 * endPercentage - 90 - gapAngle/2)
            
            Path { path in
                path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
            }
            .stroke(color, style: StrokeStyle(lineWidth: 70, lineCap: .butt))
        }
    }
}


