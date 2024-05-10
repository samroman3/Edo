//
//  HealthKitConsentView.swift
//  caloriecounter
//
//  Created by Sam Roman on 12/11/23.
//

import SwiftUI
import HealthKit

struct HealthKitConsentView: View {
    @Binding var isPresented: Bool
    let healthStore = HKHealthStore()
    
    var onFetchComplete: ((String, String, String, String) -> Void)?

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Health Data Access")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
                
                Text("We would like to use data from the Health app to streamline your experience. This includes your gender, date of birth, height, and weight. All data is stored privately and only accessible to you through iCloud.")
                    .font(.callout)
                    .multilineTextAlignment(.center)
                    .padding()
                
                continueButton
                
                Button(action: {
                    isPresented = false
                }) {
                    Text("No Thanks")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationBarTitle("HealthKit Permission", displayMode: .inline)
            .padding()
        }
    }
    
    private var continueButton: some View {
        Button(action: {
            requestHealthKitPermission()
        }) {
            Text("Continue")
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
        }
        .padding(.horizontal)
    }
    
    private func requestHealthKitPermission() {
        guard let biologicalSexType = HKObjectType.characteristicType(forIdentifier: .biologicalSex),
              let dateOfBirthType = HKObjectType.characteristicType(forIdentifier: .dateOfBirth),
              let heightType = HKObjectType.quantityType(forIdentifier: .height),
              let bodyMassType = HKObjectType.quantityType(forIdentifier: .bodyMass) else {
            print("One or more required types are unavailable.")
            return
        }
        
        // Define the data types that may be written and read from HealthKit.
        let readTypes: Set<HKObjectType> = [biologicalSexType, dateOfBirthType, heightType, bodyMassType]
        let writeTypes: Set<HKSampleType> = [heightType, bodyMassType]

        // Check if HealthKit is available
        if HKHealthStore.isHealthDataAvailable() {
            healthStore.requestAuthorization(toShare: writeTypes, read: readTypes) { success, error in
                if success {
                    DispatchQueue.main.async {
                        fetchDataFromHealthKit()
                    }
                } else {
                    print("Error accessing HealthKit: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        } else {
            print("HealthKit is not available on this device.")
        }
    }
    
    private func fetchDataFromHealthKit() {
        let dispatchGroup = DispatchGroup()
        var weight = ""
        var height = ""
        var age = ""
        var sex = ""

        // Fetch Height
        if let heightType = HKSampleType.quantityType(forIdentifier: .height) {
            dispatchGroup.enter()
            fetchMostRecentSample(for: heightType) { sample, error in
                if let sample = sample as? HKQuantitySample {
                    let meters = sample.quantity.doubleValue(for: HKUnit.meter())
                    height = String(format: "%.2f", meters)
                }
                dispatchGroup.leave()
            }
        }
        
        // Fetch Weight
        if let weightType = HKSampleType.quantityType(forIdentifier: .bodyMass) {
            dispatchGroup.enter()
            fetchMostRecentSample(for: weightType) { sample, error in
                if let sample = sample as? HKQuantitySample {
                    let kilograms = sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
                    weight = String(format: "%.2f", kilograms)
                }
                dispatchGroup.leave()
            }
        }
        
        // Fetch Biological Sex
        dispatchGroup.enter()
        do {
            let biologicalSex = try healthStore.biologicalSex().biologicalSex
            sex = biologicalSex.stringRepresentation()
        } catch {
            print("Error fetching biological sex: \(error.localizedDescription)")
        }
        dispatchGroup.leave()
        
        // Fetch Age (Date of Birth)
        dispatchGroup.enter()
        do {
            let birthdayComponents = try healthStore.dateOfBirthComponents()
            let calendar = Calendar.current
            let ageComponents = calendar.dateComponents([.year], from: birthdayComponents.date ?? Date(), to: Date())
            age = "\(ageComponents.year ?? 0)"
        } catch {
            print("Error fetching date of birth: \(error.localizedDescription)")
        }
        dispatchGroup.leave()
        
        // Once all data is fetched, update the UI
        dispatchGroup.notify(queue: .main) {
            onFetchComplete?(age, weight, height, sex)
            isPresented = false
        }
    }
    
    private func fetchMostRecentSample(for sampleType: HKSampleType, completion: @escaping (HKSample?, Error?) -> Void) {
        let mostRecentPredicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date(), options: .strictEndDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: sampleType, predicate: mostRecentPredicate, limit: 1, sortDescriptors: [sortDescriptor]) { _, samples, error in
            DispatchQueue.main.async {
                completion(samples?.first, error)
            }
        }
        
        healthStore.execute(query)
    }
}

extension HKBiologicalSex {
    func stringRepresentation() -> String {
        switch self {
        case .female: return "Female"
        case .male: return "Male"
        case .other: return "Other"
        default: return "Not Set"
        }
    }
}

struct HealthKitConsentView_Previews: PreviewProvider {
    static var previews: some View {
        HealthKitConsentView(isPresented: .constant(true), onFetchComplete: { _, _, _, _ in })
    }
}

