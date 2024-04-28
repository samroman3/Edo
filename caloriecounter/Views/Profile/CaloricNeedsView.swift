//
//  CaloricNeedsView.swift
//  caloriecounter
//
//  Created by Sam Roman on 1/10/24.
//

import SwiftUI

struct CaloricNeedsView: View {
    @EnvironmentObject private var userSettingsManager: UserSettingsManager
    @Environment(\.presentationMode) var presentationMode
    @State private var dailyCaloricNeeds: Double?
    @State private var selectedGoal: GoalSelectionView.Goal?
    @State private var protein: Double = 0
    @State private var carbs: Double = 0
    @State private var fat: Double = 0

    let proteinPerCalorie = 4.0
    let carbsPerCalorie = 4.0
    let fatPerCalorie = 9.0
    
    var onboardEntry: Bool 
    
    var onComplete: () -> Void
    
    

    var body: some View {
        NavigationView {
                if let caloricNeeds = dailyCaloricNeeds {
                    VStack(alignment: .center) {
                        Text("Your Daily Caloric Needs: \(Int(caloricNeeds)) calories")
                            .font(.headline)
                            .padding(.bottom, 5)

                        Text("This estimate is based on your age, weight, height, sex, and activity level. Adjust your goals to see how they change your macro needs.")
                            .font(.caption)
                            .padding(.bottom, 20)

                        GoalSelectionView(selectedGoal: $selectedGoal)
                            .frame(width: 300) // Set a fixed width or use geometry reader for responsiveness
                            .onChange(of: selectedGoal) { _ in
                                calculateCaloricNeeds()
                                updateMacros(for: caloricNeeds)
                            }
                        VStack {
                            Text("Daily Caloric Goal: \(Int(caloricNeeds))")
                                .font(.title2)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                        }
                        macroNutrientsView
                            .frame(width: 300) // Match width for alignment
                           Text("Macros are adjusted based on your selected goal to optimize your diet for weight loss, maintenance, muscle gain, or performance.")
                               .font(.caption)
                               .padding()

                        saveButton
                    }
                } else {
                    Text("Calculating your daily caloric needs...")
                        .font(.headline)
                        .onAppear(perform: calculateCaloricNeeds)
                }
            }
            .navigationBarItems(leading: backButton)
            .navigationTitle("Caloric Needs")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                loadUserSettings()
            }
    }
    
    private func loadUserSettings() {
        userSettingsManager.loadUserSettings()
        calculateCaloricNeeds()
        updateMacros(for: userSettingsManager.dailyCaloricNeeds)
    }

    private var backButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "arrow.backward")
                .foregroundColor(.orange)
        }
    }

    private var saveButton: some View {
        Button(action: {
            saveCaloricNeeds()
        }) {
            Text("Save")
                .foregroundColor(.white)
                .font(.largeTitle)
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppTheme.goldenrod)
        }
    }

    private var macroNutrientsView: some View {
        HStack {
            MacroNutrientView(nutrient: "Proteins", value: protein)
            MacroNutrientView(nutrient: "Carbs", value: carbs)
            MacroNutrientView(nutrient: "Fats", value: fat)
        }.padding()
    }
    
    struct MacroNutrientView: View {
        var nutrient: String
        var value: Double
        
        var background: Color {
            switch nutrient {
            case "Proteins":
                return AppTheme.sageGreen
            case "Carbs":
                return AppTheme.lavender
            case "Fats":
                return AppTheme.coral
            default:
                return AppTheme.basic
            }
        }
        
        var body: some View {
            VStack {
                Text(nutrient)
                Text("\(Int(value))g")
            }
            .padding()
            .background(background.opacity(0.7))
            .cornerRadius(8)
        }
    }
    
    private func calculateCaloricNeeds() {
        // Calculate BMR first
        let weightInKg = userSettingsManager.weight
        let heightInCm = userSettingsManager.height
        let age = Double(userSettingsManager.age)
        let s = userSettingsManager.sex == "Female" ? -161 : 5
        let bmr = (10 * weightInKg) + (6.25 * heightInCm) - (5 * age) + Double(s)
        
        // Default activity multiplier
        let activityMultiplier: Double
        switch userSettingsManager.activity {
        case "Sedentary": activityMultiplier = 1.2
        case "Lightly Active": activityMultiplier = 1.375
        case "Moderately Active": activityMultiplier = 1.55
        case "Very Active": activityMultiplier = 1.725
        default: activityMultiplier = 1.2
        }
        
        var adjustedCaloricNeeds = bmr * activityMultiplier
        
        // Adjust caloric needs based on goal
        switch selectedGoal {
        case .loseWeight:
            adjustedCaloricNeeds *= 0.9 // 10% caloric deficit
        case .gainWeight:
            adjustedCaloricNeeds *= 1.1 // 10% caloric surplus
        case .buildMuscle:
            adjustedCaloricNeeds *= 1.2 // 20% caloric surplus
        case .improveFitness, .enhancePerformance, .maintainWeight:
            // No adjustment needed for maintenance, fitness improvement, or performance enhancement
            break
        default:
            break
        }
        
        dailyCaloricNeeds = adjustedCaloricNeeds
        updateMacros(for: adjustedCaloricNeeds)
    }

    private func updateMacros(for caloricNeeds: Double) {
        guard let goal = selectedGoal else { return }
        
        // Define default macro ratios
        var proteinRatio = 0.3
        var carbsRatio = 0.4
        var fatRatio = 0.3
        
        // Adjust macros based on the goal
        switch goal {
        case .loseWeight:
            proteinRatio = 0.4
            carbsRatio = 0.3
            fatRatio = 0.3
        case .gainWeight, .buildMuscle:
            proteinRatio = 0.3
            carbsRatio = 0.5
            fatRatio = 0.2
        case .improveFitness, .enhancePerformance:
            proteinRatio = 0.3
            carbsRatio = 0.5
            fatRatio = 0.2
        case .maintainWeight:
            proteinRatio = 0.3
            carbsRatio = 0.4
            fatRatio = 0.3
        }
        
        // Calculate macros
        protein = (caloricNeeds * proteinRatio) / proteinPerCalorie
        carbs = (caloricNeeds * carbsRatio) / carbsPerCalorie
        fat = (caloricNeeds * fatRatio) / fatPerCalorie
    }

    
    
    private func saveCaloricNeeds() {
        userSettingsManager.saveDietaryGoals(caloricNeeds: dailyCaloricNeeds ?? 0.0, protein: protein, carbs: carbs, fat: fat)
        
        if onboardEntry {
            onComplete()
        }
        
    }
}

#Preview {
    CaloricNeedsView(onboardEntry: true, onComplete: {})
        .environmentObject(UserSettingsManager(context: PersistenceController(inMemory: false).container.viewContext))
}



