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
    
    @State private var showCaloricNeedsView = false
    @State private var showHealthKitConsent = false
    
    
    var onBoardEntry: Bool
    
    var onOnboardingComplete: () -> Void

    
    var body: some View {
        NavigationView{
            VStack {
                Button(action: {
                    showHealthKitConsent = true
                }) {
                    HStack {
                        Image(systemName: "heart.text.square.fill")
                            .foregroundColor(.red)
                        Text("Fill in with Health App")
                            .foregroundColor(.red)
                    }
                    .padding()
                    .cornerRadius(10)
                }
                .background(Color(.systemBackground))
                .padding()
                
                Form {
                    Section(header: Text("Your Details").foregroundColor(AppTheme.basic)) {
                        TextField("Age", text: $age)
                            .keyboardType(.numberPad)
                        
                        Picker("Unit System", selection: $unitSystem) {
                            ForEach(UnitSystem.allCases, id: \.self) { unit in
                                Text(unit.rawValue).tag(unit)
                            }
                        }
                        .onChange(of: unitSystem) { newValue in
                            convertValuesForUnitSystem(newValue)
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
                    
                    Button(action: {
                        if validateForm() {
                            saveUserData()
                            withAnimation {
                                showCaloricNeedsView = true
                                
                            }
                            
                        }                   }) {
                            Text("Calculate")
                                .foregroundColor(AppTheme.milk)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppTheme.carrot)
                                .cornerRadius(10)
                        }
                }
                .sheet(isPresented: $showHealthKitConsent) {
                    HealthKitConsentView(isPresented: $showHealthKitConsent) { age, weight, height, sex  in
                        self.age = age
                        self.sex = sex
                        if unitSystem == .imperial {
                            // Convert metric (HealthKit default) values to imperial
                            let (convertedFeet, convertedInches) = convertCentimetersToFeetAndInches(Double(height) ?? 0.0)
                            feet = convertedFeet
                            inches = convertedInches
                            self.weight = "\(convertKilogramsToPounds(Double(weight) ?? 0.0))"
                        } else {
                            // Directly use the metric values from HealthKit
                            self.height = "\(height)"
                            self.weight = "\(weight)"
                        }
                    }
                }
                .sheet(isPresented: $showCaloricNeedsView) {
                    CaloricNeedsView(onboardEntry: onBoardEntry, onComplete: onOnboardingComplete)
                }
            }
            .background(Color(.systemBackground))
            .onAppear {
                loadUserDataIfNeeded()
            }
        }
        }
    
    private func convertValuesForUnitSystem(_ unitSystem: UnitSystem) {
        switch unitSystem {
        case .metric:
            // If `weight` and `height` are stored as Strings in imperial units, convert them to metric
            let weightInKg = convertPoundsToKilograms(Double(weight) ?? 0)
            let heightInCm = convertFeetAndInchesToCentimeters(feet: feet, inches: inches)
            weight = "\(weightInKg)"
            height = "\(heightInCm)"
        case .imperial:
            // Convert metric values back to imperial
            let (convertedFeet, convertedInches) = convertCentimetersToFeetAndInches(Double(height) ?? 0)
            feet = convertedFeet
            inches = convertedInches
            weight = "\(convertKilogramsToPounds(Double(weight) ?? 0))"
        }
    }
    
    private func loadUserDataIfNeeded() {
        if !onBoardEntry { // Only load data if not in onboarding process
            age = String(userSettingsManager.age)
            weight = String(userSettingsManager.weight)
            height = String(userSettingsManager.height)
            sex = userSettingsManager.sex
            activityLevel = userSettingsManager.activity
            unitSystem = UnitSystem(rawValue: userSettingsManager.unitSystem) ?? .metric
        }
    }

    private func updateHeight() {
        if unitSystem == .imperial {
            let totalInches = feet * 12 + inches
            height = "\(totalInches)" // Height in inches
        }
    }
    private func validateForm() -> Bool {
        if age.isEmpty || weight.isEmpty || height.isEmpty || sex.isEmpty || activityLevel.isEmpty {
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
    
    func convertPoundsToKilograms(_ pounds: Double) -> Double {
        return pounds / 2.20462
    }

    func convertKilogramsToPounds(_ kilograms: Double) -> Double {
        return kilograms * 2.20462
    }

    func convertFeetAndInchesToCentimeters(feet: Int, inches: Int) -> Double {
        return Double(feet) * 30.48 + Double(inches) * 2.54
    }

    func convertCentimetersToFeetAndInches(_ centimeters: Double) -> (feet: Int, inches: Int) {
        let totalInches = centimeters / 2.54
        let feet = Int(totalInches) / 12
        let inches = Int(totalInches) % 12
        return (feet, inches)
    }

}

enum UnitSystem: String, CaseIterable {
    case metric = "Metric"
    case imperial = "Imperial"
}

struct PersonalHealthDataFormView_Previews: PreviewProvider {
    static var previews: some View {
        PersonalHealthDataFormView(onBoardEntry: true, onOnboardingComplete: {})
            .environment(\.colorScheme, .light) // Preview in light mode

        PersonalHealthDataFormView(onBoardEntry: true, onOnboardingComplete: {})
            .environment(\.colorScheme, .dark) // Preview in dark mode
    }
}



