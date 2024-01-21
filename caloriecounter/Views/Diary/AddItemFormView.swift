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
    
    @State private var additionalNutrients: [String: Double] = [:]
    @State private var userNote: String = ""
    @State private var mealPhoto: UIImage?
    @State private var showImagePicker = false
    @State private var microNutrientsExpanded = false
    @State private var selectedNutrient: MacroNutrientType?
    @State private var macroNutrientValues: [MacroNutrientType: String] = [
        .calories: "0",
        .protein: "0",
        .carbs: "0",
        .fat: "0"
    ]
    
    @FocusState private var focusedField: FocusableField?
    
    enum FocusableField {
        case name, nutrientInput
    }
    
    enum MacroNutrientType: String, CaseIterable {
        case calories, protein, carbs, fat
    }
    
    let vitaminsList: [AdditionalNutrient] = [
        AdditionalNutrient(name: "Vitamin A"),
        AdditionalNutrient(name: "Vitamin C"),
        AdditionalNutrient(name: "Vitamin D"),
        AdditionalNutrient(name: "Vitamin E"),
        AdditionalNutrient(name: "Vitamin K"),
        AdditionalNutrient(name: "Vitamin B6"),
        AdditionalNutrient(name: "Vitamin B12"),
        AdditionalNutrient(name: "Folate")
    ]
    
    let mineralsList: [AdditionalNutrient] = [
        AdditionalNutrient(name: "Calcium"),
        AdditionalNutrient(name: "Iron"),
        AdditionalNutrient(name: "Magnesium"),
        AdditionalNutrient(name: "Phosphorus"),
        AdditionalNutrient(name: "Potassium"),
        AdditionalNutrient(name: "Sodium"),
        AdditionalNutrient(name: "Zinc")
    ]
    
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
                ForEach(MacroNutrientType.allCases, id: \.self) { nutrient in
                    MacroNutrientInputTile(
                        nutrient: nutrient,
                        value: $macroNutrientValues[nutrient],
                        isSelected: Binding(
                            get: { selectedNutrient == nutrient },
                            set: { _ in selectedNutrient = nutrient }
                        ),
                        isInputActive: _isInputActive
                    )
                    
                }
                
            }
            .frame(maxWidth: .infinity, maxHeight: .greatestFiniteMagnitude)
            Divider().background(AppTheme.lime)
            if microNutrientsExpanded {
                // Vitamins and Minerals form section
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHGrid(rows: [GridItem(.flexible())]) {
                        if microNutrientsExpanded {
                            ForEach(vitaminsList) { vitamin in
                                AdditionalNutrientInputRow(nutrient: vitamin, additionalNutrients: $additionalNutrients)
                                    .background(AppTheme.coral)
                            }
                            
                            ForEach(mineralsList) { mineral in
                                AdditionalNutrientInputRow(nutrient: mineral, additionalNutrients: $additionalNutrients)
                            }
                            
                        }
                    }
                    .frame(height: 150) // Set the frame height according to ui?
                    .onTapGesture {
                        withAnimation { microNutrientsExpanded.toggle() }
                    }
                }
                Form {
                    Section(header: Text("User Note")) {
                        TextField("Enter a note...", text: $userNote)
                    }
                    
                    Section {
                        Button(action: {
                            self.showImagePicker.toggle()
                        }) {
                            mealPhoto.map { image in
                                Image(uiImage: image)
                                    .resizable()
                            } ?? Image(systemName: "photo.badge.plus.fill")
                        }
                    }
                }
            }
            HStack {
                TextField("Enter value", text: selectedNutrientTextBinding(), onEditingChanged: { isEditing in
                    self.isEditing = isEditing
                    if isEditing && self.macroNutrientValues[selectedNutrient!] == "0" {
                        self.macroNutrientValues[selectedNutrient!] = ""
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
            if focusedField == nil {
                Button(action: { addFoodItem(macroNutrientValues) }) {
                    Text("Add")
                        .font(.title)
                        .fontWeight(.light)
                        .frame(height: 70)
                        .frame(maxWidth: .infinity)
                        .background(AppTheme.carrot)
                        .foregroundColor(.white)
                }
            }
        }
        .gesture(
            DragGesture().onChanged { value in
                // Check if the drag is a downward swipe
                if value.translation.height > 0 {
                    // Dismiss the keyboard
                    focusedField = nil
                }
            }
        )
        .onTapGesture {
            focusedField = nil
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: self.$mealPhoto)
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
               get: { self.macroNutrientValues[self.selectedNutrient ?? .calories] ?? "0" },
               set: { self.macroNutrientValues[self.selectedNutrient ?? .calories] = $0 }
           )
       }
        

    struct MacroNutrientInputTile: View {
        let nutrient: AddItemFormView.MacroNutrientType
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
    
    private func addFoodItem(_ nutrientValues: [MacroNutrientType: String]) {
        guard !self.name.isEmpty || self.name != "" else {
            //todo: handle error
            return
        }
        //macros
        guard let caloriesValue = Double(nutrientValues[.calories] ?? "0"),
              let proteinValue = Double(nutrientValues[.protein] ?? "0"),
              let carbsValue = Double(nutrientValues[.carbs] ?? "0"),
              let fatValue = Double(nutrientValues[.fat] ?? "0") else {
            print("invalid input")
            return
        }
        
            dataStore.addEntryToMealAndDailyLog(
                date: selectedDate,
                mealType: mealType,
                name: name,
                calories: Double(macroNutrientValues[.calories] ?? "0") ?? 0,
                protein: Double(macroNutrientValues[.protein] ?? "0") ?? 0,
                carbs: Double(macroNutrientValues[.carbs] ?? "0") ?? 0,
                fat: Double(macroNutrientValues[.fat] ?? "0") ?? 0,
                sugars: 0,
                addedSugars: 0,
                cholesterol: 0,
                sodium: 0,
                vitamins: [:],
                minerals: [:],
                servingSize: "1 serving",
                foodGroup: "Grains",
                userNotes: userNote,
                mealPhoto: mealPhoto?.jpegData(compressionQuality: 1.0) ?? Data(),
                mealPhotoLink: "" //TODO: generate a link
            )
        print("adding food entry: name: \(name), type:\(mealType) , cals:\(caloriesValue), protein:\(proteinValue), carbs: \(carbsValue), fat: \(fatValue)")
        
        self.isPresented = false
        return
    }
    
   }

struct AdditionalNutrientInputRow: View {
    let nutrient: AdditionalNutrient
    @Binding var additionalNutrients: [String: Double]

    var body: some View {
        HStack {
            Text(nutrient.name)
                .foregroundStyle(AppTheme.milk)
            Spacer()
            TextField("0.0", value: $additionalNutrients[nutrient.name], formatter: NumberFormatter())
                .keyboardType(.decimalPad)
        }
    }
}

struct AdditionalNutrient: Identifiable {
    let id = UUID()
    let name: String
}
