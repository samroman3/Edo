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
            ZStack {
                ThemedAppBackground()

                VStack(alignment: .center) {
                    MealsView(dailyLogManager: dailyLogManager, mealSelectionViewModel: mealSelectionViewModel, nutritionDataStore: nutritionDataStore)
                        .frame(maxWidth: .infinity)
                }
            }
            .background(Color.clear)
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
        .background(Color.clear)
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
    @State private var servingSize: String
    @State private var servingUnit: String
    @State private var userNotes: String
    @State private var isFavorite: Bool
    @State private var validationMessage: String?
    @State private var entryImages: [UIImage]
    @State private var originalImageSignatures: [Data]
    @State private var selectedPickerImage: UIImage?
    @State private var isShowingImagePicker = false
    @State private var pendingReplacementIndex: Int?
    @State private var showCloseConfirmation = false

    private let servingUnits = ["Serving", "Grams", "Ounces", "Cups", "Pieces", "Slices"]

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
        _servingSize = State(initialValue: entry.servingSize)
        _servingUnit = State(initialValue: entry.servingUnit.isEmpty ? "Serving" : entry.servingUnit)
        _userNotes = State(initialValue: entry.userNotes)
        _isFavorite = State(initialValue: entry.isFavorite)
        let startingImages = NutritionDataStore.storedImageData(for: entry).compactMap { UIImage(data: $0) }
        _entryImages = State(initialValue: startingImages)
        _originalImageSignatures = State(initialValue: startingImages.compactMap { $0.pngData() })
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Food")
                            .font(AppTheme.standardBookCaption)
                            .foregroundStyle(AppTheme.textColor.opacity(0.7))

                        if !entryImages.isEmpty {
                            HStack(alignment: .top, spacing: 12) {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(Array(entryImages.enumerated()), id: \.offset) { index, image in
                                            imageCard(image: image, index: index)
                                        }
                                    }
                                    .padding(.vertical, 2)
                                }

                                if entryImages.count < 4 {
                                    Button(action: {
                                        presentImagePicker(for: nil)
                                    }) {
                                        Image(systemName: "plus")
                                            .font(.system(size: 20, weight: .semibold))
                                            .foregroundStyle(AppTheme.textColor)
                                            .frame(width: 48, height: 48)
                                            .background(AppTheme.reverse)
                                            .clipShape(RoundedRectangle(cornerRadius: 16))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .stroke(AppTheme.grayLight.opacity(0.8), lineWidth: 1)
                                            )
                                    }
                                    .buttonStyle(.plain)
                                    .padding(.top, 12)
                                }
                            }
                        } else {
                            Button(action: {
                                presentImagePicker(for: nil)
                            }) {
                                HStack(spacing: 10) {
                                    Image(systemName: "photo.badge.plus")
                                    Text("Add Photo")
                                }
                                .font(AppTheme.standardBookBody)
                                .foregroundStyle(AppTheme.textColor)
                                .frame(maxWidth: .infinity)
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
                            .buttonStyle(.plain)
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
                        Text("Serving")
                            .font(AppTheme.standardBookCaption)
                            .foregroundStyle(AppTheme.textColor.opacity(0.7))

                        HStack(spacing: 12) {
                            TextField("1", text: $servingSize)
                                .keyboardType(.decimalPad)
                                .font(AppTheme.standardBookBody)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(AppTheme.reverse)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(AppTheme.grayLight.opacity(0.8), lineWidth: 1)
                                )
                                .onTapGesture {
                                    if servingSize == "0" || servingSize == "0.0" {
                                        servingSize = ""
                                    }
                                }

                            Picker("Unit", selection: $servingUnit) {
                                ForEach(servingUnits, id: \.self) { unit in
                                    Text(unit).tag(unit)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(AppTheme.textColor)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(AppTheme.reverse)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(AppTheme.grayLight.opacity(0.8), lineWidth: 1)
                            )
                        }
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
                        addAgain()
                    }) {
                        Text("Add Again")
                            .font(AppTheme.standardBookBody)
                            .foregroundStyle(AppTheme.textColor)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppTheme.reverse)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(AppTheme.grayLight.opacity(0.8), lineWidth: 1)
                            )
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
                        requestClose()
                    }
                    .foregroundStyle(AppTheme.textColor)
                }
            }
        }
        .interactiveDismissDisabled(hasUnsavedChanges)
        .sheet(isPresented: $isShowingImagePicker) {
            ImagePicker(image: $selectedPickerImage)
        }
        .onChange(of: selectedPickerImage) { _, newImage in
            guard let newImage else {
                return
            }
            applySelectedImage(newImage)
        }
        .confirmationDialog("You have unsaved changes.", isPresented: $showCloseConfirmation, titleVisibility: .visible) {
            Button("Save and Close") {
                saveChanges()
            }
            Button("Exit Without Saving", role: .destructive) {
                dismiss()
            }
            Button("Keep Editing", role: .cancel) { }
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
                .onTapGesture {
                    if value.wrappedValue == "0" || value.wrappedValue == "0.0" {
                        value.wrappedValue = ""
                    }
                }
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
            servingSize: servingSize.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "1" : servingSize,
            servingUnit: servingUnit,
            userNotes: userNotes,
            isFavorite: isFavorite,
            imageData: currentImageData
        )
        onSave()
        dismiss()
    }

    private func imageCard(image: UIImage, index: Int) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(width: 220, height: 220)
                .background(
                    RoundedRectangle(cornerRadius: 22)
                        .fill(AppTheme.reverse)
                )
                .clipShape(RoundedRectangle(cornerRadius: 22))
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(AppTheme.grayLight.opacity(0.7), lineWidth: 1)
                )

            HStack(spacing: 10) {
                if index == 0 {
                    Image(systemName: "star.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(AppTheme.sageGreen)
                }

                Spacer()
                imageActionButton(systemImage: "arrow.triangle.2.circlepath.circle.fill", tint: AppTheme.prunes) {
                    presentImagePicker(for: index)
                }
                if index != 0 {
                    imageActionButton(systemImage: "arrow.up.circle.fill", tint: AppTheme.sageGreen) {
                        moveImageToFront(from: index)
                    }
                }
                imageActionButton(systemImage: "trash.circle.fill", tint: AppTheme.carrot) {
                    removeImage(at: index)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(AppTheme.reverse.opacity(0.82))
        )
    }

    private func presentImagePicker(for index: Int?) {
        pendingReplacementIndex = index
        selectedPickerImage = nil
        isShowingImagePicker = true
    }

    private func applySelectedImage(_ image: UIImage) {
        if let index = pendingReplacementIndex, entryImages.indices.contains(index) {
            entryImages[index] = image
        } else if entryImages.count < 4 {
            entryImages.append(image)
        }

        pendingReplacementIndex = nil
        selectedPickerImage = nil
    }

    private func moveImageToFront(from index: Int) {
        guard entryImages.indices.contains(index) else {
            return
        }

        let image = entryImages.remove(at: index)
        entryImages.insert(image, at: 0)
    }

    private func removeImage(at index: Int) {
        guard entryImages.indices.contains(index) else {
            return
        }

        entryImages.remove(at: index)
    }

    private var currentImageData: [Data] {
        entryImages.compactMap { $0.jpegData(compressionQuality: 0.9) }
    }

    private var hasUnsavedChanges: Bool {
        let currentImageSignatures = entryImages.compactMap { $0.pngData() }
        return name != entry.name ||
        calories != String(format: "%.1f", entry.calories) ||
        protein != String(format: "%.1f", entry.protein) ||
        carbs != String(format: "%.1f", entry.carbs) ||
        fat != String(format: "%.1f", entry.fat) ||
        servingSize != entry.servingSize ||
        servingUnit != (entry.servingUnit.isEmpty ? "Serving" : entry.servingUnit) ||
        userNotes != entry.userNotes ||
        isFavorite != entry.isFavorite ||
        currentImageSignatures != originalImageSignatures
    }

    private func requestClose() {
        if hasUnsavedChanges {
            showCloseConfirmation = true
        } else {
            dismiss()
        }
    }

    private func addAgain() {
        let meal = entry.meals
        guard let mealType = meal.type,
              let mealDate = meal.date else {
            validationMessage = "This item could not be added again right now."
            return
        }

        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty,
              let caloriesValue = Double(calories),
              let proteinValue = Double(protein),
              let carbsValue = Double(carbs),
              let fatValue = Double(fat) else {
            validationMessage = "Save valid values before adding this again."
            return
        }

        dataStore.addEntryToMealAndDailyLog(
            date: mealDate,
            mealType: mealType,
            name: trimmedName,
            calories: caloriesValue,
            protein: proteinValue,
            carbs: carbsValue,
            fat: fatValue,
            servingUnit: servingUnit,
            servingSize: servingSize.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "1" : servingSize,
            userNotes: userNotes,
            mealPhoto: currentImageData.first ?? Data(),
            mealPhotoLink: NutritionDataStore.encodedImageMetadata(from: currentImageData),
            isFavorite: isFavorite
        )
        onSave()
        dismiss()
    }

    private func imageActionButton(systemImage: String, tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 22))
                .foregroundStyle(tint)
                .frame(width: 34, height: 34)
                .background(AppTheme.reverse)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
}
