//
//  AddItemFormView.swift
//  caloriecounter
//
//  Created by Sam Roman on 11/24/23.
//

import SwiftUI
import AVFoundation
import AudioToolbox

enum NutrientType: String, CaseIterable {
    case calories, protein, carbs, fats,
         vitaminA, vitaminC, vitaminD, vitaminE, vitaminB6, vitaminB12, folate,
         calcium, iron, magnesium, phosphorus, potassium, sodium, zinc
}

enum AddFoodLookupMode: String, CaseIterable, Identifiable {
    case diary
    case barcode
    case quick

    var id: String { rawValue }

    var title: String {
        switch self {
        case .diary:
            return "Diary"
        case .barcode:
            return "Barcode"
        case .quick:
            return "Quick"
        }
    }

    var systemImage: String {
        switch self {
        case .diary:
            return "book.pages"
        case .barcode:
            return "barcode.viewfinder"
        case .quick:
            return "bolt.fill"
        }
    }
}

struct AddItemFormView: View {
    @Binding var isPresented: Bool
    var selectedDate: Date
    @Binding var mealType: String
    @State private var name: String = ""
    let dataStore: NutritionDataStore
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
    @State private var isFavorite: Bool = false
    @State private var validationMessage: String?
    @State private var quickRecentEntries: [NutritionEntrySummary] = []
    @State private var lookupMode: AddFoodLookupMode = .diary
    
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

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

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
                        .font(AppTheme.standardBookBody)
                        .fontWeight(.light)
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal)
                        .onChange(of: isNameTextFieldFocused,
                                  perform: { isFocused in
                            showingPreviousEntries = isFocused
                            if isFocused {
                                lookupMode = .diary
                            }
                        })
                }
            }
            .padding([.horizontal, .vertical])
            if let validationMessage {
                Text(validationMessage)
                    .font(AppTheme.standardBookCaption)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
            }
            if showingPreviousEntries {
                PreviousEntriesView(name: $name,
                                    lookupMode: $lookupMode,
                                    dataStore: dataStore,
                                    nutrientValues: $nutrientValues,
                                    userNote: $userNote,
                                    mealPhoto: $mealPhoto,
                                    isFavorite: $isFavorite,
                                    quickRecentEntries: quickRecentEntries,
                                    dismiss: {
                    withAnimation{
                        showingPreviousEntries = false
                        isNameTextFieldFocused = false
                        hideKeyboard()
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
                        if !isUserNoteFocused && !isNameTextFieldFocused {
                            quickAddSection
                        }
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
                                        .font(AppTheme.standardBookBody)
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
                                                        .font(AppTheme.standardBookLargeTitle)
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
                                .font(AppTheme.standardBookLargeTitle)
                                .frame(height: 70)
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
                            Button(action: saveFoodItem) {
                                Text("Add +")
                                    .font(AppTheme.standardBookLargeTitle)
                                    .frame(height: 70)
                                    .frame(maxWidth: .infinity)
                                    .foregroundColor(AppTheme.textColor)
                            }
                            .disabled(!canSave)
                            .opacity(canSave ? 1.0 : 0.55)
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
            refreshQuickPicks()
        }
        .onChange(of: mealType) { _ in
            refreshQuickPicks()
        }
    }
    
    private func selectedNutrientTextBinding() -> Binding<String> {
        Binding<String>(
            get: { self.nutrientValues[self.selectedNutrient ?? .calories] ?? "0" },
            set: { self.nutrientValues[self.selectedNutrient ?? .calories] = $0 }
        )
    }

    private var quickAddSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !quickRecentEntries.isEmpty {
                quickPickScroller(title: "Recent", entries: quickRecentEntries)
            }
        }
        .padding(.horizontal)
        .padding(.top, 4)
    }

    private func quickPickScroller(title: String, entries: [NutritionEntrySummary]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(AppTheme.standardBookCaption)
                .foregroundStyle(AppTheme.textColor.opacity(0.7))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(entries) { entry in
                        Button {
                            apply(entry)
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(entry.name)
                                    .font(AppTheme.standardBookBody)
                                    .lineLimit(1)
                                Text("\(Int(entry.calories)) cal")
                                    .font(AppTheme.standardBookCaption)
                                    .foregroundStyle(AppTheme.textColor.opacity(0.7))
                            }
                            .foregroundStyle(AppTheme.textColor)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(AppTheme.reverse)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
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
                                .font(AppTheme.standardBookBody)
                            Text("mg")
                                .font(AppTheme.standardBookBody)
                        }
                        .foregroundColor(isSelected ? AppTheme.reverse : AppTheme.textColor)
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
    private func saveFoodItem() {
        if addFoodItem(nutrientValues) {
            onDismiss()
            isPresented = false
        }
    }

    @discardableResult
    private func addFoodItem(_ nutrientValues: [NutrientType: String]) -> Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            validationMessage = "Add a name before saving."
            return false
        }
        //macros
        guard let caloriesValue = Double(nutrientValues[.calories] ?? "0"),
              let proteinValue = Double(nutrientValues[.protein] ?? "0"),
              let carbsValue = Double(nutrientValues[.carbs] ?? "0"),
              let fatValue = Double(nutrientValues[.fats] ?? "0") else {
            validationMessage = "Use numbers only for calories and macros."
            return false
        }

        validationMessage = nil
        dataStore.addEntryToMealAndDailyLog(
            date: selectedDate,
            mealType: mealType,
            name: trimmedName,
            calories: caloriesValue,
            protein: proteinValue,
            carbs: carbsValue,
            fat: fatValue,
            servingUnit: selectedUnit,
            servingSize: String(servingSize),
            userNotes: userNote,
            mealPhoto: mealPhoto?.jpegData(compressionQuality: 1.0) ?? Data(),
            mealPhotoLink: "",
            isFavorite: isFavorite
        )
        refreshQuickPicks()
        return true
    }

    private func refreshQuickPicks() {
        quickRecentEntries = dataStore.recentQuickEntries(limit: 6)
    }

    private func apply(_ entry: NutritionEntrySummary) {
        validationMessage = nil
        name = entry.name
        isFavorite = entry.isFavorite
        nutrientValues[.calories] = String(entry.calories)
        nutrientValues[.protein] = String(entry.protein)
        nutrientValues[.carbs] = String(entry.carbs)
        nutrientValues[.fats] = String(entry.fat)
    }
    
}

