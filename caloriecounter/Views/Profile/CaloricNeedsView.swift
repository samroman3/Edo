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
    @EnvironmentObject var nutritionDataStore: NutritionDataStore
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

    var body: some View {
        NavigationView {
            VStack {
                HStack(alignment: .center) {
                    Button(action: {
                        withAnimation(.bouncy) {
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
                                            selectedGoal = .custom  // Set the goal to custom when a tile is tapped
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
        nutrientValues[.calories] = String(format: "%.2f", adjustedCaloricNeeds)
        updateMacros(for: adjustedCaloricNeeds)
    }

    private func calculateBMR() -> Double {
        let weightInKg = userSettingsManager.weight
        let heightInCm = userSettingsManager.height
        let age = Double(userSettingsManager.age)
        let s = userSettingsManager.sex == "Female" ? -161 : 5
        return (10 * weightInKg) + (6.25 * heightInCm) - (5 * age) + Double(s)
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
            caloricNeeds *= 0.9 // 10% caloric deficit
        case .gainWeight:
            caloricNeeds *= 1.1 // 10% caloric surplus
        case .buildMuscle:
            caloricNeeds *= 1.2 // 20% caloric surplus
        case .enhancePerformance, .maintainWeight:
            // No adjustment needed for maintenance or performance enhancement
            break
        default:
            break
        }
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
        case .gainWeight:
            proteinRatio = 0.3
            carbsRatio = 0.5
            fatRatio = 0.2
        case .buildMuscle:
            proteinRatio = 0.4
            carbsRatio = 0.4
            fatRatio = 0.2
        case .enhancePerformance, .maintainWeight:
            proteinRatio = 0.3
            carbsRatio = 0.4
            fatRatio = 0.3
        default:
            break
        }

        // Calculate macros
        nutrientValues[.protein] = String(format: "%.2f", (caloricNeeds * proteinRatio) / proteinPerCalorie)
        nutrientValues[.carbs] = String(format: "%.2f", (caloricNeeds * carbsRatio) / carbsPerCalorie)
        nutrientValues[.fats] = String(format: "%.2f", (caloricNeeds * fatRatio) / fatPerCalorie)
    }

    private func saveCaloricNeeds() {
        guard let cal = nutrientValues[.calories] else { return }
        guard let protein = nutrientValues[.protein] else { return }
        guard let carbs = nutrientValues[.carbs] else { return }
        guard let fats = nutrientValues[.fats] else { return }

        let calToSave = Double(cal) ?? 0.0
        let proteinToSave = Double(protein) ?? 0.0
        let carbToSave = Double(carbs) ?? 0.0
        let fatsToSave = Double(fats) ?? 0.0

        userSettingsManager.saveDietaryGoals(
            caloricNeeds: calToSave,
            protein: proteinToSave,
            carbs: carbToSave,
            fat: fatsToSave,
            dietaryPlan: selectedGoal!.rawValue
        )

        if onboardEntry {
            onComplete()
        }
        
        nutritionDataStore.updateTodayGoals(caloricNeeds: calToSave, protein: proteinToSave, carbs: carbToSave, fat: fatsToSave)
        dailyLogManager.updateGoalsBasedOnDate()
        self.presentationMode.wrappedValue.dismiss()
    }

    private func loadUserSettings() {
        userSettingsManager.loadUserSettings()
        if onboardEntry {
            // Set a default goal if coming from onboarding
            selectedGoal = determineDefaultGoal()
        } else {
            // Load the existing goal from user settings
            selectedGoal = determineGoalBasedOnSettings()
        }

        nutrientValues[.calories] = String(format: "%.2f", userSettingsManager.dailyCaloricNeeds)
        nutrientValues[.protein] = String(format: "%.2f", userSettingsManager.proteinGoal)
        nutrientValues[.carbs] = String(format: "%.2f", userSettingsManager.carbsGoal)
        nutrientValues[.fats] = String(format: "%.2f", userSettingsManager.fatGoal)
    }

    private func determineDefaultGoal() -> GoalSelectionView.Goal {
        // Default to "Maintain Weight" if coming from onboarding
        return .maintainWeight
    }

    private func determineGoalBasedOnSettings() -> GoalSelectionView.Goal? {
        // Determine the current goal based on saved dietary plan or macros
        switch userSettingsManager.dietaryPlan {
        case "Lose Weight":
            return .loseWeight
        case "Gain Weight":
            return .gainWeight
        case "Build Muscle":
            return .buildMuscle
        case "Enhance Performance":
            return .enhancePerformance
        case "Maintain Weight":
            return .maintainWeight
        default:
            return .custom
        }
    }

    private var saveButton: some View {
        Button(action: {
            saveCaloricNeeds()
        }) {
            Text("Save")
                .foregroundStyle(AppTheme.reverse)
                .font(.largeTitle)
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppTheme.textColor)
                .cornerRadius(10)
        }
        .disabled(selectedGoal == nil)
        .padding(.horizontal)
        .padding(.bottom, 20)
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
                    .fontWeight(.light)
                Text("\(Int(value))g")
                    .fontWeight(.heavy)
                    .foregroundStyle(AppTheme.textColor)

            }
            .frame(width: screenWidth / 3, height: screenWidth / 5)
            .padding()
            .background(disabled ? background : .gray)
            .cornerRadius(5)
        }
    }
}

#Preview {
    CaloricNeedsView(onboardEntry: true, onComplete: {})
        .environmentObject(UserSettingsManager(context: PersistenceController(inMemory: false).container.viewContext))
}

