//
//  CaloricNeedsView.swift
//  caloriecounter
//
//  Created by Sam Roman on 1/10/24.
//

import SwiftUI
import SwiftUI

struct CaloricNeedsView: View {
    @EnvironmentObject private var userSettingsManager: UserSettingsManager
    @Environment(\.presentationMode) var presentationMode // For the back button
    @State private var dailyCaloricNeeds: Double?
    
    var onLoginSuccess: () -> Void

    var body: some View {
        VStack {
            Button(action: {
                presentationMode.wrappedValue.dismiss() // Back to previous view
            }) {
                Text("Back to Form")
                    .foregroundColor(.white)
                    .padding()
                    .background(AppTheme.carrot)
                    .cornerRadius(8)
            }
            
            if let caloricNeeds = dailyCaloricNeeds {
                Text("Your Daily Caloric Needs")
                    .font(.headline)
                Text("\(caloricNeeds, specifier: "%.0f") calories")
                    .font(.title)

                Spacer()
                    .frame(height: 20)

                Spacer()
                    .frame(height: 20)

                Text("Sign up to get started")
                    .multilineTextAlignment(.center)
                    .padding()

                // Replace SignInWithAppleButton with LoginSignupView
                LoginSignupView(onLoginSuccess: onLoginSuccess)

            } else {
                Text("Calculating your daily caloric needs...")
                    .font(.headline)
                    .onAppear {
                        calculateCaloricNeeds()
                    }
            }
        }
        .padding()
    }

    private func calculateCaloricNeeds() {
        // Formula for calculating caloric needs

        let weightFactor = userSettingsManager.weight * 10
        let heightFactor = userSettingsManager.height * 6.25
        let ageFactor = Double(userSettingsManager.age) * 5

        let baseCaloricNeeds = weightFactor + heightFactor - ageFactor

        switch userSettingsManager.activity {
        case "Sedentary":
            dailyCaloricNeeds = baseCaloricNeeds * 1.2
        case "Lightly Active":
            dailyCaloricNeeds = baseCaloricNeeds * 1.375
        case "Moderately Active":
            dailyCaloricNeeds = baseCaloricNeeds * 1.55
        case "Very Active":
            dailyCaloricNeeds = baseCaloricNeeds * 1.725
        default:
            dailyCaloricNeeds = baseCaloricNeeds
        }

        if userSettingsManager.sex == "Female" {
            dailyCaloricNeeds! -= 161
        } else {
            dailyCaloricNeeds! += 5
        }
    }
}


