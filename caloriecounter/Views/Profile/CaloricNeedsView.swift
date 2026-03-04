////
////  CaloricNeedsView.swift
////  caloriecounter
////
////  Created by Sam Roman on 1/10/24.
////
//

import SwiftUI

struct CaloricNeedsView: View {
    @EnvironmentObject private var userSettingsManager: UserSettingsManager
    @EnvironmentObject var dailyLogManager: DailyLogManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedGoal: GoalSelectionView.Goal?
    let columns: [GridItem] = Array(repeating: .init(.adaptive(minimum: 200, maximum: 600)), count: 2)
    let macroNutrientTypes: [NutrientType] = [.calories, .protein, .carbs, .fats]
    
    let proteinPerCalorie = 4.0
    let carbsPerCalorie = 4.0
    let fatPerCalorie = 9.0
    
    @State private var nutrientValues: [NutrientType: String] = [.calories: "0", .protein: "0", .carbs: "0", .fats: "0"]
    var onboardEntry: Bool
    var onComplete: () -> Void
    
    @FocusState private var isInputActive: Bool
    @State private var selectedNutrient: NutrientType?
    @State private var showAlert = false
    @State private var calorieAdjustment: Double = 0
    
    var body: some View {
        NavigationView {
            VStack {
                HStack(alignment: .center) {
                    Button(action: {
                        withAnimation(.easeInOut) {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }) {
                        Image(systemName: "chevron.down")
                            .foregroundColor(AppTheme.textColor)
                    }.padding([.vertical, .horizontal])
                }
                
                ScrollView {
                    if let cal = nutrientValues[.calories] {
                        goalSelectionSection(caloricNeeds: Double(cal) ?? 0.0)
                    }
                    LazyVGrid(columns: columns, spacing: 3) {
                        ForEach(macroNutrientTypes, id: \.self) { nutrient in
                            MacroNutrientInputTile(
                                nutrient: nutrient,
                                addItemEntry: false,
                                value: $nutrientValues[nutrient],
                                isSelected: Binding(
                                    get: { selectedNutrient == nutrient },
                                    set: { newValue in
                                        if newValue {
                                            selectedNutrient = nutrient
                                            selectedGoal = .custom
                                        }
                                    }
                                ),
                                isInputActive: _isInputActive
                            ).onTapGesture {
                                HapticFeedbackProvider.impact()
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                VStack {
                    if selectedGoal == .custom {
                        HStack {
                            TextField("Enter value", text: selectedNutrientTextBinding(), onEditingChanged: { isEditing in
                                if isEditing && self.nutrientValues[selectedNutrient!] == "0" {
                                    self.nutrientValues[selectedNutrient!] = ""
                                }
                            })
                            .keyboardType(.decimalPad)
                            .focused($isInputActive)
                            .font(.largeTitle)
                            .frame(height: 70)
                            .fontWeight(.light)
                            .padding(.horizontal)
                            .foregroundColor(AppTheme.textColor)
                            Spacer()
                            
                            Button(action: {
                                hideKeyboard()
                            }, label: {
                                Image(systemName: "keyboard.chevron.compact.down")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundStyle(AppTheme.textColor)
                            })
                            .padding([.vertical, .horizontal])
                        }
                    }
                    
                    if !isInputActive {
                        saveButton
                    }
                }
            }
            .onAppear {
                loadUserSettings()
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Calorie Mismatch"),
                    message: Text("The sum of macros exceeds the total calories. Please adjust to fit within the calorie limit."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    private func selectedNutrientTextBinding() -> Binding<String> {
        Binding<String>(
            get: { self.nutrientValues[self.selectedNutrient ?? .calories] ?? "0" },
            set: { self.nutrientValues[self.selectedNutrient ?? .calories] = $0 }
        )
    }
    
    private func goalSelectionSection(caloricNeeds: Double) -> some View {
        VStack {
            Text("Macros are adjusted based on your selected goal and your personal health information.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .lineLimit(2, reservesSpace: true)
            GoalSelectionView(selectedGoal: $selectedGoal)
                .onChange(of: selectedGoal) { _, _ in
                    calculateCaloricNeeds()
                }
                .frame(minWidth: 100, minHeight: 100)
                .padding(.vertical)

            VStack(spacing: 8) {
                HStack {
                    Text("Maintenance Range")
                        .font(AppTheme.standardBookCaption)
                    Spacer()
                    Text(userSettingsManager.maintenanceRangeText())
                        .font(AppTheme.standardBookBody)
                }

                HStack {
                    Text("Daily Adjustment")
                        .font(AppTheme.standardBookCaption)
                    Spacer()
                    Text(calorieAdjustmentLabel)
                        .font(AppTheme.standardBookBody)
                }

                Stepper(value: $calorieAdjustment, in: -400...400, step: 50) {
                    Text("Fine tune")
                        .font(AppTheme.standardBookCaption)
                }
                .onChange(of: calorieAdjustment) { _, newValue in
                    userSettingsManager.saveCalorieAdjustmentOffset(newValue)
                    calculateCaloricNeeds()
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 18))
        }
    }
    
    private func calculateCaloricNeeds() {
        var adjustedCaloricNeeds = userSettingsManager.estimatedMaintenanceCalories(adjustment: calorieAdjustment)
          
        adjustCaloricNeedsBasedOnGoal(&adjustedCaloricNeeds)
          
        nutrientValues[.calories] = String(format: "%.0f", adjustedCaloricNeeds)
        updateMacros(for: adjustedCaloricNeeds)
      }
       
    private func adjustCaloricNeedsBasedOnGoal(_ caloricNeeds: inout Double) {
        guard let goal = selectedGoal else { return }

        switch goal {
        case .loseWeight:
            caloricNeeds = max(userSettingsManager.minimumSuggestedCalories(), caloricNeeds * 0.8)
        case .gainWeight:
            caloricNeeds *= 1.12
        case .buildMuscle:
            caloricNeeds *= 1.08
        case .enhancePerformance:
            caloricNeeds *= 1.05
        case .maintainWeight, .custom:
            break
        }
    }
       
    
    private struct MacroConfiguration {
        let minProteinPerKilogram: Double
        let minFatPerKilogram: Double
        let leftoverDistribution: (protein: Double, fat: Double, carbs: Double)
    }

    private func macroConfiguration(for goal: GoalSelectionView.Goal) -> MacroConfiguration {
        switch goal {
        case .loseWeight:
            return MacroConfiguration(
                minProteinPerKilogram: 1.9,
                minFatPerKilogram: 0.7,
                leftoverDistribution: (protein: 0.0, fat: 0.0, carbs: 1.0)
            )
        case .gainWeight:
            return MacroConfiguration(
                minProteinPerKilogram: 1.8,
                minFatPerKilogram: 0.8,
                leftoverDistribution: (protein: 0.0, fat: 0.0, carbs: 1.0)
            )
        case .buildMuscle:
            return MacroConfiguration(
                minProteinPerKilogram: 2.0,
                minFatPerKilogram: 0.8,
                leftoverDistribution: (protein: 0.0, fat: 0.0, carbs: 1.0)
            )
        case .enhancePerformance:
            return MacroConfiguration(
                minProteinPerKilogram: 1.6,
                minFatPerKilogram: 0.7,
                leftoverDistribution: (protein: 0.0, fat: 0.0, carbs: 1.0)
            )
        case .maintainWeight:
            return MacroConfiguration(
                minProteinPerKilogram: 1.6,
                minFatPerKilogram: 0.75,
                leftoverDistribution: (protein: 0.0, fat: 0.0, carbs: 1.0)
            )
        case .custom:
            return MacroConfiguration(
                minProteinPerKilogram: 0.0,
                minFatPerKilogram: 0.0,
                leftoverDistribution: (protein: 0.0, fat: 0.0, carbs: 1.0)
            )
        }
    }

    private func updateMacros(for caloricNeeds: Double) {
        guard let goal = selectedGoal, goal != .custom else { return }
        guard caloricNeeds > 0 else {
            nutrientValues[.protein] = "0"
            nutrientValues[.carbs] = "0"
            nutrientValues[.fats] = "0"
            return
        }

        let weightInKg = max(userSettingsManager.weight, 0)
        guard weightInKg > 0 else {
            nutrientValues[.protein] = "0"
            nutrientValues[.carbs] = String(format: "%.0f", caloricNeeds / carbsPerCalorie)
            nutrientValues[.fats] = "0"
            return
        }

        let configuration = macroConfiguration(for: goal)

        var proteinGrams = weightInKg * configuration.minProteinPerKilogram
        var fatGrams = weightInKg * configuration.minFatPerKilogram

        let proteinCalories = proteinGrams * proteinPerCalorie
        let fatCalories = fatGrams * fatPerCalorie
        let baselineCalories = proteinCalories + fatCalories

        if baselineCalories >= caloricNeeds {
            let scaleFactor = caloricNeeds / max(baselineCalories, 1)
            if scaleFactor.isFinite && scaleFactor > 0 {
                proteinGrams *= scaleFactor
                fatGrams *= scaleFactor
            } else {
                proteinGrams = 0
                fatGrams = 0
            }

            nutrientValues[.protein] = String(format: "%.0f", proteinGrams)
            nutrientValues[.fats] = String(format: "%.0f", fatGrams)
            nutrientValues[.carbs] = "0"
            return
        }

        let remainingCalories = max(0, caloricNeeds - baselineCalories)
        let extraProteinCalories = remainingCalories * configuration.leftoverDistribution.protein
        let extraFatCalories = remainingCalories * configuration.leftoverDistribution.fat
        let extraCarbCalories = max(0, remainingCalories - extraProteinCalories - extraFatCalories)

        proteinGrams += extraProteinCalories / proteinPerCalorie
        fatGrams += extraFatCalories / fatPerCalorie
        let carbGrams = extraCarbCalories / carbsPerCalorie

        nutrientValues[.protein] = String(format: "%.0f", proteinGrams)
        nutrientValues[.fats] = String(format: "%.0f", fatGrams)
        nutrientValues[.carbs] = String(format: "%.0f", max(0, carbGrams))
    }

    private func saveCaloricNeeds() {
        guard let cal = nutrientValues[.calories], let caloricNeeds = Double(cal) else { return }
        guard let protein = nutrientValues[.protein], let proteinToSave = Double(protein) else { return }
        guard let carbs = nutrientValues[.carbs], let carbsToSave = Double(carbs) else { return }
        guard let fats = nutrientValues[.fats], let fatsToSave = Double(fats) else { return }
        
        let totalMacroCalories = (proteinToSave * proteinPerCalorie) +
        (carbsToSave * carbsPerCalorie) +
        (fatsToSave * fatPerCalorie)
        
        if selectedGoal == .custom && totalMacroCalories > caloricNeeds {
            showAlert = true
            return
        }
        
        userSettingsManager.saveDietaryGoals(
            caloricNeeds: caloricNeeds,
            protein: proteinToSave,
            carbs: carbsToSave,
            fat: fatsToSave,
            dietaryPlan: selectedGoal?.rawValue ?? "Custom"
        )
        
        if onboardEntry {
            onComplete()
        } else {
            dailyLogManager.updateGoalsBasedOnDate()
        }
        
        presentationMode.wrappedValue.dismiss()
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
                .background(AppTheme.carrot)
                .cornerRadius(10)
        }
        .disabled(selectedGoal == nil)
        .padding(.horizontal)
        .padding(.bottom, 20)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Calorie Mismatch"),
                message: Text("The sum of macros exceeds the total calories. Please adjust to fit within the calorie limit."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private func loadUserSettings() {
        userSettingsManager.loadUserSettings()
        DispatchQueue.main.async {
            self.calorieAdjustment = self.userSettingsManager.calorieAdjustmentOffset
            if self.onboardEntry {
                self.selectedGoal = self.determineDefaultGoal()
            } else {
                self.selectedGoal = self.determineGoalBasedOnSettings()
            }
            self.calculateCaloricNeeds()
        }
    }

    private var calorieAdjustmentLabel: String {
        let value = Int(calorieAdjustment.rounded())
        return value == 0 ? "0 cal" : "\(value > 0 ? "+" : "")\(value) cal"
    }
    
    private func determineDefaultGoal() -> GoalSelectionView.Goal {
        // Default to "Maintain Weight" if coming from onboarding
        return .maintainWeight
    }
    
    private func determineGoalBasedOnSettings() -> GoalSelectionView.Goal? {
        switch userSettingsManager.dietaryPlan {
        case "Lose Weight": return .loseWeight
        case "Gain Weight": return .gainWeight
        case "Build Muscle": return .buildMuscle
        case "Enhance Performance": return .enhancePerformance
        case "Maintain Weight": return .maintainWeight
        default: return .custom
        }
    }
}

#Preview {
    CaloricNeedsView(onboardEntry: true, onComplete: {})
        .environmentObject(UserSettingsManager(context: PersistenceController(inMemory: false).container.viewContext))
}
