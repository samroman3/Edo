//
//  WaterIntakeView.swift
//  caloriecounter
//
//  Created by Sam Roman on 1/19/24.
//

import SwiftUI


class WaterIntakeViewModel: ObservableObject {
    @Published var currentIntake: Double = 0.0
    @Published var goalIntake: Double = 2.7
    @Published var glassSize: Double = 0.3
    @ObservedObject var dailyLogManager: DailyLogManager
    @ObservedObject var nutritionDataStore: NutritionDataStore
    
    var goalMet: Bool {
        round(currentIntake) >= round(goalIntake)
    }
    
    init(dailyLogManager: DailyLogManager, nutritionDataStore: NutritionDataStore) {
        self.dailyLogManager = dailyLogManager
        self.nutritionDataStore = nutritionDataStore
        self.currentIntake = dailyLogManager.waterIntake
        print(dailyLogManager.waterIntake)
    }
    
    func addWater() {
        if currentIntake + glassSize <= goalIntake {
            currentIntake += glassSize
            self.nutritionDataStore.updateWaterIntake(intake: currentIntake, date: self.dailyLogManager.selectedDate)
        }
    }
    func deleteWater() {
        if currentIntake > 0.0 {
            currentIntake -= glassSize
            self.nutritionDataStore.updateWaterIntake(intake: currentIntake, date: self.dailyLogManager.selectedDate)
        }
    }
    
    func resetWaterIntake() {
        currentIntake = 0.0
        self.nutritionDataStore.resetWaterIntake(date: self.dailyLogManager.selectedDate)
    }
    
    
}

struct WaterIntakeView: View {
    @ObservedObject var viewModel: WaterIntakeViewModel
    
    var body: some View {
        VStack {
            HStack {
                Text("Water")
                    .font(.largeTitle)
                    .fontWeight(.light)
                    .foregroundStyle(AppTheme.textColor)
                Spacer()
                if viewModel.goalMet {
                    Button(action: {
                        withAnimation {
                            viewModel.resetWaterIntake()
                        }
                    }) {
                        Image(systemName: "arrow.counterclockwise.circle")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(AppTheme.textColor)
                    }
                } else {
                    Button(action: {
                        let _ = HapticFeedbackProvider.impact()
                        withAnimation {
                            viewModel.addWater()
                        }
                    }) {
                        Image(systemName: "plus")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .foregroundColor(AppTheme.textColor)
                    }
                    .padding(.vertical)
                }
            }
            .padding(.horizontal)
            .contentShape(Rectangle())
            
            
            HStack {
                ForEach(1..<Int(ceil(viewModel.goalIntake / viewModel.glassSize)), id: \.self) { glassIndex in
                    Image(systemName: viewModel.currentIntake >= (Double(glassIndex)) * viewModel.glassSize ? "drop.circle.fill" : "drop.circle")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(viewModel.currentIntake >= (Double(glassIndex)) * viewModel.glassSize ? AppTheme.skyBlue : AppTheme.grayLight)
                        .onTapGesture(perform: {
                            
                        })
                }
                
            }
            
            if viewModel.goalMet {
                Text("Water intake goal reached. \n Water needs are approximate, keep hydrated.")
                    .foregroundStyle(AppTheme.grayDark)
                    .multilineTextAlignment(.center)
                    .font(.caption)
                    .padding(.bottom, 5)
            }
            
            Text("\(viewModel.currentIntake, specifier: "%.1f") out of \(viewModel.goalIntake.formattedAsPrettyString()) L")
                .foregroundColor(AppTheme.textColor)
                .font(.caption)
                .padding(.bottom, 5)
            
            Text("One glass of water ≈ \((viewModel.glassSize * 1000).formattedAsPrettyString()) ml")
                .foregroundColor(AppTheme.grayDark)
                .font(.caption)
        }
        .frame(maxWidth: .infinity)
    }
}

