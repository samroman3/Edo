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
        guard let biologicalSexType = HKObjectType.characteristicType(forIdentifier: .biologicalSex),
              let dateOfBirthType = HKObjectType.characteristicType(forIdentifier: .dateOfBirth),
              let heightType = HKObjectType.quantityType(forIdentifier: .height),
              let bodyMassType = HKObjectType.quantityType(forIdentifier: .bodyMass) else {
            // One or more of the required types are unavailable
            return
        }
        
        let readTypes = Set([biologicalSexType, dateOfBirthType, heightType, bodyMassType])
        
        // Check if HealthKit is available
        if HKHealthStore.isHealthDataAvailable() {
            // Request authorization
            healthStore.requestAuthorization(toShare: nil, read: readTypes) { (success, error) in
                if success {
                    fetchDataFromHealthKit()
                } else {
                    print("error accesing healthkit, check permissions")
                }
            }
        }
    }
    private func fetchDataFromHealthKit(){
        let dispatchGroup = DispatchGroup()
        var weight = ""
        var height = ""
        var age = ""
        var sex = ""
        // Fetch Height
        if let heightType = HKSampleType.quantityType(forIdentifier: .height) {
            dispatchGroup.enter()
            fetchMostRecentSample(for: heightType) { (sample, error) in
                height = (sample as? HKQuantitySample)?.quantity.doubleValue(for: HKUnit.meterUnit(with: .centi)).description ?? ""             
                dispatchGroup.leave()
            }
        }
        
        // Fetch Weight
        if let weightType = HKSampleType.quantityType(forIdentifier: .bodyMass) {
            dispatchGroup.enter()
            fetchMostRecentSample(for: weightType) { (sample, error) in
                weight = (sample as? HKQuantitySample)?.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo)).description ?? ""
                dispatchGroup.leave()
            }
        }
        
        // Fetch Biological Sex
        do {
            dispatchGroup.enter()
            let biologicalSex = try healthStore.biologicalSex().biologicalSex
            sex = biologicalSex.stringRepresentation()
            dispatchGroup.leave()
        } catch {
            print("error getting sex")
        }
        
        // Fetch Age (Date of Birth)
        do {
            dispatchGroup.enter()
            let birthdayComponents = try healthStore.dateOfBirthComponents()
            let calendar = Calendar.current
            let ageDate = calendar.dateComponents([.year], from: birthdayComponents.date!, to: Date()).year!
            age = String(ageDate)
            dispatchGroup.leave()
        } catch {
            print("error getting age")
        }
        
        dispatchGroup.notify(queue: .main) {
               self.onFetchComplete?(age, weight, height, sex)
               self.isPresented = false
           }

    }
    
    private func fetchMostRecentSample(for sampleType: HKSampleType, completion: @escaping (HKSample?, Error?) -> Void) {
        let mostRecentPredicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date(), options: .strictEndDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(sampleType: sampleType, predicate: mostRecentPredicate, limit: 1, sortDescriptors: [sortDescriptor]) { query, samples, error in
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

