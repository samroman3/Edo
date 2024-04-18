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
    var dataStore: NutritionDataStore?
    
    @State private var userNote: String = "Enter a note..."
    @State private var mealPhoto: UIImage?
    @State private var showImagePicker = false
    @State private var microNutrientsExpanded = false
    @State private var notesExpanded = false
    @FocusState private var focusedField: FocusableField?
    
    enum FocusableField {
        case name, nutrientInput
    }
    
    @State private var nutrientValues: [NutrientType: String] = [
        .calories: "0", .protein: "0", .carbs: "0", .fat: "0", .vitaminA: "0", .vitaminC: "0", .vitaminD: "0", .vitaminE: "0", .vitaminB6: "0", .vitaminB12: "0", .folate: "0", .calcium: "0", .iron: "0", .magnesium: "0", .phosphorus: "0", .potassium: "0", .sodium: "0", .zinc: "0"
    ]
    
    // Subset for macronutrients
    let macroNutrientTypes: [NutrientType] = [.calories, .protein, .carbs, .fat]
    let additionalVitaminTypes: [NutrientType] = [.vitaminA, .vitaminC, .vitaminD, .vitaminE, .vitaminB6, .vitaminB12, .folate]
    let mineralTypes: [NutrientType] = [.calcium, .iron, .magnesium, .phosphorus, .potassium, .sodium, .zinc]
    
    enum NutrientType: String, CaseIterable {
        case calories, protein, carbs, fat,
             vitaminA, vitaminC, vitaminD, vitaminE, vitaminB6, vitaminB12, folate,
             calcium, iron, magnesium, phosphorus, potassium, sodium, zinc
    }
    
    @State private var selectedNutrient: NutrientType?
    
    
    
    @FocusState private var isInputActive: Bool
    @FocusState private var isNameTextFieldFocused: Bool
    @FocusState private var isUserNoteFocused: Bool
    @State private var isEditing: Bool = false
    let columns: [GridItem] = Array(repeating: .init(.adaptive(minimum: 200, maximum: 500)), count: 2)
    let onDismiss: () -> Void
    var body: some View {
        VStack(spacing: 10) {
            ScrollView(.vertical){
                HStack {
                    Button(action: { isPresented = false }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(AppTheme.textColor)
                    }
                    TextField("Enter Name...", text: $name)
                        .focused($isNameTextFieldFocused)
                        .foregroundColor(AppTheme.textColor)
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
                    Image(systemName: "star")
                        .foregroundColor(.yellow)
                }
                .padding([.horizontal, .vertical])
                if !isUserNoteFocused {
                    // Nutrient input section
                    LazyVGrid(columns: columns, spacing: 5) {
                        ForEach(macroNutrientTypes, id: \.self) { nutrient in
                            MacroNutrientInputTile(
                                nutrient: nutrient,
                                value: $nutrientValues[nutrient],
                                isSelected: Binding(
                                    get: { selectedNutrient == nutrient },
                                    set: { _ in selectedNutrient = nutrient }
                                ),
                                isInputActive: _isInputActive
                            )
                            
                        }
                    }.frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                VStack(alignment: .leading, spacing: 10) {
                    Spacer()
                    if !isUserNoteFocused {
                        Button {
                            microNutrientsExpanded.toggle()
                        } label: {
                            Image(systemName: "chevron.down.circle")
                                .resizable()
                                .frame(width: 35, height: 35)
                                .foregroundStyle(AppTheme.textColor)
                            Text("More")
                                .foregroundStyle(AppTheme.textColor)
                        }
                        if microNutrientsExpanded == true && isNameTextFieldFocused == false {
                            // Vitamins and Minerals form section
                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHGrid(rows: [GridItem(.flexible())]) {
                                    if microNutrientsExpanded {
                                        ForEach(additionalVitaminTypes, id: \.self) { nutrient in
                                            AdditionalNutrientInputRow(nutrient: nutrient, value: $nutrientValues[nutrient], isSelected:  Binding(
                                                get: { selectedNutrient == nutrient },
                                                set: { _ in selectedNutrient = nutrient }
                                            ))
                                            .background(AppTheme.reverse)
                                        }
                                        ForEach(mineralTypes, id: \.self) { nutrient in
                                            AdditionalNutrientInputRow(nutrient: nutrient, value: $nutrientValues[nutrient], isSelected:  Binding(
                                                get: { selectedNutrient == nutrient },
                                                set: { _ in selectedNutrient = nutrient }
                                            ))
                                            .background(AppTheme.coral)
                                        }
                                    }
                                }.frame(height: 150)
                            }
                        }
                    }
                    if isInputActive == false {
                        Button {
                            notesExpanded.toggle()
                        } label: {
                            Image(systemName:"square.and.pencil.circle")
                                .resizable()
                                .frame(width: 35, height: 35)
                                .foregroundStyle(AppTheme.basic)
                            Text("Add Note")
                                .foregroundStyle(AppTheme.basic)
                        }
                        if isNameTextFieldFocused == false && notesExpanded == true {
                            TextField("Enter a note...", text: $userNote)
                                .focused($isUserNoteFocused)
                                .foregroundColor(AppTheme.textColor)
                                .font(.title2)
                                .fontWeight(.light)
                                .multilineTextAlignment(.leading)
                                .lineLimit(0)
                                .padding(.horizontal)
                                .frame(maxWidth:.infinity, maxHeight: .infinity)
                                .background(AppTheme.reverse.edgesIgnoringSafeArea([.leading,.trailing]))
                        }
                        if !isUserNoteFocused {
                            Button {
                                self.showImagePicker.toggle()
                            } label: {
                                Image(systemName: "photo.artframe.circle")
                                    .resizable()
                                    .frame(width: 35, height: 35)
                                    .foregroundStyle(AppTheme.textColor)
                                Text("Add Image")
                                    .foregroundStyle(AppTheme.textColor)
                            }
                        }
                    }
                    
                }
                
                
                //TODO: view for selected image
                //                        mealPhoto.map { image in
                //                            Image(uiImage: image)
                //                                .resizable()
                //                        } ?? Image(systemName: "photo.badge.plus.fill")
                
            }
            HStack {
                if isUserNoteFocused || isNameTextFieldFocused {
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
                    .padding(.horizontal)
                    .foregroundColor(AppTheme.textColor)
                    Spacer()
                    if isInputActive {
                        Button(action: {
                            hideKeyboard()
                        }, label: {
                            Image(systemName: "keyboard.chevron.compact.down")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(AppTheme.textColor)
                        })
                        .padding([.vertical])
                    }
                }
            }
            
            // 'Add' button
            if !keyBoardOpen() {
                Button(action: { addFoodItem(nutrientValues) }) {
                    Text("Add")
                        .font(.title)
                        .fontWeight(.light)
                        .frame(height: 70)
                        .frame(maxWidth: .infinity)
                        .background(AppTheme.lavender)
                        .foregroundColor(.white)
                }
            }
        }
        .gesture(
            DragGesture().onChanged { value in
                // Check if the drag is a downward swipe
                if value.translation.height > 10 {
                    // Dismiss the keyboard
                    focusedField = nil
                    hideKeyboard()
                }
            }
        )
        .onTapGesture {
            focusedField = nil
            hideKeyboard()
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: self.$mealPhoto)
        }
        .onAppear {
            // automatically show the keyboard for the 'name' TextField
            selectedNutrient = .calories
        }
        .onDisappear{
            self.onDismiss()
        }
    }
    
    private func selectedNutrientTextBinding() -> Binding<String> {
        Binding<String>(
            get: { self.nutrientValues[self.selectedNutrient ?? .calories] ?? "0" },
            set: { self.nutrientValues[self.selectedNutrient ?? .calories] = $0 }
        )
    }
    
    struct AdditionalNutrientInputRow: View {
        let nutrient: NutrientType
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
                            Text("mg")
                        }
                        .foregroundColor(isSelected ? AppTheme.reverse : AppTheme.textColor)
                        .font(.headline)
                        .fontWeight(.light)
                        Text(nutrient.rawValue)
                    }
                    .foregroundColor(isSelected ? AppTheme.reverse : AppTheme.textColor)
                    .font(.headline)
                    .fontWeight(.light)
                }
                .padding([.vertical,.horizontal])
                .frame(minWidth: 100, maxHeight: .infinity)
                .background(isSelected ? AppTheme.basic : AppTheme.grayMiddle)
                .clipShape(.rect(cornerRadius: 10))
                .padding(.horizontal, 4)
            }
            .focused($isInputActive)
        }
    }
    
    struct MacroNutrientInputTile: View {
        let nutrient: NutrientType
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
                        .foregroundColor(isSelected ? AppTheme.reverse : AppTheme.basic)
                        .font(.headline)
                        .fontWeight(.bold)
                        Text(nutrient.rawValue)
                    }
                    .foregroundColor(isSelected ? AppTheme.reverse : AppTheme.textColor)
                    .font(.headline)
                    .fontWeight(.light)
                }
                .padding([.vertical,.horizontal],50)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(isSelected ? AppTheme.basic : AppTheme.grayMiddle)
                .clipShape(.rect(cornerRadius: 20))
                .padding()
                .shadow(radius: 4, x: 2, y: 4)
            }
            .focused($isInputActive)
        }
    }
    
    private func keyBoardOpen() -> Bool {
        return focusedField != nil || isInputActive || isNameTextFieldFocused || isUserNoteFocused
    }
    
    enum KeyboardType {
        case numeric
        case alphabet
    }
    private func addFoodItem(_ nutrientValues: [NutrientType: String]) {
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
        
        dataStore?.addEntryToMealAndDailyLog(
            date: selectedDate,
            mealType: mealType,
            name: name,
            calories: Double(nutrientValues[.calories] ?? "0") ?? 0,
            protein: Double(nutrientValues[.protein] ?? "0") ?? 0,
            carbs: Double(nutrientValues[.carbs] ?? "0") ?? 0,
            fat: Double(nutrientValues[.fat] ?? "0") ?? 0,
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
        print("adding food entry: name: \(name), type:\(mealType) , cals:\(caloriesValue), protein:\(proteinValue), carbs: \(carbsValue), fats: \(fatValue)")
        
        self.isPresented = false
        return
    }
    
}

struct AddItemFormView_Previews: PreviewProvider {
    static var previews: some View {
        AddItemFormView(
            isPresented: .constant(true),
            selectedDate: Date(),
            mealType: .constant(""),
            dataStore: nil,
            onDismiss: {}
        )
    }
}
