//
//  AddItemFormView.swift
//  caloriecounter
//
//  Created by Sam Roman on 11/24/23.
//

import SwiftUI

enum NutrientType: String, CaseIterable {
    case calories, protein, carbs, fats,
         vitaminA, vitaminC, vitaminD, vitaminE, vitaminB6, vitaminB12, folate,
         calcium, iron, magnesium, phosphorus, potassium, sodium, zinc
}

struct AddItemFormView: View {
    @Binding var isPresented: Bool
    var selectedDate: Date
    @Binding var mealType: String
    @State private var name: String = ""
    var dataStore: NutritionDataStore?
    let onDismiss: () -> Void
    
    @State private var userNote: String = ""
    @State private var mealPhoto: UIImage?
    @State private var showImageView: Bool = false
    @State private var showImagePicker = false
    @State private var microNutrientsExpanded = false
    @State private var notesExpanded = false
    @State private var servingExpanded = false
    @State private var servingSize: Int = 1
    @State private var selectedUnit: String = "Serving" // Default unit
    let unitsOfMeasurement = ["Serving", "Grams", "Ounces", "Cups", "Pieces", "Slices"]
    @FocusState private var focusedField: FocusableField?
    
    @State private var showingPreviousEntries = false
    @State private var isFavorite: Bool = false // State to track if the item is marked as favorite
    
    enum FocusableField {
        case name, nutrientInput
    }
    
    @State private var nutrientValues: [NutrientType: String] = [
        .calories: "0", .protein: "0", .carbs: "0", .fats: "0", .vitaminA: "0", .vitaminC: "0", .vitaminD: "0", .vitaminE: "0", .vitaminB6: "0", .vitaminB12: "0", .folate: "0", .calcium: "0", .iron: "0", .magnesium: "0", .phosphorus: "0", .potassium: "0", .sodium: "0", .zinc: "0"
    ]
    
    let macroNutrientTypes: [NutrientType] = [.calories, .protein, .carbs, .fats]
    let additionalVitaminTypes: [NutrientType] = [.vitaminA, .vitaminC, .vitaminD, .vitaminE, .vitaminB6, .vitaminB12, .folate]
    let mineralTypes: [NutrientType] = [.calcium, .iron, .magnesium, .phosphorus, .potassium, .sodium, .zinc]

    
    @State private var selectedNutrient: NutrientType?
    
    @FocusState private var isInputActive: Bool
    @FocusState private var isNameTextFieldFocused: Bool
    @FocusState private var isUserNoteFocused: Bool
    @State private var isEditing: Bool = false
    let columns: [GridItem] = Array(repeating: .init(.adaptive(minimum: 200, maximum: 500)), count: 2)
    
