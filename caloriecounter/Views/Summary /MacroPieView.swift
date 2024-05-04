//
//  MacroRingView.swift
//  caloriecounter
//
//  Created by Sam Roman on 11/24/23.
//

import SwiftUI

//struct MacroRingView: View {
//    var percentages: (Double,Double,Double,Double)
//    var totalCaloriesConsumed: Double {
//        percentages.0 + percentages.1 + percentages.2 + percentages.3
//    }
//    
//    func mealColor(mealType: MealType) -> Color {
//           switch mealType {
//           case .breakfast:
//               return AppTheme.peach
//           case .lunch:
//               return AppTheme.dustyRose
//           case .dinner:
//               return AppTheme.dustyBlue
//           case .snack:
//               return AppTheme.teal
//           case .water:
//               return .black
//           }
//       }
//    
//    var body: some View {
//        ZStack {
//            // Breakfast
//            if percentages.0 > 0 {
//                RingSegmentView(color: mealColor(mealType: .breakfast), startPercentage: 0, endPercentage: percentages.0)
//            }
//            
//            // Lunch
//            if percentages.1 > 0 {
//                RingSegmentView(color: mealColor(mealType: .lunch), startPercentage: percentages.0, endPercentage: percentages.0 + percentages.1)
//            }
//            
//            // Dinner
//            if percentages.2 > 0 {
//                RingSegmentView(color: mealColor(mealType: .dinner), startPercentage: percentages.0 + percentages.1, endPercentage: percentages.0 + percentages.1 + percentages.2)
//            }
//            
//            // Snacks
//            if percentages.3 > 0 {
//                RingSegmentView(color: mealColor(mealType: .snack), startPercentage: percentages.0 + percentages.1 + percentages.2, endPercentage: totalCaloriesConsumed)
//            }
//            
//            // Calories left to consume
//            if totalCaloriesConsumed < 1.0 {
//                RingSegmentView(color: AppTheme.grayDark, startPercentage: totalCaloriesConsumed, endPercentage: 1.0)
//            }
//        }
//    }
//}

struct MacroRingView: View {
    var percentages: (Double, Double, Double, Double)
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
                PieSegmentView(color: mealColor(mealType: .breakfast), startPercentage: 0, endPercentage: percentages.0)
            }

            // Lunch
            if percentages.1 > 0 {
                PieSegmentView(color: mealColor(mealType: .lunch), startPercentage: percentages.0, endPercentage: percentages.0 + percentages.1)
            }

            // Dinner
            if percentages.2 > 0 {
                PieSegmentView(color: mealColor(mealType: .dinner), startPercentage: percentages.0 + percentages.1, endPercentage: percentages.0 + percentages.1 + percentages.2)
            }

            // Snacks
            if percentages.3 > 0 {
                PieSegmentView(color: mealColor(mealType: .snack), startPercentage: percentages.0 + percentages.1 + percentages.2, endPercentage: totalCaloriesConsumed)
            }

            // Calories left to consume
            if totalCaloriesConsumed < 1.0 {
                PieSegmentView(color: AppTheme.grayDark, startPercentage: totalCaloriesConsumed, endPercentage: 1.0)
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

            // Calculate start and end angles
            let startAngle = Angle(degrees: 360 * startPercentage - 90)
            let endAngle = Angle(degrees: 360 * endPercentage - 90)

            // Draw the main pie segment
            Path { path in
                path.move(to: center)
                path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
                path.closeSubpath()
            }
            .fill(color)

            // Draw the excess portion if it exceeds 100%
            if endPercentage > 1.0 {
                let excessStartPercentage = min(startPercentage, 1.0)
                let excessEndPercentage = min(endPercentage, 1.0)

                let excessStartAngle = Angle(degrees: 360 * excessStartPercentage - 90)
                let excessEndAngle = Angle(degrees: 360 * excessEndPercentage - 90)

                Path { path in
                    path.move(to: center)
                    path.addArc(center: center, radius: radius, startAngle: excessStartAngle, endAngle: excessEndAngle, clockwise: false)
                    path.closeSubpath()
                }
                .fill(Color.red) // Adjust color for the excess portion
                .overlay(
                    // Overlay for the excess portion
                    Path { path in
                        path.move(to: CGPoint(x: center.x + CGFloat(cos(excessEndAngle.radians)) * radius, y: center.y + CGFloat(sin(excessEndAngle.radians)) * radius))
                        path.addLine(to: center)
                        path.addLine(to: CGPoint(x: center.x + CGFloat(cos(excessStartAngle.radians)) * radius, y: center.y + CGFloat(sin(excessStartAngle.radians)) * radius))
                    }
                    .stroke(style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [5]))
                    .foregroundColor(Color.gray)
                )
            }
        }
    }
}





