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
    
    @State private var proteinEdit: String = ""
    @State private var carbsEdit: String = ""
    @State private var fatEdit: String = ""
    
    var onboardEntry: Bool 
    
    var onComplete: () -> Void
    
    @State private var isCustomGoal: Bool = false
    @State private var showPersonalHealthDataFormView = false
    var body: some View {
        NavigationView {
                if let caloricNeeds = dailyCaloricNeeds {
                    VStack(alignment: .center) {
                        if !onboardEntry {
                        Button(action: {
                                        showPersonalHealthDataFormView = true
                        }) {
                                HStack {
                                    Image(systemName: "person.circle")
                                        .foregroundColor(.blue)
                                    Text("View User Health Details")
                                        .foregroundColor(.blue)
                                }
                                .padding()
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.blue, lineWidth: 2)
                                )
                            }
                                .padding()
                                .sheet(isPresented: $showPersonalHealthDataFormView) {
                                    PersonalHealthDataFormView(onBoardEntry: false, onOnboardingComplete: {})
                                        .environmentObject(userSettingsManager)
                                }
                        }
                        Text("Daily Goals")
                            .font(.title)
                            .padding(.bottom, 5)

                        Text("Macros are adjusted based on your selected goal to optimize your diet for weight loss, maintenance, muscle gain, or performance. Edit the values below to input custom goals.")
                            .font(.subheadline)
                            .padding([.bottom,.horizontal], 20)
                        Divider().background(AppTheme.textColor)
                        GoalSelectionView(selectedGoal: $selectedGoal)
                            .onChange(of: selectedGoal) { _ in
                                calculateCaloricNeeds()
                                updateMacros(for: caloricNeeds)
                            }
                        Spacer()
                        macroNutrientsView
                        Spacer()
                        saveButton
                            .disabled(!(isCustomGoal || selectedGoal != nil))
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
                .foregroundStyle(AppTheme.textColor)
                .font(.largeTitle)
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppTheme.milk)
            
        }.disabled(!(isCustomGoal || selectedGoal != nil))
    }
    private var macroNutrientsView: some View {
        HStack() {
            VStack{
                MacroNutrientView(nutrient: "Calories", value: dailyCaloricNeeds ?? 0, disabled: (!isCustomGoal || selectedGoal == nil))
                MacroNutrientView(nutrient: "Proteins", value: protein, disabled: (!isCustomGoal || selectedGoal == nil))
            }
            VStack{
                MacroNutrientView(nutrient: "Carbs", value: carbs, disabled:  (!isCustomGoal || selectedGoal == nil))
                MacroNutrientView(nutrient: "Fats", value: fat, disabled:  (!isCustomGoal || selectedGoal == nil))
            }
        }
    }
    
    struct MacroNutrientView: View {
        var nutrient: String
        var value: Double
        var disabled: Bool
        
        var background: Color {
            switch nutrient {
            case "Calories":
                return AppTheme.sageGreen
            case "Proteins":
                return AppTheme.lavender
            case "Carbs":
                return AppTheme.goldenrod
            case "Fats":
                return AppTheme.coral
            default:
                return AppTheme.basic
            }
        }
        let screenWidth = UIScreen.main.bounds.width
        
        var body: some View {
            VStack {
                Text(nutrient)
                    .foregroundStyle(AppTheme.textColor)
                    .fontWeight(.heavy)
                Text("\(Int(value))g")
                    .fontWeight(.heavy)
                    .foregroundStyle(AppTheme.textColor)

            }
            .frame(width:screenWidth / 3, height: screenWidth / 5)
            .padding()
            .background(disabled ? background : .gray)
            .cornerRadius(5)
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
        case .custom:
            break
        }
        if goal != .custom {
            // Calculate macros
            protein = (caloricNeeds * proteinRatio) / proteinPerCalorie
            carbs = (caloricNeeds * carbsRatio) / carbsPerCalorie
            fat = (caloricNeeds * fatRatio) / fatPerCalorie
        }
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
