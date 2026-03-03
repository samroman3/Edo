//
//  DiaryView.swift
//  caloriecounter
//
//  Created by Sam Roman on 12/5/23.
//

import SwiftUI
import UIKit

struct DiaryView: View {
    @EnvironmentObject private var dailyLogManager: DailyLogManager
    @EnvironmentObject private var mealSelectionViewModel: MealSelectionViewModel
    @EnvironmentObject private var nutritionDataStore: NutritionDataStore
    
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center) {
                MealsView(dailyLogManager: dailyLogManager, mealSelectionViewModel: mealSelectionViewModel, nutritionDataStore: nutritionDataStore)
                    .frame(maxWidth: .infinity)
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $mealSelectionViewModel.showingAddItemForm) {
                
                AddItemFormView(
                    isPresented: $mealSelectionViewModel.showingAddItemForm,
                    selectedDate: dailyLogManager.selectedDate,
                    mealType: $mealSelectionViewModel.currentMealType,
                    dataStore: nutritionDataStore,
                    onDismiss: {
                        dailyLogManager.refreshData()
                    }).presentationBackground(Material.ultraThickMaterial)
                
            }
            .sheet(item: $mealSelectionViewModel.selectedEntry) { entry in
                NutritionEntryDetailView(
                    entry: entry,
                    dataStore: nutritionDataStore,
                    onSave: {
                        dailyLogManager.refreshData()
                        mealSelectionViewModel.clearSelectedEntry()
                    },
                    onDelete: {
                        dailyLogManager.refreshData()
                        mealSelectionViewModel.clearSelectedEntry()
                    }
                )
                .presentationBackground(Material.ultraThickMaterial)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Ensures NavigationView uses the full width on iPads
    }}

struct NutritionEntryDetailView: View {
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var entry: NutritionEntry
    let dataStore: NutritionDataStore
    let onSave: () -> Void
    let onDelete: () -> Void

    @State private var name: String
    @State private var calories: String
    @State private var protein: String
    @State private var carbs: String
    @State private var fat: String
    @State private var userNotes: String
    @State private var isFavorite: Bool
    @State private var validationMessage: String?

    private var mealImage: UIImage? {
        guard !entry.mealPhoto.isEmpty else {
            return nil
        }
        return UIImage(data: entry.mealPhoto)
    }

    init(entry: NutritionEntry, dataStore: NutritionDataStore, onSave: @escaping () -> Void, onDelete: @escaping () -> Void) {
        self.entry = entry
        self.dataStore = dataStore
        self.onSave = onSave
        self.onDelete = onDelete
        _name = State(initialValue: entry.name)
        _calories = State(initialValue: String(format: "%.1f", entry.calories))
        _protein = State(initialValue: String(format: "%.1f", entry.protein))
        _carbs = State(initialValue: String(format: "%.1f", entry.carbs))
        _fat = State(initialValue: String(format: "%.1f", entry.fat))
        _userNotes = State(initialValue: entry.userNotes)
        _isFavorite = State(initialValue: entry.isFavorite)
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Food")
                            .font(AppTheme.standardBookCaption)
                            .foregroundStyle(AppTheme.textColor.opacity(0.7))

                        if let mealImage {
                            Image(uiImage: mealImage)
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity)
                                .frame(height: 180)
                                .clipShape(RoundedRectangle(cornerRadius: 22))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 22)
                                        .stroke(AppTheme.grayLight.opacity(0.7), lineWidth: 1)
                                )
                        }

                        TextField("Name", text: $name)
                            .font(AppTheme.standardBookTitle)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(AppTheme.reverse)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(AppTheme.grayLight.opacity(0.8), lineWidth: 1)
                            )

                        Toggle("Favorite", isOn: $isFavorite)
                            .toggleStyle(SwitchToggleStyle(tint: AppTheme.carrot))
                            .font(AppTheme.standardBookBody)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(AppTheme.reverse)
                            )
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Macros")
                            .font(AppTheme.standardBookCaption)
                            .foregroundStyle(AppTheme.textColor.opacity(0.7))

                        macroField(title: "Calories", value: $calories, tint: AppTheme.sageGreen)
                        macroField(title: "Protein", value: $protein, tint: AppTheme.lavender)
                        macroField(title: "Carbs", value: $carbs, tint: AppTheme.goldenrod)
                        macroField(title: "Fats", value: $fat, tint: AppTheme.carrot)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes")
                            .font(AppTheme.standardBookCaption)
                            .foregroundStyle(AppTheme.textColor.opacity(0.7))
                        TextField("Add notes", text: $userNotes, axis: .vertical)
                            .font(AppTheme.standardBookBody)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(AppTheme.reverse)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(AppTheme.grayLight.opacity(0.8), lineWidth: 1)
                            )
                    }

                    if let validationMessage {
                        Text(validationMessage)
                            .font(AppTheme.standardBookCaption)
                            .foregroundStyle(.red)
                    }

                    Button(action: {
                        saveChanges()
                    }) {
                        Text("Save Changes")
                            .font(AppTheme.standardBookBody)
                            .foregroundStyle(AppTheme.prunes)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppTheme.sageGreen)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                    }
                    .buttonStyle(.plain)
                    .contentShape(RoundedRectangle(cornerRadius: 18))

                    Button(action: {
                        dataStore.deleteEntry(entry)
                        onDelete()
                        dismiss()
                    }) {
                        Text("Delete Item")
                            .font(AppTheme.standardBookBody)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppTheme.carrot)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                    }
                    .buttonStyle(.plain)
                    .contentShape(RoundedRectangle(cornerRadius: 18))
                }
                .padding()
            }
            .navigationTitle("Item Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundStyle(AppTheme.textColor)
                }
            }
        }
    }

    private func macroField(title: String, value: Binding<String>, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(AppTheme.standardBookBody)
                Spacer()
                Circle()
                    .fill(tint)
                    .frame(width: 10, height: 10)
            }
            TextField("0", text: value)
                .keyboardType(.decimalPad)
                .font(AppTheme.standardBookBody)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(tint.opacity(0.14))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(tint.opacity(0.45), lineWidth: 1)
                )
        }
    }

    private func saveChanges() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            validationMessage = "Name is required."
            return
        }

        guard
            let caloriesValue = Double(calories),
            let proteinValue = Double(protein),
            let carbsValue = Double(carbs),
            let fatValue = Double(fat)
        else {
            validationMessage = "Use numbers only for calories and macros."
            return
        }

        validationMessage = nil
        dataStore.updateEntry(
            entry,
            name: trimmedName,
            calories: caloriesValue,
            protein: proteinValue,
            carbs: carbsValue,
            fat: fatValue,
            userNotes: userNotes,
            isFavorite: isFavorite
        )
        onSave()
        dismiss()
    }
}
