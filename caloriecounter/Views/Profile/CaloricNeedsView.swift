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
                .onChange(of: selectedGoal) { _ in
                    calculateCaloricNeeds()
                }
                .frame(minWidth: 100, minHeight: 100)
                .padding(.vertical)
        }
    }
    
    private func calculateCaloricNeeds() {
        let bmr = calculateBMR()
        let activityMultiplier = getActivityMultiplier()
        var adjustedCaloricNeeds = bmr * activityMultiplier
        
        adjustCaloricNeedsBasedOnGoal(&adjustedCaloricNeeds)
        
        nutrientValues[.calories] = String(format: "%.0f", adjustedCaloricNeeds)
        updateMacros(for: adjustedCaloricNeeds)
    }
    
    private func calculateBMR() -> Double {
        let weightInKg = userSettingsManager.weight
        let heightInCm = userSettingsManager.height
        let age = Double(userSettingsManager.age)
        
        if userSettingsManager.sex == "Female" {
            return 10 * weightInKg + 6.25 * heightInCm - 5 * age - 161
        } else {
            return 10 * weightInKg + 6.25 * heightInCm - 5 * age + 5
        }
    }
    
    private func getActivityMultiplier() -> Double {
        switch userSettingsManager.activity {
        case "Sedentary": return 1.2
        case "Lightly Active": return 1.375
        case "Moderately Active": return 1.55
        case "Very Active": return 1.725
        default: return 1.2
        }
    }
    
    private func adjustCaloricNeedsBasedOnGoal(_ caloricNeeds: inout Double) {
        guard let goal = selectedGoal else { return }
        
        switch goal {
        case .loseWeight:
            caloricNeeds -= caloricNeeds * 0.15 // 15% caloric deficit
        case .gainWeight:
            caloricNeeds += caloricNeeds * 0.15 // 15% caloric surplus
        case .buildMuscle:
            caloricNeeds += caloricNeeds * 0.1 // 10% caloric surplus
        case .enhancePerformance, .maintainWeight:
            break
        default:
            break
        }
    }
    
    private func updateMacros(for caloricNeeds: Double) {
        guard let goal = selectedGoal else { return }
        
        var proteinRatio = 0.4
        var carbsRatio = 0.4
        var fatRatio = 0.2
        
        switch goal {
        case .loseWeight:
            proteinRatio = 0.4
            carbsRatio = 0.3
            fatRatio = 0.3
        case .gainWeight, .buildMuscle:
            proteinRatio = 0.3
            carbsRatio = 0.5
            fatRatio = 0.2
        case .enhancePerformance, .maintainWeight:
            proteinRatio = 0.3
            carbsRatio = 0.4
            fatRatio = 0.3
        case .custom:
            let proteinCalories = Double(nutrientValues[.protein] ?? "0") ?? 0 * proteinPerCalorie
            let carbsCalories = Double(nutrientValues[.carbs] ?? "0") ?? 0 * carbsPerCalorie
            let fatCalories = Double(nutrientValues[.fats] ?? "0") ?? 0 * fatPerCalorie
            let totalMacroCalories = proteinCalories + carbsCalories + fatCalories
            
            if totalMacroCalories > caloricNeeds {
                showAlert = true
            } else {
                // Only update if within the limit
                nutrientValues[.protein] = String(format: "%.0f", proteinCalories / proteinPerCalorie)
                nutrientValues[.carbs] = String(format: "%.0f", carbsCalories / carbsPerCalorie)
                nutrientValues[.fats] = String(format: "%.0f", fatCalories / fatPerCalorie)
            }
            return
        }

        // Update macros based on ratios and caloric needs
        nutrientValues[.protein] = String(format: "%.0f", (caloricNeeds * proteinRatio) / proteinPerCalorie)
        nutrientValues[.carbs] = String(format: "%.0f", (caloricNeeds * carbsRatio) / carbsPerCalorie)
        nutrientValues[.fats] = String(format: "%.0f", (caloricNeeds * fatRatio) / fatPerCalorie)
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
        
        if onboardEntry {
            selectedGoal = determineDefaultGoal()
        } else {
            selectedGoal = determineGoalBasedOnSettings()
        }
        
        // Preload the macro values
        let caloricNeeds = userSettingsManager.dailyCaloricNeeds
        nutrientValues[.calories] = String(format: "%.0f", caloricNeeds)
        nutrientValues[.protein] = String(format: "%.0f", userSettingsManager.proteinGoal)
        nutrientValues[.carbs] = String(format: "%.0f", userSettingsManager.carbsGoal)
        nutrientValues[.fats] = String(format: "%.0f", userSettingsManager.fatGoal)
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
//            .environmentObject(DailyLogManager(context: context, userSettings: UserSettingsManager(context: context)))
    }
