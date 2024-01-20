//
//  AddItemFormView.swift
//  caloriecounter
//
//  Created by Sam Roman on 11/24/23.
//

import SwiftUI

struct AddItemFormView: View {
    @Binding var isPresented: Bool
    var selectedDate: Date
    @Binding var mealType: String
    @State private var name: String = "Enter Name..."
    @State private var calories: String = "0"
    @State private var protein: String = "0"
    @State private var carbs: String = "0"
    @State private var fat: String = "0"
    var dataStore: NutritionDataStore
    
    @State private var selectedNutrient: NutrientType?
        @State private var nutrientValues: [NutrientType: String] = [
            .calories: "0",
            .protein: "0",
            .carbs: "0",
            .fat: "0"
        ]
        
        enum NutrientType: String, CaseIterable {
            case calories, protein, carbs, fat
        }

    @FocusState private var isInputActive: Bool
    @FocusState private var isTextFieldFocused: Bool
    @State private var isEditing: Bool = false //for name textfield
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    let onDismiss: () -> Void
    var body: some View {
            VStack() {
                HStack {
                    Button(action: { isPresented = false }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                    }
                    TextField("Enter Name...", text: $name)
                        .focused($isTextFieldFocused)
                        .foregroundColor(.white)
                        .font(.title3)
                        .fontWeight(.light)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .onTapGesture {
                            if !isEditing {
                                // Only clear the text if the TextField is not already being edited.
                                self.name = ""
                            }
                        }
                        .background(Color.black.edgesIgnoringSafeArea([.leading,.trailing]))
                    Image(systemName: "star")
                        .foregroundColor(.yellow)
                }
                .padding(.horizontal)

                // Nutrient input section
                LazyVGrid(columns: columns, spacing: 5) {
                    ForEach(NutrientType.allCases, id: \.self) { nutrient in
                            NutrientInputTile(
                                nutrient: nutrient,
                                value: $nutrientValues[nutrient],
                                isSelected: Binding(
                                    get: { selectedNutrient == nutrient },
                                    set: { _ in selectedNutrient = nutrient }
                                ),
                                isInputActive: _isInputActive
                            )
                        
                    }
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .greatestFiniteMagnitude)
                HStack {
                    TextField("Enter value", text: selectedNutrientTextBinding(), onEditingChanged: { isEditing in
                        self.isEditing = isEditing
                        if isEditing && self.nutrientValues[selectedNutrient!] == "0" {
                            self.nutrientValues[selectedNutrient!] = ""
                        }
                    })
                        .keyboardType(.decimalPad)
                        .focused($isInputActive)
                        .font(.largeTitle)
                        .frame(height: 70)
                        .fontWeight(.light)
                        .padding([.leading, .trailing], 40)
                        .background(Color.black.edgesIgnoringSafeArea(.all))
                        .cornerRadius(10)
                        .foregroundColor(AppTheme.lime)
                   
                }

                // 'Add' button
                Button(action: { addFoodItem(nutrientValues) }) {
                Text("Add")
                }
                .font(.title)
                .fontWeight(.light)
                .frame(height: 70)
                .frame(maxWidth: .infinity)
                .background(AppTheme.carrot)
                .foregroundColor(.white)

            }
            .onAppear {
                // automatically show the keyboard for the 'name' TextField
                    selectedNutrient = .calories
                    self.isTextFieldFocused = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                    name = ""
                })
            }
            .onDisappear{
                self.onDismiss()
            }
            .background(AppTheme.prunes)
        }
       private func selectedNutrientTextBinding() -> Binding<String> {
           Binding<String>(
               get: { self.nutrientValues[self.selectedNutrient ?? .calories] ?? "0" },
               set: { self.nutrientValues[self.selectedNutrient ?? .calories] = $0 }
           )
       }

    struct NutrientInputTile: View {
        let nutrient: AddItemFormView.NutrientType
        @Binding var value: String?
        @Binding var isSelected: Bool
        @FocusState var isInputActive: Bool

        var body: some View {
            Button(action: {
                isSelected = true
                isInputActive = true
            }) {
                HStack(alignment: .center) {
                    VStack(alignment: .center) {
                        HStack {
                            Text(value ?? "")
                            Text("g")
                        }
                        .foregroundColor(isSelected ? .black : AppTheme.lime)
                        .font(.headline)
                        .fontWeight(.light)// Adjust font as needed
                        Text(nutrient.rawValue)
                    }
                    .foregroundColor(isSelected ? .black : .white)
                        .font(.headline)
                        .fontWeight(.light)
                }
                .padding([.vertical])
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(isSelected ? AppTheme.lime : AppTheme.grayDark)
            }
            .focused($isInputActive)
        }
    }
    
    private func addFoodItem(_ nutrientValues: [NutrientType: String]) {
        guard !self.name.isEmpty || self.name != "" else {
            //todo: handle error
            return
        }
        
        guard let caloriesValue = Double(nutrientValues[.calories] ?? "0"),
              let proteinValue = Double(nutrientValues[.protein] ?? "0"),
              let carbsValue = Double(nutrientValues[.carbs] ?? "0"),
              let fatValue = Double(nutrientValues[.fat] ?? "0") else {
            print("invalid input")
            return
        }

        dataStore.addEntryToMealAndDailyLog(date: selectedDate, mealType: mealType, name: name, calories: caloriesValue, protein: proteinValue, carbs: carbsValue, fat: fatValue)
        print("adding food entry: name: \(name), type:\(mealType) , cals:\(caloriesValue), protein:\(proteinValue), carbs: \(carbsValue), fat: \(fatValue)")
        
        self.isPresented = false
        return
    }
    
   }
