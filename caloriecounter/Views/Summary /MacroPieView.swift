//
//  MacroPieView.swift
//  caloriecounter
//
//  Created by Sam Roman on 11/24/23.
//
import SwiftUI

struct MacroPieView: View {
    var percentages: (Double, Double, Double, Double)
    var totalCaloriesConsumed: Double {
        percentages.0 + percentages.1 + percentages.2 + percentages.3
    }
    
    var overPercentage: Double {
        max(totalCaloriesConsumed - 1.0, 0)
    }

    func mealColor(mealType: MealType) -> Color {
        switch mealType {
        case .breakfast:
            return AppTheme.lime
        case .lunch:
            return .mint
        case .dinner:
            return .indigo
        case .snack:
            return .pink
        case .water:
            return .black
        }
    }
    
    var body: some View {
        VStack {
            ZStack {
                // Breakfast
                if percentages.0 > 0 {
                    PieSegmentView(color: mealColor(mealType: .breakfast), startPercentage: 0, endPercentage: min(percentages.0, 1.0))
                }
                
                // Lunch
                if percentages.1 > 0 {
                    PieSegmentView(color: mealColor(mealType: .lunch), startPercentage: percentages.0, endPercentage: min(percentages.0 + percentages.1, 1.0))
                }
                
                // Dinner
                if percentages.2 > 0 {
                    PieSegmentView(color: mealColor(mealType: .dinner), startPercentage: percentages.0 + percentages.1, endPercentage: min(percentages.0 + percentages.1 + percentages.2, 1.0))
                }
                
                // Snacks
                if percentages.3 > 0 {
                    PieSegmentView(color: mealColor(mealType: .snack), startPercentage: percentages.0 + percentages.1 + percentages.2, endPercentage: min(totalCaloriesConsumed, 1.0))
                }
                
                // Left to consume
                if totalCaloriesConsumed < 1.0 {
                    PieSegmentView(color: AppTheme.grayDark, startPercentage: totalCaloriesConsumed, endPercentage: 1.0)
                }
                
                // Over percentage label
                if overPercentage > 0 {
                    let overPercentageString = String(format: "%.1f%% Over", overPercentage * 100)
                    Text(overPercentageString)
                        .font(.caption)
                        .foregroundColor(.white)
                }
            }
        }
    }
}

struct PieSegmentView: View {
    var color: Color
    var startPercentage: Double
    var endPercentage: Double

    var body: some View {
        GeometryReader { geometry in
            let width: CGFloat = min(geometry.size.width, geometry.size.height)
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let radius = width / 2

            // Adjust the start and end angles
            let startAngle = Angle(degrees: 360 * startPercentage - 90)
            let endAngle = Angle(degrees: 360 * endPercentage - 90)

            Path { path in
                path.move(to: center)
                path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
                path.closeSubpath()
            }
            .fill(color)
        }
    }
}