struct PreviousEntriesView: View {
    @Binding var name: String
    @Binding var lookupMode: AddFoodLookupMode
    let dataStore: NutritionDataStore
    @State private var entries: [NutritionEntrySummary] = []
    @Binding var nutrientValues: [NutrientType: String]
    @Binding var userNote: String
    @Binding var mealPhoto: UIImage?
    @Binding var isFavorite: Bool
    let quickRecentEntries: [NutritionEntrySummary]
    var dismiss: () -> Void

    @State private var barcodeResults: [RemoteFoodSearchResult] = []
    @State private var barcodeQuery: String = ""
    @State private var remoteStatusMessage: String?
    @State private var isSearchingBarcode = false
    @State private var showBarcodeScanner = false
    @State private var scannerErrorMessage: String?

    private let searchService = OpenFoodFactsSearchService()
    
    var body: some View {
        VStack(spacing: 12) {
            lookupModePicker

            Group {
                switch lookupMode {
                case .diary:
                    diaryResultsView
                case .barcode:
                    barcodeLookupView
                case .quick:
                    quickResultsView
                }
            }
        }
        .onChange(of: name) { _ in
            if lookupMode == .diary {
                fetchEntries()
            }
        }
        .onChange(of: lookupMode) { newMode in
            remoteStatusMessage = nil
            if newMode == .diary {
                fetchEntries()
            } else if newMode == .barcode {
                barcodeQuery = barcodeQuery.isEmpty ? digitsOnly(from: name) : barcodeQuery
            }
        }
        .onAppear {
            fetchEntries()
        }
        .sheet(isPresented: $showBarcodeScanner) {
            BarcodeScannerSheet(
                scannedCode: { scannedCode in
                    barcodeQuery = scannedCode
                    scannerErrorMessage = nil
                    showBarcodeScanner = false
                    lookupBarcode()
                },
                onFailure: { message in
                    scannerErrorMessage = message
                    showBarcodeScanner = false
                }
            )
        }
    }

    private var lookupModePicker: some View {
        HStack(spacing: 8) {
            ForEach(AddFoodLookupMode.allCases) { mode in
                Button {
                    lookupMode = mode
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: mode.systemImage)
                            .font(.system(size: 15, weight: .semibold))
                        Text(mode.title)
                            .font(AppTheme.standardBookCaption)
                    }
                    .foregroundStyle(lookupMode == mode ? AppTheme.reverse : AppTheme.textColor)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(lookupMode == mode ? AppTheme.basic : AppTheme.reverse)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal)
    }

