//
//  UserStatsView.swift
//  caloriecounter
//
//  Created by Sam Roman on 12/29/23.
//

import SwiftUI

struct UserStatsView: View {
    @EnvironmentObject var userSettingsManager: UserSettingsManager
    @State private var showingImagePicker = false
    
    var weight: Double
    var height: Double

    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            Text("Your Stats")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.top)

            ProfileImageView(image: Image(uiImage: userSettingsManager.profileImage ?? UIImage(systemName: "person.crop.circle")!))
                .frame(width: 100, height: 100)
                .clipShape(Circle())
                .overlay(Circle().stroke(AppTheme.basic, lineWidth: 4))
                .shadow(radius: 10)
                .onTapGesture {
                    showingImagePicker = true
                }
            
            Text("Weight: \(String(format: "%.1f", weight)) kg")
                .font(.headline)
            Text("Height: \(String(format: "%.1f", height)) cm")
                .font(.headline)
            
            if let bmi = userSettingsManager.calculateBMI() {
                Text("BMI: \(String(format: "%.1f", bmi))")
                    .font(.headline)
                    .foregroundColor(bmiColor(bmi: bmi))
            } else {
                Text("BMI: Not Available")
                    .font(.headline)
                    .foregroundColor(.gray)
            }
            
            // Additional stats can be added here
        }
        .padding()
        .background(AppTheme.grayDark.opacity(0.1))
        .cornerRadius(12)
        .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
//            ImagePicker(image: self.$userSettingsManager.profileImage)
        }
    }
    
    private func loadImage() {
        guard let selectedImage = userSettingsManager.profileImage else { return }
        userSettingsManager.uploadProfileImage(selectedImage)
    }
    
    private func bmiColor(bmi: Double) -> Color {
        switch bmi {
        case ..<18.5:
            return .blue
        case 18.5..<24.9:
            return .green
        case 24.9..<29.9:
            return .yellow
        default:
            return .red
        }
    }
}



