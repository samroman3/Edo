//
//  ProfileView.swift
//  caloriecounter
//
//  Created by Sam Roman on 12/28/23.
//

import SwiftUI

struct ProfileMenuItem: View {
    let type: ProfileItemType
    
    var icon: Image {
        switch type {
        case .notifications:
            return Image(systemName: "bell")
        case .weightDynamics:
            return Image(systemName: "chart.line.downtrend.xyaxis")
        case .permissions:
            return Image(systemName: "heart.text.square")
        case .goals:
            return Image(systemName: "flag")
        case .removeAds:
               return Image(systemName: "nosign")
           }
    }
    
    var tint: Color {
        switch type {
        case .notifications:
            return AppTheme.skyBlue
        case .weightDynamics:
            return AppTheme.lime
        case .permissions:
            return AppTheme.coral
        case .goals:
            return AppTheme.goldenrod
    case .removeAds:
           return .red
       }
    }
    
var name: String {
    switch type {
    case .permissions:
        return "Permissions"
    case .notifications:
        return "Notifications"
    case .weightDynamics:
        return "Dynamics"
    case .goals:
        return "Goals"
    case .removeAds:
        return "Remove Ads"
    }
}
    
    var body: some View {
        VStack {
            HStack {
                Text(name)
                    .font(AppTheme.standardBookLargeTitle)
                Spacer()
                icon
                    .resizable()
                    .frame(width: 25, height: 25)
                    .foregroundStyle(tint)
                    .padding(.vertical)
            }
            .padding(.horizontal)
            .contentShape(Rectangle())
        }
        .foregroundStyle(AppTheme.textColor)
    }
}

enum ProfileItemType {
    case weightDynamics
    case notifications
    case permissions
    case goals
    case removeAds 
}

struct ProfileView: View {
    @EnvironmentObject private var userSettingsManager: UserSettingsManager
    
    @Binding var profileEditing: Bool

    @State private var isEditMode = false
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
        
    @State private var editingUserName: String = ""
    @State private var editingWeight: Double = 0.0
    @State private var editingHeight: Double = 0.0
    @State private var editingFeet: Int = 0
    @State private var editingInches: Int = 0
    @State private var editingActivityLevel: String = ""
    
    @State var showCaloricNeedsView = false
    @State var showPermissionsView = false
    @State var showRemoveAdsView = false
    @State private var isMetric: Bool = true
    
    @FocusState private var isInputActive: Bool

    private var profileImage: Image? {
        if let imageData = userSettingsManager.profileImage {
            if let image = UIImage(data: imageData) {
                return Image(uiImage: image)
            }
        }
        return nil
    }
    