    var body: some View {
        VStack(spacing: 10) {
            HStack(alignment: .center){
                Button(action: {
                    withAnimation(.bouncy){
                        isPresented = false
                    }}) {
                    Image(systemName: "chevron.down")
                        .foregroundColor(AppTheme.textColor)
                }.padding([.vertical,.horizontal])
                
            }
            HStack {
                if !isUserNoteFocused {
                    TextField("Enter Name...", text: $name)
                        .focused($isNameTextFieldFocused)
                        .foregroundColor(AppTheme.textColor)
                        .font(.title3)
                        .fontWeight(.light)
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal)
                        .onChange(of: isNameTextFieldFocused,
                                  perform: { isFocused in
                            showingPreviousEntries = isFocused
                        })
                    Button(action: {
                        withAnimation {
                            isFavorite.toggle()
                        }
                    }) {
                        Image(systemName: isFavorite ? "star.circle.fill" : "star")
                            .foregroundColor(isFavorite ? .yellow : .gray)
                    }
                }
            }
            .padding([.horizontal, .vertical])
            if showingPreviousEntries {
                PreviousEntriesView(name: $name,
                                    dataStore: dataStore as? NutritionDataStore,
                                    nutrientValues: $nutrientValues,
                                    userNote: $userNote,
                                    mealPhoto: $mealPhoto,
                                    isFavorite: $isFavorite,
                                    dismiss: {
                    withAnimation{
                        isNameTextFieldFocused.toggle()
                    }
                }
                )
                Spacer()
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
                ZStack(alignment: .bottom){
                    ScrollView(.vertical){
                        if !isUserNoteFocused {
                            // Nutrient input section
                            LazyVGrid(columns: columns, spacing: 3) {
                                ForEach(macroNutrientTypes, id: \.self) { nutrient in
                                    MacroNutrientInputTile(
                                        nutrient: nutrient, addItemEntry: true,
                                        value: $nutrientValues[nutrient],
                                        isSelected: Binding(
                                            get: { selectedNutrient == nutrient },
                                            set: { _ in selectedNutrient = nutrient }
                                        ),
                                        isInputActive: _isInputActive
                                    )
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        VStack(alignment:.center, spacing: 20) {
                            if isInputActive == false {
                                
                                Button {
                                    notesExpanded.toggle()
                                } label: {
                                    Image(systemName:"square.and.pencil.circle")
                                        .resizable()
                                        .frame(width: 35, height: 35)
                                        .foregroundStyle(AppTheme.basic)
                                }
                                if isNameTextFieldFocused == false && notesExpanded == true {
                                    TextField("Enter a note...", text: $userNote)
                                        .focused($isUserNoteFocused)
                                        .foregroundColor(AppTheme.textColor)
                                        .font(.title2)
                                        .fontWeight(.light)
                                        .multilineTextAlignment(.leading)
                                        .padding(.horizontal)
                                        .frame(maxWidth: .infinity, maxHeight: isUserNoteFocused ? .infinity : 100)
                                        .background(AppTheme.reverse.edgesIgnoringSafeArea(.all))
                                        .clipShape(.rect(cornerRadius: 25))
                                }
                                if !isUserNoteFocused {
                                    Button {
                                        withAnimation(.bouncy){
                                            self.servingExpanded.toggle()
                                        }
                                    } label: {
                                        Image(systemName: "fork.knife.circle")
                                            .resizable()
                                            .frame(width: 35, height: 35)
                                            .foregroundStyle(AppTheme.basic)
                                    }
                                    
                                    if servingExpanded {
                                        HStack {
                                            Text("\(servingSize)")
                                                .fontWeight(.light)
                                                .frame(width: 50, alignment: .trailing)
                                            Picker("Unit", selection: $selectedUnit) {
                                                ForEach(unitsOfMeasurement, id: \.self) { unit in
                                                    Text(unit).tag(unit)
                                                }
                                            }
                                            .pickerStyle(MenuPickerStyle())
                                            .tint(AppTheme.textColor)
                                        }
                                        .frame(maxWidth: .infinity)
                                        
                                        Stepper(value: $servingSize, in: 1...20) {
                                            Text("")
                                        }.labelsHidden()
                                    }
                                }
                                if !isUserNoteFocused {
                                    // Button to toggle the visibility of the image view
                                    Button(action: {
                                        self.showImageView.toggle()
                                    }) {
                                        Image(systemName: "photo.artframe.circle")
                                            .resizable()
                                            .frame(width: 35, height: 35)
                                            .foregroundStyle(AppTheme.textColor)
                                    }
                                    if showImageView {
                                        // View for selected image
                                        if let image = mealPhoto {
                                            VStack{
                                                ZStack(alignment: .topTrailing) {
                                                    Image(uiImage: image)
                                                        .resizable()
                                                        .scaledToFill()
                                                        .clipShape(RoundedRectangle(cornerRadius: 30))
                                                    
                                                    Button(action: {
                                                        self.showImageView = false
                                                        self.mealPhoto = nil
                                                    }) {
                                                        Image(systemName: "xmark.circle")
                                                            .foregroundColor(AppTheme.grayDark)
                                                            .padding()
                                                            .frame(maxWidth:30, maxHeight: 30)
                                                            .background(Color.white.opacity(0.9))
                                                            .clipShape(Circle())
                                                    }
                                                }
                                            }
                                        } else {
                                            Button(action: {
                                                self.showImagePicker.toggle() // Show the image picker to add an image
                                            }) {
                                                HStack {
                                                    Spacer()
                                                    Text("+ Add Image")
                                                        .foregroundColor(AppTheme.textColor)
                                                    Spacer()
                                                }
                                                .padding()
                                                .background(RoundedRectangle(cornerRadius: 10).stroke(AppTheme.textColor, lineWidth: 2))
                                            }
                                        }
                                    }
                                }
                            }
                            
                        }.padding(.horizontal)
                        Spacer(minLength: 200)
                    }
                    
                    VStack{
                        
                        HStack {
                            if !isNameTextFieldFocused && !isUserNoteFocused {
                                TextField("Enter value", text: selectedNutrientTextBinding(), onEditingChanged: { isEditing in
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
                            }
                        }
                        
                        // 'Add' button
                        if !keyBoardOpen() {
                            Button(action: { addFoodItem(nutrientValues)
                                onDismiss()
                                isPresented = false
                            }) {
                                Text("Add +")
                                    .font(.title)
                                    .fontWeight(.light)
                                    .frame(height: 70)
                                    .frame(maxWidth: .infinity)
                                    .foregroundColor(AppTheme.textColor)
                            }
                        }
                    }.background(.ultraThinMaterial)
                }
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: self.$mealPhoto)
        }
        .onAppear {
            selectedNutrient = .calories
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
                }
                .padding([.vertical,.horizontal])
                .frame(minWidth: 150, maxHeight: .infinity)
                .background(isSelected ? AppTheme.textColor : AppTheme.reverse)
                .clipShape(.rect(cornerRadius: 10))
            }
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
              let fatValue = Double(nutrientValues[.fats] ?? "0") else {
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
                fat: Double(nutrientValues[.fats] ?? "0") ?? 0,
                servingUnit: selectedUnit,
                servingSize: String(servingSize),
                userNotes: userNote,
                mealPhoto: mealPhoto?.jpegData(compressionQuality: 1.0) ?? Data(),
                mealPhotoLink: "",  //TODO: generate a link
                isFavorite: isFavorite
            )
        print("adding food entry: name: \(name), type:\(mealType) , cals:\(caloriesValue), protein:\(proteinValue), carbs: \(carbsValue), fats: \(fatValue)")
        return
    }
    
}


struct PreviousEntriesView: View {
    @State private var selectedTab: Int = 0
    @Binding var name: String
    @State var dataStore: NutritionDataStore?
    @State private var entries: [NutritionEntry] = []
    @State private var favoriteEntries: [NutritionEntry] = []
    @Binding var nutrientValues: [NutrientType: String]
    @Binding var userNote: String
    @Binding var mealPhoto: UIImage?
    @Binding var isFavorite: Bool
    var dismiss: () -> Void
    
    var body: some View {
        VStack {
            Picker("Filter", selection: $selectedTab) {
                Text("All").tag(0)
                Text("Favorites").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .onChange(of: selectedTab) { _ in
                fetchEntries()
            }
            ScrollView {
                ForEach(selectedTab == 0 ? entries : favoriteEntries, id: \.self) { entry in
                    Button(action: {
                        populateFields(with: entry)
                    }) {
                        NutritionEntryView(entry: entry)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .onChange(of: name) { _ in
            fetchEntries()
        }
        .onAppear {
            fetchEntries()
        }
    }
    
    private func fetchEntries() {
        if selectedTab == 0 {
            entries = dataStore?.fetchEntries(favorites: false, nameSearch: name) ?? []
        } else {
            favoriteEntries = dataStore?.fetchEntries(favorites: true, nameSearch: name) ?? []
        }
    }
    
    private func populateFields(with entry: NutritionEntry) {
        self.name = entry.name
        self.isFavorite = entry.isFavorite
        nutrientValues[.calories] = String(entry.calories)
        nutrientValues[.protein] = String(entry.protein)
        nutrientValues[.carbs] = String(entry.carbs)
        nutrientValues[.fats] = String(entry.fat)
        dismiss()
    }
}

// MacroNutrientInputTile.swift
struct MacroNutrientInputTile: View {
    let nutrient: NutrientType
    var addItemEntry: Bool
    @Binding var value: String?
    @Binding var isSelected: Bool
    @FocusState var isInputActive: Bool
    //Wave Animation
    // Define maximum values for each nutrient for the purpose of the animation
//    private let maxValues: [NutrientType: Double] = [
//        .calories: 2000, .protein: 200, .carbs: 300, .fats: 100
//    ]

    // Calculate the current percentage of the nutrient value
//    private var nutrientPercent: Double {
//        guard let currentValue = Double(value ?? "0"), let maxValue = maxValues[nutrient] else {
//            return 0
//        }
//        return (currentValue / maxValue) * 100
//    }

    @State private var waveOffset = Angle(degrees: 0)

    var body: some View {
        Button(action: {
            isSelected = true
            isInputActive = true
        }) {
            ZStack {
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
                    .foregroundColor(isSelected ? AppTheme.reverse : getNutrientTheme(nutrient))
                }
                .padding([.vertical], 50)
                .frame(maxWidth: .infinity, maxHeight: 120)
                .background(isSelected ? getNutrientTheme(nutrient) : AppTheme.reverse)
                .clipShape(.rect(cornerRadius: 20))
                .padding()
                .shadow(radius: 4, x: 2, y: 4)
            }
            //Wave Animation
//            .background(
//                addItemEntry ? AnyView(
//                    Wave(offSet: Angle(degrees: waveOffset.degrees), percent: nutrientPercent)
//                        .fill(isSelected ? getNutrientTheme(nutrient) : AppTheme.reverse)
//                        .clipShape(Rectangle())
//                        .padding(.bottom, 5)
//                ) : AnyView(EmptyView())
//            )
        }
//        .onAppear {
//            if addItemEntry {
//                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
//                    waveOffset = Angle(degrees: 360)
//                }
//            }
//        }
    }

    private func getNutrientTheme(_ type: NutrientType) -> Color {
        switch type {
        case .calories:
            return AppTheme.sageGreen
        case .protein:
            return AppTheme.lavender
        case .carbs:
            return AppTheme.goldenrod
        case .fats:
            return AppTheme.carrot
        default:
            return AppTheme.basic
        }
    }
}

struct AddItemFormView_Previews: PreviewProvider {
    static var previews: some View {
        AddItemFormView(
            isPresented: .constant(true),
            selectedDate: Date(),
            mealType: .constant("Breakfast"),
            dataStore: MockNutritionDataStore(context: PersistenceController.init(inMemory: false).container.viewContext), onDismiss: {}
        )
    }
}
