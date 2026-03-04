//
//  MealsView.swift
//  caloriecounter
//
//  Created by Sam Roman on 11/26/23.
//

import SwiftUI
import UniformTypeIdentifiers

struct MealsView: View {
    
    @ObservedObject var dailyLogManager: DailyLogManager
    @ObservedObject var mealSelectionViewModel: MealSelectionViewModel
    @ObservedObject var nutritionDataStore: NutritionDataStore
    
    @Environment(\.colorScheme) var colorScheme
    
    func calculateTotalCalories(entries: [NutritionEntry]) -> Double {
        // Logic to calculate total calories
        entries.reduce(0) { $0 + Double($1.calories) }
    }
    
    func calculateTotalCarbs(entries: [NutritionEntry]) -> Double {
        // Logic to calculate total carbs
        entries.reduce(0) { $0 + Double($1.carbs) }
    }

    func calculateTotalFats(entries: [NutritionEntry]) -> Double {
        // Logic to calculate total fats
        entries.reduce(0) { $0 + Double($1.fat) }
    }

    func calculateTotalProtein(entries: [NutritionEntry]) -> Double {
        // Logic to calculate total protein
        entries.reduce(0) { $0 + Double($1.protein) }
    }
    
    
    
    @State private var expandedStates: [MealType: Bool] = Dictionary(uniqueKeysWithValues: MealType.allCases.map { ($0, true) })
    
    var body: some View {
        VStack {
            ScrollView{
                Divider().background(AppTheme.textColor)
                ForEach(MealType.allCases, id: \.self) { mealType in
                    let isExpandedBinding = Binding(
                        get: { self.expandedStates[mealType, default: true] },
                        set: { self.expandedStates[mealType] = $0 }
                    )
                    if let meal = dailyLogManager.meals.first(where: { $0.type == mealType.rawValue }) {
                        let entries = Array(meal.entries as? Set<NutritionEntry> ?? []).sorted { n1, n2 in
                            if n1.timestamp != n2.timestamp {
                                return n1.timestamp > n2.timestamp
                            }
                            if n1.name != n2.name {
                                return n1.name.localizedCaseInsensitiveCompare(n2.name) == .orderedAscending
                            }
                            return n1.id.uuidString < n2.id.uuidString
                        }
                        MealCardView(
                            mealType: mealType.displayName,
                            entries: entries,
                            isExpanded: isExpandedBinding,
                            onAddTapped: { mealSelectionViewModel.selectMealType(mealType.rawValue)},
                            onEntryTapped: { entry in
                                mealSelectionViewModel.selectEntry(entry)
                            },
                            onDropEntry: { entryID in
                                moveEntry(entryID, to: mealType)
                            }
                        )

                        if !entries.isEmpty {
                            ChevronView(isExpanded: isExpandedBinding, 
                            totalCalories: calculateTotalCalories(entries: entries), 
                                        totalProtein: calculateTotalProtein(entries: entries), 
                                        totalCarbs: calculateTotalCarbs(entries: entries),
                            totalFats: calculateTotalFats(entries: entries))
                                .padding(.horizontal)
                        }
                        Divider().background(AppTheme.textColor)
                    }
                    else {
                        if mealType == .water {
                            WaterIntakeView(viewModel: WaterIntakeViewModel(dailyLogManager: dailyLogManager, nutritionDataStore: nutritionDataStore))
                        } else {
                            PlaceholderMealView(
                                mealType: mealType.displayName,
                                onAddTapped: { mealSelectionViewModel.selectMealType(mealType.rawValue) },
                                onDropEntry: { entryID in
                                    moveEntry(entryID, to: mealType)
                                }
                            )
                        }
                        Divider().background(AppTheme.textColor)
                        
                    }
                    
                }
            }
            .background(Color.clear)
        }
        .background(Color.clear)
    }
    private func moveEntry(_ entryID: UUID, to mealType: MealType) -> Bool {
        guard mealType != .water, let entry = nutritionDataStore.entry(with: entryID) else {
            return false
        }

        withAnimation {
            nutritionDataStore.moveEntry(entry, to: mealType.rawValue, on: dailyLogManager.selectedDate)
            dailyLogManager.refreshData()
        }

        return true
    }
    
    struct PlaceholderMealView: View {
        let mealType: String
        var onAddTapped: () -> Void
        var onDropEntry: (UUID) -> Bool
        @State private var isDropTargeted = false
        
        var body: some View {
            VStack() {
                HStack {
                    Text(mealType)
                        .font(AppTheme.standardBookLargeTitle)
                    Spacer()
                    Button(action:{
                        let _ = HapticFeedbackProvider.impact()
                        onAddTapped()
                           }) {
                        Image(systemName: "plus")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .foregroundStyle(AppTheme.textColor)
                    }
                    .padding(.vertical)
                }
                .padding(.horizontal)
                .contentShape(Rectangle())
                .onTapGesture {
                    onAddTapped()
                }
            }
            .padding(.vertical, 8)
            .background(isDropTargeted ? AppTheme.grayLight.opacity(0.25) : .clear)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .onDrop(of: [UTType.plainText], isTargeted: $isDropTargeted) { providers in
                handleDrop(providers: providers)
            }
        }

        private func handleDrop(providers: [NSItemProvider]) -> Bool {
            guard let provider = providers.first,
                  provider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) else {
                return false
            }

            provider.loadDataRepresentation(forTypeIdentifier: UTType.plainText.identifier) { data, _ in
                guard let data,
                      let identifier = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
                      let entryID = UUID(uuidString: identifier) else {
                    return
                }

                DispatchQueue.main.async {
                    if onDropEntry(entryID) {
                        HapticFeedbackProvider.impact()
                    }
                }
            }

            return true
        }
    }
  
}
