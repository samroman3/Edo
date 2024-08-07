//
//  PersonalHealthDataFormView.swift
//  caloriecounter
//
//  Created by Sam Roman on 12/14/23.
//
//
import SwiftUI
import Combine

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
    
    @State private var keyboardHeight: CGFloat = 0


    var onBoardEntry: Bool
    var onOnboardingComplete: () -> Void

    var body: some View {
        NavigationView {
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
                    Form{
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
                    }
                    
                    if let formError = formError {
                        Text(formError)
                            .foregroundColor(.red)
                    }
                if validateForm(){
                    calculateButton
                }
                
                if keyBoardOpen() {
                    Button(action: {
                        hideKeyboard()
                    }, label: {
                        Image(systemName: "keyboard.chevron.compact.down")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(AppTheme.textColor)
                    })
                    .padding([.vertical,.horizontal])
                } else {
                    
                    
                    Image(systemName: "info.circle")
                        .foregroundStyle(AppTheme.carrot)
                    
                    VStack(alignment: .center) {
                        Text("Calculations are made using the Mifflin-St Jeor equation and may not be suitable for everyone. This app is not intended to diagnose, treat, cure, or prevent any disease. Consult with a healthcare professional or a registered dietitian to determine the appropriate calorie and macronutrient targets based on individual needs and goals. Learn more from the following sources:")
                            .font(AppTheme.standardBookCaption)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray)
                        
                        VStack(alignment: .center) {
                            Link("Mifflin-St Jeor Equation", destination: URL(string: "https://reference.medscape.com/calculator/846/mifflin-st-jeor-equation")!)
                                .foregroundColor(.blue)
                        }
                        
                        VStack(alignment: .center) {
                            Link("Research on BMR", destination: URL(string: "https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7478086/")!)
                                .foregroundColor(.blue)
                        }
                        
                        VStack(alignment: .center) {
                            Link("Journal Article", destination: URL(string: "https://www.jandonline.org/article/S0002-8223(05)00149-5/abstract")!)
                                .foregroundColor(.blue)
                        }
                        
                    }
                    .padding(.vertical)
                }
            }
            .sheet(isPresented: $showHealthKitConsent) {
                HealthKitConsentView(isPresented: $showHealthKitConsent) { age, weight, height, sex in
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
                CaloricNeedsView(
                    onboardEntry: onBoardEntry,
                    onComplete: onOnboardingComplete
                )
                .environmentObject(userSettingsManager)
            }
            .background(Color(.systemBackground))
            .onReceive(Publishers.keyboardHeight) { self.keyboardHeight = $0 }
            .onAppear {
                loadUserDataIfNeeded()
            }
        }
    }
    
    private func keyBoardOpen() -> Bool {
           return keyboardHeight > 0
       }
    
    private var calculateButton: some View {
        Button(action: {
            if validateForm() {
                saveUserData()
                withAnimation {
                    showCaloricNeedsView = true
                }
            }
            HapticFeedbackProvider.impact()
        }) {
            Text("Calculate")
                .foregroundStyle(.white)
                .font(.largeTitle)
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppTheme.carrot)
                .cornerRadius(10)
        }
        .padding(.horizontal)
        .padding(.bottom, 20)
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
        let weightValue = unitSystem == .imperial ? convertPoundsToKilograms(Double(weight) ?? 0.0) : Double(weight) ?? 0.0
        let heightValue = unitSystem == .imperial ? convertFeetAndInchesToCentimeters(feet: feet, inches: inches) : Double(height) ?? 0.0
        userSettingsManager.saveUserSettings(
            age: Int(self.age) ?? 0,
            weight: weightValue,
            height: heightValue,
            sex: sex,
            activity: activityLevel,
            unitSystem: unitSystem.rawValue.lowercased(),
            userName: "",
            userEmail: ""
        )
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
