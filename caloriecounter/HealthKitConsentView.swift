//
//  HealthKitConsentView.swift
//  caloriecounter
//
//  Created by Sam Roman on 12/11/23.
//

import SwiftUI
import HealthKit

struct CaloricCalculationFormView: View {
    @State private var age: String = ""
    @State private var weight: String = ""
    @State private var height: String = ""
    @State private var sex: String = ""
    @State private var activityLevel: String = ""
    @State private var showHealthKitConsent = false
    @State private var unitSystem: UnitSystem = .metric
    @State private var feet: Int = 0
    @State private var inches: Int = 0

       enum UnitSystem: String, CaseIterable {
           case metric = "Metric"
           case imperial = "Imperial"
       }

       var body: some View {
           NavigationView {
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
                       }

                       Picker("Sex", selection: $sex) {
                           Text("Male").tag("Male")
                           Text("Female").tag("Female")
                           Text("Other").tag("Other")
                       }

                       Picker("Activity Level", selection: $activityLevel) {
                           Text("Sedentary").tag("Sedentary")
                           Text("Lightly Active").tag("Lightly Active")
                           Text("Moderately Active").tag("Moderately Active")
                           Text("Very Active").tag("Very Active")
                       }
                   }

                   Button(action: {
                       // Submit form data logic here
                   }) {
                       Text("Calculate Caloric Needs")
                           .foregroundColor(.white)
                           .frame(maxWidth: .infinity)
                           .padding()
                           .background(AppTheme.carrot)
                           .cornerRadius(10)
                   }
               }
            .navigationBarTitle("Set Your Goals", displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                showHealthKitConsent.toggle()
            }) {
                Image(systemName: "heart.fill")
                    .foregroundColor(AppTheme.carrot)
            })
            .sheet(isPresented: $showHealthKitConsent) {
                HealthKitConsentView(isPresented: $showHealthKitConsent)
            }
        }
    }
}

struct HealthKitConsentView: View {
    @Binding var isPresented: Bool
    let healthStore = HKHealthStore()

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Health Data Access")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Eazeat would like to use data from the Health app to personalize your experience. This includes your gender, date of birth, height, and weight.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding()

                Button(action: {
                    requestHealthKitPermission()
                }) {
                    Text("Continue with HealthKit")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }

                Button("No Thanks") {
                    isPresented = false
                }
                .foregroundColor(.red)

                Spacer()
            }
            .padding()
            .navigationBarTitle("HealthKit Integration", displayMode: .inline)
            .navigationBarItems(trailing: Button("Close") {
                isPresented = false
            })
        }
    }

    private func requestHealthKitPermission() {
        let readTypes = Set([
            HKObjectType.characteristicType(forIdentifier: .biologicalSex)!,
            HKObjectType.characteristicType(forIdentifier: .dateOfBirth)!,
            HKObjectType.quantityType(forIdentifier: .height)!,
            HKObjectType.quantityType(forIdentifier: .bodyMass)!
        ])

        // Check if HealthKit is available
        if HKHealthStore.isHealthDataAvailable() {
            // Request authorization
            healthStore.requestAuthorization(toShare: nil, read: readTypes) { (success, error) in
                if success {
                    // Permissions granted, proceed with fetching HealthKit data
                    // Fetch and process HealthKit data here
                } else {
                    // Handle errors or lack of permissions
                }
            }
        }
    }
}
