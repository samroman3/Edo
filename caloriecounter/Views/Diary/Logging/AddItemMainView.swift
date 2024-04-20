//
//  AddItemMainView.swift
//  caloriecounter
//
//  Created by Sam Roman on 4/20/24.
//

import SwiftUI
 
struct AddItemMainView: View {
    @Binding var isPresented: Bool
    var selectedDate: Date
    @Binding var mealType: String
    var dataStore: NutritionDataStore?
    let onDismiss: () -> Void
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center) {
                Button(action: { isPresented = false }) {
                    Image(systemName: "chevron.down")
                        .foregroundColor(AppTheme.textColor)
                }
                HStack {
                    TextField("Search...", text: .constant(""))
                    Spacer()
                    Image(systemName: "magnifyingglass")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(AppTheme.basic)
                        .frame(maxWidth: 20, maxHeight: 20 )
                    
                }.padding()
                HStack(spacing: 16) {
                    VStack(alignment: .center) {
                        NavigationLink(destination: BarcodeScannerView(), label: {
                            Image(systemName: "camera.viewfinder")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundStyle(AppTheme.basic)
                                .frame(maxWidth: 150, maxHeight: 150)
                                .symbolRenderingMode(.monochrome)
                        })
                    }
                }
                Text("Favorites")
                    .font(.headline)
                FoodItem(name: "Cottage cheese 60%", amount: "27g", rss: 3, calories: 65)
                FoodItem(name: "Cabbage cutlets with mushrooms and onions", amount: "70g", rss: 6, calories: 119)
                FoodItem(name: "Milk 4.2%", amount: "260mL", rss: 9, calories: 185)
                FoodItem(name: "Frozen Blueberries", amount: "67g", rss: 3, calories: 21)
                FoodItem(name: "Cherry tomato", amount: "90g", rss: 4, calories: 21)
                Spacer()
            }
            .padding(.horizontal)
            }
        .navigationTitle("Add Entry")
        .navigationBarTitleDisplayMode(.automatic)
    }
}

struct FoodItem: View {
    let name: String
    let amount: String
    let rss: Int
    let calories: Int
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(name)
                Text("\(amount) — RSS \(rss)% — \(calories) cal")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Image(systemName: "plus.circle.fill")
                .foregroundColor(.green)
        }
    }
}

struct AddItemMainView_Previews: PreviewProvider {
    static var previews: some View {
        
            AddItemMainView(
                isPresented: .constant(true),
                selectedDate: Date(),
                mealType: .constant(""),
                dataStore: nil,
                onDismiss: {}
            )
                .previewDevice(PreviewDevice(rawValue: "iPhone 14 Pro"))
                .previewDisplayName("iPhone 14 Pro")
        
    }
}