    private var diaryResultsView: some View {
        VStack(spacing: 12) {
            ScrollView {
                if entries.isEmpty {
                    emptyState(
                        title: name.isEmpty ? "Start typing to search your diary." : "No diary matches yet.",
                        subtitle: name.isEmpty ? "Your recent items stay here by default." : "Try barcode lookup for packaged foods."
                    )
                } else {
                    ForEach(entries, id: \.self) { entry in
                        Button(action: {
                            populateFields(with: entry)
                        }) {
                            HistoryEntryRow(entry: entry)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var barcodeLookupView: some View {
        VStack(spacing: 12) {
            HStack(spacing: 10) {
                TextField("Enter barcode...", text: $barcodeQuery)
                    .keyboardType(.numberPad)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(AppTheme.reverse)
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                Button(action: lookupBarcode) {
                    if isSearchingBarcode {
                        ProgressView()
                    } else {
                        Text("Lookup")
                            .font(AppTheme.standardBookCaption)
                    }
                }
                .disabled(isSearchingBarcode || barcodeQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.horizontal)

            Button(action: {
                scannerErrorMessage = nil
                showBarcodeScanner = true
            }) {
                Label("Scan Barcode", systemImage: "camera.viewfinder")
                    .font(AppTheme.standardBookCaption)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(AppTheme.reverse)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(.plain)
            .padding(.horizontal)

            Text("Scan a barcode or type it in manually.")
                .font(AppTheme.standardBookCaption)
                .foregroundStyle(AppTheme.textColor.opacity(0.7))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

            if let scannerErrorMessage {
                Text(scannerErrorMessage)
                    .font(AppTheme.standardBookCaption)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
            }

            if let remoteStatusMessage {
                Text(remoteStatusMessage)
                    .font(AppTheme.standardBookCaption)
                    .foregroundStyle(AppTheme.textColor.opacity(0.7))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
            }

            ScrollView {
                if barcodeResults.isEmpty {
                    emptyState(
                        title: "Paste or type a barcode to look it up.",
                        subtitle: "This is ideal for boxed and packaged items."
                    )
                } else {
                    ForEach(barcodeResults) { result in
                        Button {
                            populateFields(with: result)
                        } label: {
                            RemoteFoodResultRow(result: result)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var quickResultsView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                if quickRecentEntries.isEmpty {
                    emptyState(
                        title: "Quick picks will show up once you log a few foods.",
                        subtitle: "Your recent items live here for fast repeat logging."
                    )
                } else {
                    ForEach(quickRecentEntries) { entry in
                        Button {
                            populateFields(with: entry)
                        } label: {
                            HistoryEntryRow(entry: entry)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private func fetchEntries() {
        if name.isEmpty {
            entries = dataStore.recentQuickEntries(limit: 10)
            return
        }

        entries = dataStore.fetchConsolidatedEntries(favorites: false, nameSearch: name)
    }
    
    private func populateFields(with entry: NutritionEntrySummary) {
        self.name = entry.name
        self.isFavorite = entry.isFavorite
        self.userNote = ""
        self.mealPhoto = nil
        nutrientValues[.calories] = String(entry.calories)
        nutrientValues[.protein] = String(entry.protein)
        nutrientValues[.carbs] = String(entry.carbs)
        nutrientValues[.fats] = String(entry.fat)
        dismiss()
    }

    private func populateFields(with result: RemoteFoodSearchResult) {
        name = result.name
        isFavorite = false
        userNote = ""
        mealPhoto = nil
        nutrientValues[.calories] = result.formattedCalories
        nutrientValues[.protein] = result.formattedProtein
        nutrientValues[.carbs] = result.formattedCarbs
        nutrientValues[.fats] = result.formattedFat
        dismiss()
    }

    private func lookupBarcode() {
        let query = barcodeQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            remoteStatusMessage = "Enter a barcode before looking it up."
            return
        }

        isSearchingBarcode = true
        remoteStatusMessage = "Looking up barcode..."

        Task {
            do {
                let result = try await searchService.lookupBarcode(query)
                await MainActor.run {
                    barcodeResults = result.map { [$0] } ?? []
                    remoteStatusMessage = result == nil ? "No product found for that barcode." : "Barcode match ready."
                    isSearchingBarcode = false
                }
            } catch {
                await MainActor.run {
                    remoteStatusMessage = "Barcode lookup failed. Try again in a moment."
                    isSearchingBarcode = false
                }
            }
        }
    }

    private func emptyState(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(AppTheme.standardBookBody)
            Text(subtitle)
                .font(AppTheme.standardBookCaption)
                .foregroundStyle(AppTheme.textColor.opacity(0.7))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
    }

    private func digitsOnly(from value: String) -> String {
        value.filter(\.isNumber)
    }
}



// MacroNutrientInputTile.swift
struct HistoryEntryRow: View {
    let entry: NutritionEntrySummary

    var body: some View {
        VStack(alignment: .leading) {
            Text(entry.name)
                .font(AppTheme.standardBookBody)
            HStack {
                HistoryMetricRow(color: AppTheme.sageGreen, text: String(format: "%.1f cal", entry.calories))
                HistoryMetricRow(color: AppTheme.softPurple, text: String(format: "%.1fg prot", entry.protein))
                HistoryMetricRow(color: AppTheme.goldenrod, text: String(format: "%.1fg carbs", entry.carbs))
                HistoryMetricRow(color: AppTheme.carrot, text: String(format: "%.1fg fats", entry.fat))
            }
            .font(.caption)
            .foregroundColor(.primary)
            Divider().background(AppTheme.textColor)
        }
        .padding(.vertical, 4)
        .padding(.horizontal)
    }
}

private struct HistoryMetricRow: View {
    let color: Color
    let text: String

    var body: some View {
        HStack {
            Text("*")
                .font(.title2)
                .foregroundStyle(color)
            Text(text)
                .lineLimit(1)
                .minimumScaleFactor(0.65)
                .allowsTightening(true)
        }
    }
}

private struct BarcodeScannerSheet: View {
    let scannedCode: (String) -> Void
    let onFailure: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var permissionDenied = false

    var body: some View {
        NavigationStack {
            if permissionDenied {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Camera access is required to scan barcodes.")
                        .font(AppTheme.standardBookBody)
                    Text("You can still type the barcode manually in the field below the scanner button.")
                        .font(AppTheme.standardBookCaption)
                        .foregroundStyle(AppTheme.textColor.opacity(0.7))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding()
            } else {
                EmbeddedBarcodeScannerView(
                    onCodeScanned: { code in
                        scannedCode(code)
                    },
                    onFailure: { message in
                        onFailure(message)
                    }
                )
                .ignoresSafeArea(edges: .bottom)
            }
        }
        .background(AppTheme.basic)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Close") {
                    dismiss()
                }
            }
        }
        .task {
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            switch status {
            case .authorized:
                permissionDenied = false
            case .notDetermined:
                let granted = await AVCaptureDevice.requestAccess(for: .video)
                permissionDenied = !granted
                if !granted {
                    onFailure("Camera permission was denied. You can still type the barcode manually.")
                }
            case .denied, .restricted:
                permissionDenied = true
            @unknown default:
                permissionDenied = true
            }
        }
    }
}

private struct EmbeddedBarcodeScannerView: UIViewControllerRepresentable {
    let onCodeScanned: (String) -> Void
    let onFailure: (String) -> Void

    func makeUIViewController(context: Context) -> EmbeddedBarcodeScannerViewController {
        let controller = EmbeddedBarcodeScannerViewController()
        controller.onCodeScanned = onCodeScanned
        controller.onFailure = onFailure
        return controller
    }

    func updateUIViewController(_ uiViewController: EmbeddedBarcodeScannerViewController, context: Context) {
        uiViewController.onCodeScanned = onCodeScanned
        uiViewController.onFailure = onFailure
    }
}

private final class EmbeddedBarcodeScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var onCodeScanned: ((String) -> Void)?
    var onFailure: ((String) -> Void)?

    private let captureSession = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var didFinishScan = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        configureSession()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !captureSession.isRunning && !didFinishScan {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession.startRunning()
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }

    private func configureSession() {
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            onFailure?("This device does not have a camera available for barcode scanning.")
            return
        }

        do {
            let videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
            } else {
                onFailure?("The camera input could not be configured.")
                return
            }
        } catch {
            onFailure?("The camera could not be started.")
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [
                .ean8,
                .ean13,
                .upce,
                .code128,
                .qr
            ]
        } else {
            onFailure?("Barcode scanning is not supported on this device.")
            return
        }

        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)
        self.previewLayer = previewLayer
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard !didFinishScan,
              let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let code = metadataObject.stringValue,
              !code.isEmpty else {
            return
        }

        didFinishScan = true
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        onCodeScanned?(code)
    }
}

struct RemoteFoodSearchResult: Identifiable, Hashable {
    let id: String
    let name: String
    let brand: String?
    let barcode: String?
    let calories: Double
    let protein: Double
    let carbs: Double
    let fat: Double
    let sourceName: String

    var note: String {
        var parts = [sourceName]
        if let brand, !brand.isEmpty {
            parts.append(brand)
        }
        if let barcode, !barcode.isEmpty {
            parts.append("Barcode: \(barcode)")
        }
        return parts.joined(separator: " | ")
    }

    var formattedCalories: String { Self.format(calories) }
    var formattedProtein: String { Self.format(protein) }
    var formattedCarbs: String { Self.format(carbs) }
    var formattedFat: String { Self.format(fat) }

    private static func format(_ value: Double) -> String {
        if value.rounded() == value {
            return String(Int(value))
        }
        return String(format: "%.1f", value)
    }
}

private struct RemoteFoodResultRow: View {
    let result: RemoteFoodSearchResult

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text(result.name)
                    .font(AppTheme.standardBookBody)
                Spacer()
                Text("\(result.formattedCalories) cal")
                    .font(AppTheme.standardBookCaption)
                    .foregroundStyle(AppTheme.sageGreen)
            }

            if let brand = result.brand, !brand.isEmpty {
                Text(brand)
                    .font(AppTheme.standardBookCaption)
                    .foregroundStyle(AppTheme.textColor.opacity(0.7))
            }

            HStack {
                HistoryMetricRow(color: AppTheme.lavender, text: "\(result.formattedProtein)g prot")
                HistoryMetricRow(color: AppTheme.goldenrod, text: "\(result.formattedCarbs)g carbs")
                HistoryMetricRow(color: AppTheme.carrot, text: "\(result.formattedFat)g fats")
            }
            .font(.caption)

            Divider().background(AppTheme.textColor)
        }
        .padding(.vertical, 4)
        .padding(.horizontal)
    }
}

struct OpenFoodFactsSearchService {
    func searchProducts(matching query: String) async throws -> [RemoteFoodSearchResult] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else {
            return []
        }

        var components = URLComponents(string: "https://world.openfoodfacts.org/cgi/search.pl")
        components?.queryItems = [
            URLQueryItem(name: "search_terms", value: trimmedQuery),
            URLQueryItem(name: "search_simple", value: "1"),
            URLQueryItem(name: "action", value: "process"),
            URLQueryItem(name: "json", value: "1"),
            URLQueryItem(name: "page_size", value: "12")
        ]

        guard let url = components?.url else {
            return []
        }

        let (data, _) = try await URLSession.shared.data(for: request(for: url))
        return try decodeSearchResults(from: data)
    }

    func lookupBarcode(_ barcode: String) async throws -> RemoteFoodSearchResult? {
        let trimmedBarcode = barcode.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedBarcode.isEmpty else {
            return nil
        }

        guard let url = URL(string: "https://world.openfoodfacts.org/api/v2/product/\(trimmedBarcode).json") else {
            return nil
        }

        let (data, _) = try await URLSession.shared.data(for: request(for: url))
        return try decodeBarcodeLookup(from: data)
    }

    func decodeSearchResults(from data: Data) throws -> [RemoteFoodSearchResult] {
        let payload = try JSONDecoder().decode(OpenFoodFactsSearchResponse.self, from: data)
        return payload.products.compactMap { product in
            makeResult(from: product)
        }
    }

    func decodeBarcodeLookup(from data: Data) throws -> RemoteFoodSearchResult? {
        let payload = try JSONDecoder().decode(OpenFoodFactsBarcodeResponse.self, from: data)
        guard payload.status == 1 else {
            return nil
        }
        return payload.product.flatMap(makeResult(from:))
    }

    private func request(for url: URL) -> URLRequest {
        var request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 15)
        request.setValue("EAZEAT/1.0 (iOS; Open Food Facts integration)", forHTTPHeaderField: "User-Agent")
        return request
    }

    private func makeResult(from product: OpenFoodFactsProduct) -> RemoteFoodSearchResult? {
        let trimmedName = (product.productName ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            return nil
        }

        let nutriments = product.nutriments ?? .empty
        let calories = nutriments.energyKcalServing ?? nutriments.energyKcal100g ?? nutriments.energyKcal ?? 0
        let protein = nutriments.proteinsServing ?? nutriments.proteins100g ?? nutriments.proteins ?? 0
        let carbs = nutriments.carbohydratesServing ?? nutriments.carbohydrates100g ?? nutriments.carbohydrates ?? 0
        let fat = nutriments.fatServing ?? nutriments.fat100g ?? nutriments.fat ?? 0

        return RemoteFoodSearchResult(
            id: product.code ?? UUID().uuidString,
            name: trimmedName,
            brand: product.brands,
            barcode: product.code,
            calories: calories,
            protein: protein,
            carbs: carbs,
            fat: fat,
            sourceName: "Open Food Facts"
        )
    }
}

struct FoodSearchService {
    private let openFoodFacts = OpenFoodFactsSearchService()
    private let usdaBasics = USDABasicFoodSearchService()

    func searchProducts(matching query: String) async throws -> [RemoteFoodSearchResult] {
        let offResults = (try? await openFoodFacts.searchProducts(matching: query)) ?? []
        let usdaResults = usdaBasics.searchProducts(matching: query)

        var seen = Set<String>()
        var merged: [RemoteFoodSearchResult] = []

        for result in offResults + usdaResults {
            let key = result.name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            if seen.insert(key).inserted {
                merged.append(result)
            }
        }

        return merged
    }

    func lookupBarcode(_ barcode: String) async throws -> RemoteFoodSearchResult? {
        try await openFoodFacts.lookupBarcode(barcode)
    }
}

struct USDABasicFoodSearchService {
    func searchProducts(matching query: String) -> [RemoteFoodSearchResult] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmedQuery.isEmpty else {
            return []
        }

        let directMatches = Self.catalog.filter { item in
            item.searchTokens.contains { $0.contains(trimmedQuery) } || item.name.lowercased().contains(trimmedQuery)
        }

        if !directMatches.isEmpty {
            return Array(directMatches.prefix(8)).map(\.result)
        }

        let fallbackMatches = Self.catalog.filter { item in
            trimmedQuery.split(separator: " ").contains { token in
                let value = String(token)
                return item.searchTokens.contains { $0.contains(value) } || item.name.lowercased().contains(value)
            }
        }

        return Array(fallbackMatches.prefix(8)).map(\.result)
    }

    private static let catalog: [USDAFoodReference] = [
        USDAFoodReference(name: "Apple", calories: 95, protein: 0.5, carbs: 25, fat: 0.3, searchTokens: ["apple", "fruit"]),
        USDAFoodReference(name: "Banana", calories: 105, protein: 1.3, carbs: 27, fat: 0.4, searchTokens: ["banana", "fruit"]),
        USDAFoodReference(name: "Blueberries", calories: 84, protein: 1.1, carbs: 21, fat: 0.5, searchTokens: ["blueberry", "blueberries", "berries", "fruit"]),
        USDAFoodReference(name: "White Rice", calories: 205, protein: 4.3, carbs: 45, fat: 0.4, searchTokens: ["rice", "white rice"]),
        USDAFoodReference(name: "Brown Rice", calories: 216, protein: 5, carbs: 45, fat: 1.8, searchTokens: ["brown rice", "rice"]),
        USDAFoodReference(name: "Oatmeal", calories: 154, protein: 5.4, carbs: 27.4, fat: 2.6, searchTokens: ["oats", "oatmeal", "porridge"]),
        USDAFoodReference(name: "Egg", calories: 78, protein: 6.3, carbs: 0.6, fat: 5.3, searchTokens: ["egg", "eggs"]),
        USDAFoodReference(name: "Chicken Breast", calories: 165, protein: 31, carbs: 0, fat: 3.6, searchTokens: ["chicken", "chicken breast"]),
        USDAFoodReference(name: "Salmon", calories: 206, protein: 22, carbs: 0, fat: 12, searchTokens: ["salmon", "fish"]),
        USDAFoodReference(name: "Ground Beef", calories: 332, protein: 14, carbs: 0, fat: 30, searchTokens: ["beef", "ground beef"]),
        USDAFoodReference(name: "Greek Yogurt", calories: 130, protein: 17, carbs: 6, fat: 3.5, searchTokens: ["greek yogurt", "yogurt", "yoghurt"]),
        USDAFoodReference(name: "Cottage Cheese", calories: 183, protein: 23.5, carbs: 6.1, fat: 5.1, searchTokens: ["cottage cheese", "cheese"]),
        USDAFoodReference(name: "Broccoli", calories: 55, protein: 3.7, carbs: 11.2, fat: 0.6, searchTokens: ["broccoli", "vegetable"]),
        USDAFoodReference(name: "Sweet Potato", calories: 112, protein: 2, carbs: 26, fat: 0.1, searchTokens: ["sweet potato", "yam", "potato"]),
        USDAFoodReference(name: "Avocado", calories: 240, protein: 3, carbs: 12.8, fat: 22, searchTokens: ["avocado"]),
        USDAFoodReference(name: "Peanut Butter", calories: 190, protein: 7, carbs: 7, fat: 16, searchTokens: ["peanut butter", "nut butter"]),
        USDAFoodReference(name: "Almonds", calories: 164, protein: 6, carbs: 6.1, fat: 14.2, searchTokens: ["almond", "almonds", "nuts"]),
        USDAFoodReference(name: "Whole Wheat Bread", calories: 110, protein: 4, carbs: 20, fat: 1.5, searchTokens: ["bread", "whole wheat bread", "toast"]),
        USDAFoodReference(name: "Black Beans", calories: 227, protein: 15, carbs: 41, fat: 0.9, searchTokens: ["beans", "black beans"]),
        USDAFoodReference(name: "Tofu", calories: 144, protein: 17, carbs: 3, fat: 9, searchTokens: ["tofu"])
    ]
}

private struct USDAFoodReference {
    let name: String
    let calories: Double
    let protein: Double
    let carbs: Double
    let fat: Double
    let searchTokens: [String]

    var result: RemoteFoodSearchResult {
        .basicUSDAFood(
            name: name,
            calories: calories,
            protein: protein,
            carbs: carbs,
            fat: fat
        )
    }
}

extension RemoteFoodSearchResult {
    static func basicUSDAFood(
        name: String,
        calories: Double,
        protein: Double,
        carbs: Double,
        fat: Double
    ) -> RemoteFoodSearchResult {
        RemoteFoodSearchResult(
            id: "usda-\(name.lowercased().replacingOccurrences(of: " ", with: "-"))",
            name: name,
            brand: nil,
            barcode: nil,
            calories: calories,
            protein: protein,
            carbs: carbs,
            fat: fat,
            sourceName: "USDA Basics"
        )
    }
}

private struct OpenFoodFactsSearchResponse: Decodable {
    let products: [OpenFoodFactsProduct]
}

private struct OpenFoodFactsBarcodeResponse: Decodable {
    let status: Int
    let product: OpenFoodFactsProduct?
}

private struct OpenFoodFactsProduct: Decodable {
    let code: String?
    let productName: String?
    let brands: String?
    let nutriments: OpenFoodFactsNutriments?

    enum CodingKeys: String, CodingKey {
        case code
        case productName = "product_name"
        case brands
        case nutriments
    }
}

private struct OpenFoodFactsNutriments: Decodable {
    let energyKcal100g: Double?
    let energyKcalServing: Double?
    let energyKcal: Double?
    let proteins100g: Double?
    let proteinsServing: Double?
    let proteins: Double?
    let carbohydrates100g: Double?
    let carbohydratesServing: Double?
    let carbohydrates: Double?
    let fat100g: Double?
    let fatServing: Double?
    let fat: Double?

    static let empty = OpenFoodFactsNutriments(
        energyKcal100g: nil,
        energyKcalServing: nil,
        energyKcal: nil,
        proteins100g: nil,
        proteinsServing: nil,
        proteins: nil,
        carbohydrates100g: nil,
        carbohydratesServing: nil,
        carbohydrates: nil,
        fat100g: nil,
        fatServing: nil,
        fat: nil
    )

    enum CodingKeys: String, CodingKey {
        case energyKcal100g = "energy-kcal_100g"
        case energyKcalServing = "energy-kcal_serving"
        case energyKcal = "energy-kcal"
        case proteins100g = "proteins_100g"
        case proteinsServing = "proteins_serving"
        case proteins
        case carbohydrates100g = "carbohydrates_100g"
        case carbohydratesServing = "carbohydrates_serving"
        case carbohydrates
        case fat100g = "fat_100g"
        case fatServing = "fat_serving"
        case fat
    }
}

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
