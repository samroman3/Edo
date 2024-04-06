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
        case improveFitness = "Improve Fitness"
        case buildMuscle = "Build Muscle"
        case enhancePerformance = "Enhance Performance"
        
        var description: String {
            switch self {
                case .loseWeight:
                    return "For users aiming to reduce their body weight."
                case .maintainWeight:
                    return "Ideal for users who want to keep their current weight."
                case .gainWeight:
                    return "Suitable for those looking to increase their weight."
                case .improveFitness:
                    return "Focus on general health improvements."
                case .buildMuscle:
                    return "Targeted towards users interested in muscle gain."
                case .enhancePerformance:
                    return "For athletes or training for specific sports."
            }
        }
    }
    
    @Binding var selectedGoal: Goal?
    
    var body: some View {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(Goal.allCases, id: \.self) { goal in
                        GoalIconView(goal: goal, isSelected:  Binding(
                            get: { self.selectedGoal == goal },
                            set: { if $0 { self.selectedGoal = goal } }
                        ))
                            .onTapGesture {
                                withAnimation {
                                    self.selectedGoal = goal
                                }
                            }
                    }
                }
            }
            .padding()
            
            if let selectedGoal = selectedGoal {
                Text(selectedGoal.description)
                    .padding()
                    .transition(.scale)
            }
    }
}

struct GoalIconView: View {
    let goal: GoalSelectionView.Goal
    @Binding var isSelected: Bool

    var body: some View {
        VStack {
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .font(.largeTitle)
                .foregroundColor(isSelected ? AppTheme.lime : .gray)
            Text(goal.rawValue)
                .font(.caption)
                .multilineTextAlignment(.center)
                .lineLimit(2, reservesSpace: true)
        }
        .frame(width: 60, height: 60)
        .padding()
        .background(isSelected ? AppTheme.grayLight : .clear)
        .cornerRadius(30)
        .onTapGesture {
            self.isSelected.toggle()
        }
    }
}
