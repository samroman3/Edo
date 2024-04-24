//
//  ProgressRingView.swift
//  caloriecounter
//
//  Created by Sam Roman on 11/24/23.
//

import SwiftUI

struct CalorieRingView: View {
    var breakfastPercentage: Double
    var lunchPercentage: Double
    var dinnerPercentage: Double
    var snacksPercentage: Double
    var totalCaloriesConsumed: Double {
        breakfastPercentage + lunchPercentage + dinnerPercentage + snacksPercentage
    }
    
    var body: some View {
        ZStack {
            // Breakfast
            if breakfastPercentage > 0 {
                RingSegmentView(color: AppTheme.carrot, startPercentage: 0, endPercentage: breakfastPercentage)
            }
            
            // Lunch
            if lunchPercentage > 0 {
                RingSegmentView(color: AppTheme.lavender, startPercentage: breakfastPercentage, endPercentage: breakfastPercentage + lunchPercentage)
            }
            
            // Dinner
            if dinnerPercentage > 0 {
                RingSegmentView(color: AppTheme.skyBlue, startPercentage: breakfastPercentage + lunchPercentage, endPercentage: breakfastPercentage + lunchPercentage + dinnerPercentage)
            }
            
            // Snacks
            if snacksPercentage > 0 {
                RingSegmentView(color: AppTheme.teal, startPercentage: breakfastPercentage + lunchPercentage + dinnerPercentage, endPercentage: totalCaloriesConsumed)
            }
            
            // Calories left to consume
            if totalCaloriesConsumed < 1.0 {
                RingSegmentView(color: AppTheme.grayDark, startPercentage: totalCaloriesConsumed, endPercentage: 1.0)
            }
        }
        .frame(width: 150, height: 150) 
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