    var body: some View {
        VStack{
            ScrollView {
                header
                    .padding()
                profileInfoSection
                if !isEditMode {
                    menuSection
                } else {
                    unitToggleSection
                }
                Spacer()
            }
            .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
                ImagePicker(image: self.$inputImage)
            }
            .sheet(isPresented: $showPermissionsView) {
                PermissionsView()
            }
            .sheet(isPresented: $showCaloricNeedsView) {
                CaloricNeedsView(onboardEntry: false, onComplete: {})
            }
            .sheet(isPresented: $showRemoveAdsView) { 
                     PurchaseView()
                 }
            .onAppear {
                self.editingUserName = self.userSettingsManager.userName
                self.editingActivityLevel = self.userSettingsManager.activity
                self.isMetric = self.userSettingsManager.unitSystem == "metric"
                
                if self.isMetric {
                    self.editingWeight = self.userSettingsManager.weight
                    self.editingHeight = self.userSettingsManager.height
                } else {
                    let weightInPounds = self.userSettingsManager.convertKilogramsToPounds(self.userSettingsManager.weight)
                    self.editingWeight = weightInPounds
                    let (feet, inches) = self.userSettingsManager.convertCentimetersToFeetAndInches(self.userSettingsManager.height)
                    self.editingFeet = feet
                    self.editingInches = inches
                }
            }
            if isInputActive {
                Button(action: {
                    hideKeyboard()
                }, label: {
                    Image(systemName: "keyboard.chevron.compact.down")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(AppTheme.textColor)
                })
                .padding([.vertical,.horizontal])
            }
        }
    }
    
    private var header: some View {
        HStack {
            Spacer()
            editButton
        }
    }
    
    private var profileInfoSection: some View {
        VStack {
            if isEditMode {
                TextField("User Name", text: $editingUserName)
                    .focused($isInputActive)
                    .font(AppTheme.standardBookTitle)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).stroke(AppTheme.textColor, lineWidth: 1))
                profileImageView
                    .font(AppTheme.standardBookBody)
                    .padding(.top)
            } else {
                VStack {
                    Text(userSettingsManager.userName)
                        .font(AppTheme.standardBookLargeTitle)
                    profileImageView
                        .padding(.horizontal)
                }
            }
            weightHeightSection
        }
        .padding()
    }
    
    private var weightHeightSection: some View {
        VStack(spacing: 8) {
            if isEditMode {
                editableWeightHeightField(label: "Weight:", value: $editingWeight, unit: isMetric ? "kg" : "lb")
                if isMetric {
                    editableWeightHeightField(label: "Height:", value: $editingHeight, unit: "cm")
                } else {
                    editableWeightHeightField(label: "Height:", value: .constant(Double(editingFeet * 12 + editingInches)), unit: "ft, in")
                }
            } else {
                profileInfoRow(
                    label: "Weight:",
                    value: isMetric ? "\(String(format: "%.0f", userSettingsManager.weight)) kg" :
                    "\(String(format: "%.0f", userSettingsManager.convertKilogramsToPounds(userSettingsManager.weight))) lb"
                )
                profileInfoRow(
                    label: "Height:",
                    value: isMetric ? "\(String(format: "%.0f", userSettingsManager.height)) cm" :
                    "\(userSettingsManager.convertCentimetersToFeetAndInches(userSettingsManager.height).0)' \(userSettingsManager.convertCentimetersToFeetAndInches(userSettingsManager.height).1)\""
                )
            }
            activityLevelSection
            BMISection
        }
    }
    
    private var activityLevelSection: some View {
        VStack {
            if isEditMode {
                HStack{
                    Text("Activity Level:")
                        .font(AppTheme.standardBookBody)
                    Spacer()
                    
                    Picker("Activity Level", selection: $editingActivityLevel) {
                        ForEach(ActivityLevel.allCases, id: \.self) { level in
                            Text(level.rawValue).tag(level.rawValue)
                        }
                    }
                    .pickerStyle(MenuPickerStyle()).tint(AppTheme.textColor)
                }
                .background(RoundedRectangle(cornerRadius: 10).stroke(AppTheme.textColor, lineWidth: 1))

            } else {
                HStack {
                    Text("Activity Level:")
                        .font(AppTheme.standardBookBody)
                    Spacer()
                    Text(userSettingsManager.activity)
                        .font(AppTheme.standardBookBody)
                    Image(systemName: ActivityLevel.getSymbol(for: userSettingsManager.activity))
                        .foregroundColor(AppTheme.sageGreen)
                        .font(AppTheme.standardBookTitle)
                }
            }
        }
    }
    
    private var BMISection: some View {
        VStack {
            if !isEditMode {
                HStack {
                    Text("BMI:")
                        .font(AppTheme.standardBookBody)
                    Spacer()
                    Text("\(userSettingsManager.calculateBMI() ?? 0, specifier: "%.f")")
                        .font(AppTheme.standardBookTitle)
                }
            }
        }
    }

    private func editableWeightHeightField(label: String, value: Binding<Double>, unit: String) -> some View {
        HStack {
            Text(label)
                .font(AppTheme.standardBookBody)
            Spacer()
            if label == "Height:" && !isMetric {
                HStack {
                    Picker("Feet", selection: $editingFeet) {
                        ForEach(0...12, id: \.self) { feet in
                            Text("\(feet) ft").tag(feet)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(width: 60, alignment: .center)
                    .clipped()

                    Picker("Inches", selection: $editingInches) {
                        ForEach(0..<12, id: \.self) { inches in
                            Text("\(inches) in").tag(inches)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(width: 60, alignment: .center)
                    .clipped()
                }
            } else {
                TextField("", value: value, formatter: NumberFormatter())
                    .keyboardType(.decimalPad)
                    .font(AppTheme.standardBookTitle)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80)
                    .focused($isInputActive)
            }
            Text(unit)
                .font(AppTheme.standardBookTitle)
        }
        .padding(.vertical, 8)
        .padding(.horizontal)
        .background(RoundedRectangle(cornerRadius: 10).stroke(AppTheme.textColor, lineWidth: 1))
    }
    
    private var unitToggleSection: some View {
        HStack {
            Text("Unit System")
                .font(AppTheme.standardBookTitle)
            Spacer()
            Picker("Unit System", selection: $isMetric) {
                Text("Metric").tag(true)
                Text("Imperial").tag(false)
            }
            .pickerStyle(SegmentedPickerStyle())
            .onChange(of: isMetric) { newValue in
                userSettingsManager.unitSystem = newValue ? "metric" : "imperial"
                convertUnits()
            }
        }
        .padding()
    }
    
    private var menuSection: some View {
        Group {
            Divider().background(AppTheme.textColor)
            ProfileMenuItem(type: .goals).onTapGesture {
                self.showCaloricNeedsView.toggle()
            }
            Divider().background(AppTheme.textColor)
            ProfileMenuItem(type: .permissions).onTapGesture {
                self.showPermissionsView.toggle()
            }
            Divider().background(AppTheme.textColor)
            ProfileMenuItem(type: .removeAds).onTapGesture {
                self.showRemoveAdsView.toggle()
            }
        }
    }
    
    private func profileInfoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(AppTheme.standardBookBody)
            Spacer()
            Text(value)
                .font(AppTheme.standardBookTitle)
        }
    }
    
    private var editButton: some View {
        Button(action: {
            if isEditMode {
                saveProfile()
                isEditMode.toggle()
                HapticFeedbackProvider.impact()
                profileEditing = false
            } else {
                isEditMode.toggle()
                profileEditing = true
            }
        }) {
            Text(isEditMode ? "Save" : "Edit")
                .font(.headline)
                .foregroundStyle(AppTheme.textColor)
        }
    }
    
    private func saveProfile() {
        if let inputImage {
            userSettingsManager.uploadProfileImage(inputImage)
        }
        if editingUserName != userSettingsManager.userName {
            userSettingsManager.saveUserName(editingUserName)
        }

        let weightToSave = isMetric ? editingWeight : userSettingsManager.convertPoundsToKilograms(editingWeight)
        let heightToSave: Double
        
        if isMetric {
            heightToSave = editingHeight
        } else {
            // Convert feet and inches back to centimeters before saving
            heightToSave = userSettingsManager.convertFeetAndInchesToCentimeters(feet: editingFeet, inches: editingInches)
        }
        userSettingsManager.saveUserSettings(
            age: userSettingsManager.age,
            weight: weightToSave,
            height: heightToSave,
            sex: userSettingsManager.sex,
            activity: editingActivityLevel,
            unitSystem: isMetric ? "metric" : "imperial",
            userName: editingUserName,
            userEmail: userSettingsManager.userEmail
        )
        
        userSettingsManager.loadUserSettings()
        
        //Show Caloric needs view if weight or height was changed with updated goals:
        if weightToSave != userSettingsManager.weight || heightToSave != userSettingsManager.height || editingActivityLevel != userSettingsManager.activity {
            showCaloricNeedsView.toggle()
        }
    }
    
    private func loadImage() {
        guard let inputImage = inputImage else { return }
        userSettingsManager.profileImage = inputImage.jpegData(compressionQuality: 0.8)
    }

    private var profileImageView: some View {
        Group {
            if isEditMode {
                Button("Select new photo") {
                    showingImagePicker = true
                }
                .tint(AppTheme.carrot)
            }
            if let profileImage = profileImage {
                profileImage
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
            } else {
                Image(systemName: "person.crop.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .foregroundColor(.gray)
            }
        }
        .padding()
    }

    private func convertUnits() {
        if isMetric {
            // Convert from Imperial to Metric
            editingWeight = userSettingsManager.convertPoundsToKilograms(editingWeight)
            // Convert feet and inches to centimeters
            let heightInCm = userSettingsManager.convertFeetAndInchesToCentimeters(feet: editingFeet, inches: editingInches)
            editingHeight = heightInCm
        } else {
            // Convert from Metric to Imperial
            editingWeight = userSettingsManager.convertKilogramsToPounds(editingWeight)
            // Convert centimeters to feet and inches
            let (feet, inches) = userSettingsManager.convertCentimetersToFeetAndInches(editingHeight)
            editingFeet = feet
            editingInches = inches
            // Update editingHeight for total inches
            editingHeight = Double(feet * 12 + inches)
        }
    }
}

enum ActivityLevel: String, CaseIterable {
    case sedentary = "Sedentary"
    case light = "Lightly Active"
    case moderate = "Moderately Active"
    case veryActive = "Very Active"

    static func getSymbol(for activity: String) -> String {
        switch activity {
        case ActivityLevel.sedentary.rawValue:
            return "tortoise"
        case ActivityLevel.light.rawValue:
            return "cat"
        case ActivityLevel.moderate.rawValue:
            return "dog"
        case ActivityLevel.veryActive.rawValue:
            return "hare"
        default:
            return "questionmark"
        }
    }
}

