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
                calculateCaloricNeeds()
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
    
    private func calculateBMR() -> Double {
          let weightInKg = userSettingsManager.weight
          let heightInCm = userSettingsManager.height
          let age = Double(userSettingsManager.age)
          
          if userSettingsManager.sex == "Female" {
              return 447.593 + (9.247 * weightInKg) + (3.098 * heightInCm) - (4.330 * age)
          } else {
              return 88.362 + (13.397 * weightInKg) + (4.799 * heightInCm) - (5.677 * age)
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
    
    private func calculateCaloricNeeds() {
          let bmr = calculateBMR()
          let activityMultiplier = getActivityMultiplier()
          var adjustedCaloricNeeds = bmr * activityMultiplier
          
          adjustCaloricNeedsBasedOnGoal(&adjustedCaloricNeeds)
          
          nutrientValues[.calories] = String(format: "%.0f", adjustedCaloricNeeds)
          updateMacros(for: adjustedCaloricNeeds)
      }
       
    private func adjustCaloricNeedsBasedOnGoal(_ caloricNeeds: inout Double) {
           guard let goal = selectedGoal else { return }
           
           switch goal {
           case .loseWeight:
               caloricNeeds = max(1200, caloricNeeds * 0.85) // 15% deficit, but not below 1200
           case .gainWeight:
               caloricNeeds *= 1.1 // 10% surplus for gradual weight gain
           case .buildMuscle:
               caloricNeeds *= 1.05 // 5% surplus for lean muscle gain
           case .enhancePerformance, .maintainWeight:
               break // No change
           case .custom:
               break // No change, user will input their own values
           }
       }
       
    
    private func updateMacros(for caloricNeeds: Double) {
           guard let goal = selectedGoal else { return }
           
           let weightInKg = userSettingsManager.weight
           
           var proteinMultiplier: Double
           var fatMultiplier: Double
           
           switch goal {
           case .loseWeight:
               proteinMultiplier = 1.6 // grams per kg of body weight
               fatMultiplier = 0.8 // grams per kg of body weight
           case .gainWeight, .buildMuscle:
               proteinMultiplier = 2.0
               fatMultiplier = 1.0
           case .enhancePerformance:
               proteinMultiplier = 1.8
               fatMultiplier = 1.0
           case .maintainWeight:
               proteinMultiplier = 1.6
               fatMultiplier = 0.9
           case .custom:
               // Use user-input values
               return
           }

           let proteinGrams = weightInKg * proteinMultiplier
           let fatGrams = weightInKg * fatMultiplier
           let proteinCalories = proteinGrams * proteinPerCalorie
           let fatCalories = fatGrams * fatPerCalorie
           let carbsCalories = caloricNeeds - proteinCalories - fatCalories
           let carbsGrams = carbsCalories / carbsPerCalorie

           nutrientValues[.protein] = String(format: "%.0f", proteinGrams)
           nutrientValues[.carbs] = String(format: "%.0f", max(0, carbsGrams))
           nutrientValues[.fats] = String(format: "%.0f", fatGrams)
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
        
//        // Preload the macro values
//        let caloricNeeds = userSettingsManager.dailyCaloricNeeds
//        nutrientValues[.calories] = String(format: "%.0f", caloricNeeds)
//        nutrientValues[.protein] = String(format: "%.0f", userSettingsManager.proteinGoal)
//        nutrientValues[.carbs] = String(format: "%.0f", userSettingsManager.carbsGoal)
//        nutrientValues[.fats] = String(format: "%.0f", userSettingsManager.fatGoal)
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
