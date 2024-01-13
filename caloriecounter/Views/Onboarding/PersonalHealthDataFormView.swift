//
//  PersonalHealthDataFormView.swift
//  caloriecounter
//
//  Created by Sam Roman on 12/14/23.
//

import SwiftUI

struct PersonalHealthDataFormView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var userSettingsManager: UserSettingsManager
    @State private var age: String = ""
    @State private var weight: String = ""
    @State private var height: String = ""
    @State private var sex: String = ""
    @State private var activityLevel: String = ""
    @State private var unitSystem: UnitSystem = .metric
    @State private var feet = 0
    @State private var inches = 0
    @State private var formError: String? = nil
    
    @State private var selectedGoal: GoalSelectionView.Goal?
    
    @State private var showCaloricNeedsView = false
    @State private var showHealthKitConsent = false
    
    var onBoardEntry: Bool
    
    var onOnboardingComplete: () -> Void
    
    var onLoginSuccess: () -> Void

    
    var body: some View {
        VStack {
                Form {
                    Section(header: Text("Your Details").foregroundColor(AppTheme.lime)) {
                        TextField("Age", text: $age)
                            .keyboardType(.numberPad)
                        
                        Picker("Unit System", selection: $unitSystem) {
                            ForEach(UnitSystem.allCases, id: \.self) { unit in
                                Text(unit.rawValue).tag(unit)
                            }
                        }
                        
                        if unitSystem == .metric {
                            TextField("Weight (kg)", text: $weight)
                                .keyboardType(.decimalPad)
                            TextField("Height (cm)", text: $height)
                                .keyboardType(.decimalPad)
                        } else {
                            TextField("Weight (lb)", text: $weight)
                                .keyboardType(.decimalPad)
                            HStack {
                                Picker("Feet", selection: $feet) {
                                    ForEach(0..<10, id: \.self) { i in
                                        Text("\(i) ft").tag(i)
                                    }
                                }
                                Picker("Inches", selection: $inches) {
                                    ForEach(0..<12, id: \.self) { i in
                                        Text("\(i) in").tag(i)
                                    }
                                }
                            }
                            .onChange(of: feet) { _ in updateHeight() }
                            .onChange(of: inches) { _ in updateHeight() }
                        }
                        
                        Picker("Sex", selection: $sex) {
                            Text("").tag("")
                            Text("Male").tag("Male")
                            Text("Female").tag("Female")
                            Text("Other").tag("Other")
                        }
                        
                        Picker("Activity Level", selection: $activityLevel) {
                            Text("").tag("")
                            Text("Sedentary").tag("Sedentary")
                            Text("Lightly Active").tag("Lightly Active")
                            Text("Moderately Active").tag("Moderately Active")
                            Text("Very Active").tag("Very Active")
                        }
                }
    
                if let formError = formError {
                    Text(formError)
                        .foregroundColor(.red)
                }
                Section(header: Text("Select Your Goal").foregroundColor(AppTheme.lime)) {
                        HStack {
                            ForEach(GoalSelectionView.Goal.allCases, id: \.self) { goal in
                                GoalIconView(goal: goal, isSelected: .init(
                                    get: { self.selectedGoal == goal },
                                    set: { if $0 { self.selectedGoal = goal } }
                                ))
                            }
                        }
                        .padding(.vertical)
                    }
                    
                Button(action: {
                    if validateForm() {
//                        saveUserData()
                        withAnimation {
                        showCaloricNeedsView = true
                        
                        }
                        
                    }                   }) {
                    Text("Calculate")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppTheme.carrot)
                            .cornerRadius(10)
                    }
                    .navigationBarTitle("Health Data", displayMode: .inline)
                    .navigationBarItems(trailing: Button(action: {
                        showHealthKitConsent.toggle()
                    }) {
                        Image(systemName: "heart.fill")
                            .foregroundColor(AppTheme.carrot)
                    })
            }
            
            .sheet(isPresented: $showHealthKitConsent) {
                HealthKitConsentView(isPresented: $showHealthKitConsent) { age, weight, height, sex  in
                    self.age = age
                    self.weight = weight
                    self.height = height
                    self.sex = sex
                }
            }
            .fullScreenCover(isPresented: $showCaloricNeedsView) {
                CaloricNeedsView(onLoginSuccess: onLoginSuccess)
            }
        }
        }
    
    private func updateHeight() {
        if unitSystem == .imperial {
            let totalInches = feet * 12 + inches
            height = "\(totalInches)" // Height in inches
        }
    }
    private func validateForm() -> Bool {
        if age.isEmpty || weight.isEmpty || height.isEmpty || sex.isEmpty || activityLevel.isEmpty || selectedGoal == nil {
            formError = "Please fill in all fields."
            return false
        }
        formError = nil
        return true
    }
    private func saveUserData() {
        userSettingsManager.saveUserSettings(age: Int(self.age) ?? 0, weight: Double(weight) ?? 0.0, height: Double(height) ?? 0.0, sex: sex, activity: activityLevel, unitSystem: unitSystem.rawValue, userName: "", userEmail: "")
        userSettingsManager.loadUserSettings()
        
        
    }
}

enum UnitSystem: String, CaseIterable {
    case metric = "Metric"
    case imperial = "Imperial"
}
//#Preview {
//    PersonalHealthDataFormView()
//}


