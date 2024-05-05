//
//  GoalSelectionView.swift
//  caloriecounter
//
//  Created by Sam Roman on 12/28/23.
//

import SwiftUI

struct GoalSelectionView: View {
    enum Goal: String, CaseIterable {
        case loseWeight = "Lose Weight"
        case maintainWeight = "Maintain Weight"
        case gainWeight = "Gain Weight"
        case buildMuscle = "Build Muscle"
        case enhancePerformance = "Enhance Performance"
        case custom = "Custom Goal"
        var description: String {
            switch self {
                case .loseWeight:
                    return "For users aiming to reduce their body weight."
                case .maintainWeight:
                    return "Ideal for users who want to keep their current weight."
                case .gainWeight:
                    return "Suitable for those looking to increase their weight."
                case .buildMuscle:
                    return "Targeted towards users interested in muscle gain."
                case .enhancePerformance:
                    return "For athletes or training for specific sports."
            case .custom:
                return ""
            }
        }
    }
    
    @Binding var selectedGoal: Goal?
    
    var body: some View {
           ScrollViewReader { scrollProxy in
               ScrollView(.horizontal, showsIndicators: false) {
                   Section {
                       HStack {
                           ForEach(Goal.allCases, id: \.self) { goal in
                               GoalIconView(goal: goal, isSelected: Binding(
                                   get: { self.selectedGoal == goal },
                                   set: { if $0 { self.selectedGoal = goal } }
                               ))
                               .id(goal)  // Assign an ID to each goal for the ScrollViewReader
                               .onTapGesture {
                                   withAnimation {
                                       self.selectedGoal = goal
                                       HapticFeedbackProvider.impact()
                                   }
                               }
                           }
                       }
                   }
                   .padding()
               }
               .background(Material.ultraThick)
               .onChange(of: selectedGoal) { newValue in
                               if newValue == .custom {
                                   withAnimation {
                                       scrollProxy.scrollTo(Goal.custom, anchor: .trailing)
                                   }
                               }
                           }
           }
       }
   }

struct GoalIconView: View {
    let goal: GoalSelectionView.Goal
    @Binding var isSelected: Bool

    var body: some View {
        VStack(spacing: 5) {
            Spacer()
            Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                .font(.largeTitle)
                .foregroundColor(isSelected ? AppTheme.reverse : .gray)
            Text(goal.rawValue)
                .font(.caption)
                .multilineTextAlignment(.center)
                .lineLimit(4, reservesSpace: true)
                .foregroundStyle(isSelected ? AppTheme.reverse : .gray)
        }
        .frame(width: 70, height: 70)
        .padding()
        .background(isSelected ? AppTheme.textColor : .clear)
        .cornerRadius(5)
        .onTapGesture {
            self.isSelected.toggle()
        }
    }
}
