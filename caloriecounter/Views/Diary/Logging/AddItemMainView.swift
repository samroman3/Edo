//
//  AddItemMainView.swift
//  caloriecounter
//
//  Created by Sam Roman on 4/20/24.
//

import SwiftUI
 
struct AddItemMainView: View {
    var body: some View {
        NavigationView {
            VStack(alignment: .center) {
                HStack {
                    TextField("Search...", text: .constant(""))
                    Spacer()
                    Circle()
                        .fill(Color.yellow)
                        .frame(width: 32, height: 32)
                }
                
                HStack(spacing: 16) {
//                    VStack {
//                        Image(systemName: "camera")
//                            .foregroundColor(.black)
//                            .frame(width: 48, height: 48)
//                            .background(Color.yellow)
//                    }
                    
                    VStack(alignment: .center) {
                       Image(systemName: "barcode.viewfinder")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundStyle(AppTheme.basic)
                    }.frame(maxWidth: 150, maxHeight: 150 )
                }
                
                Text("Favorites")
                    .font(.headline)
                
                FoodItem(name: "Cottage cheese 60%", amount: "27g", rss: 3, calories: 65)
                FoodItem(name: "Cabbage cutlets with mushrooms and onions", amount: "70g", rss: 6, calories: 119)
                FoodItem(name: "Milk 4.2%", amount: "260mL", rss: 9, calories: 185)
                FoodItem(name: "Frozen Blueberries", amount: "67g", rss: 3, calories: 21)
                FoodItem(name: "Cherry tomato", amount: "90g", rss: 4, calories: 21)
            }
            .padding()
            .navigationBarTitle("Add Entry", displayMode: .inline)
        }
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
        Group {
            AddItemMainView()
                .previewDevice(PreviewDevice(rawValue: "iPhone 14 Pro"))
                .previewDisplayName("iPhone 14 Pro")
        }
    }
}
