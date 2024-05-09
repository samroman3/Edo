//
//  MealCardView.swift
//  caloriecounter
//
//  Created by Sam Roman on 11/24/23.

import SwiftUI
import CoreData

struct MealCardView: View {
    let mealType: String
    let entries: [NutritionEntry]
    @Binding var isExpanded: Bool
    var onAddTapped: () -> Void
    var onDeleteEntry: (NutritionEntry) -> Void
    
    @State private var swipedEntry: NutritionEntry?
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(mealType)
                    .font(.largeTitle)
                    .fontWeight(.light)
                    .foregroundStyle(AppTheme.textColor)
                Spacer()
                Button(action: onAddTapped) {
                    Image(systemName: "plus")
                        .resizable()
                        .foregroundStyle(AppTheme.textColor)
                        .frame(width: 25, height: 25)
                }
                .padding(.vertical)
            }
            
            .padding(.horizontal)
            .contentShape(Rectangle())
            if isExpanded {
                ForEach(entries, id: \.self) { entry in
                    HStack{
                        NutritionEntryView(entry: entry)
                            .offset(x: swipedEntry == entry ? -30 : 0)
                            .animation(.easeInOut, value: swipedEntry == entry)//
                            .gesture(
                                DragGesture()
                                    .onChanged { gesture in
                                        if gesture.translation.width < -30 { // Swipe left
                                            swipedEntry = entry
                                        }
                                        if gesture.translation.width > 30 { //swipe right
                                            swipedEntry = nil
                                        }
                                    }
                                    .onEnded { _ in
                                
                                    }
                            )
                        if swipedEntry == entry {
                            // Show the delete button or tray
                            withAnimation(.interpolatingSpring(.smooth, initialVelocity: 0.02)) {
                                HStack {
                                    Button(action: {
                                        onDeleteEntry(entry)
                                        swipedEntry = nil
                                    }) {
                                        Image(systemName: "minus")
                                            .foregroundStyle(AppTheme.textColor)
                                            .frame(width: 50, height: 50)
                                            .background(AppTheme.carrot)
                                    }
                                    .padding(.leading)
                                    .transition(.slide)
                                    .animation(.easeInOut, value: swipedEntry == entry)
                                }
                            }
                           
                        }
                    }
                    
                }
            }
        }.onAppear(){
            
            print(entries)
        }
        .onDisappear(){
            swipedEntry = nil
        }
    }
    
    


}

struct ChevronView: View {
    var isExpanded: Binding<Bool>
    var totalCalories: Double
    var totalProtein: Double
    var totalCarbs: Double
    var totalFats: Double
    
    var body: some View {
        VStack {
            Spacer()
            Image(systemName: isExpanded.wrappedValue ? "chevron.up" : "chevron.down")
                .font(.system(size: 25))
            HStack(alignment: .firstTextBaseline, spacing: 5){
                MacroLabel.shared.labelView(macro: "calories", value:  Text("\(totalCalories, specifier: "%.f")g"))
                MacroLabel.shared.labelView(macro: "protein", value:  Text("\(totalProtein, specifier: "%.f")g"))
                MacroLabel.shared.labelView(macro: "carbs", value:  Text("\(totalCarbs, specifier: "%.f")g"))
                MacroLabel.shared.labelView(macro: "fats", value:  Text("\(totalFats, specifier: "%.f")g"))
            }.padding()
            Spacer()
        }
        .onTapGesture {
            withAnimation {
                isExpanded.wrappedValue.toggle()
            }
        }
    }
}

class MacroLabel {
    static let shared = MacroLabel()
    
    func labelView(macro: String, value: Text) -> some View {
        switch macro {
        case "calories":
            return AnyView(
                HStack {
                    Image(systemName: "c.circle")
                        .font(.title2)
                        .foregroundStyle(.black)
                    value
                        .font(.caption)
                        .foregroundStyle(.black)
                    Spacer()
                }
                    .background(AppTheme.sageGreen)
                    .cornerRadius(15)
            )
        case "protein":
            return AnyView(
                HStack {
                    Image(systemName: "p.circle")
                        .font(.title2)
                        .foregroundStyle(.black)
                    value
                        .font(.caption)
                        .foregroundStyle(.black)
                    Spacer()
                }
                    .background(AppTheme.softPurple)
                    .cornerRadius(15)
            )
        case "carbs":
            return AnyView(
                HStack {
                    Image(systemName: "c.circle")
                        .font(.title2)
                        .foregroundStyle(.black)
                    value
                        .font(.caption)
                        .foregroundStyle(.black)
                    Spacer()
                }
                    .background(AppTheme.goldenrod)
                    .cornerRadius(15)
            )
        case "fats":
            return AnyView(
                HStack {
                    Image(systemName: "f.circle")
                        .font(.title2)
                        .foregroundStyle(.black)
                    value
                        .font(.caption)
                        .foregroundStyle(.black)
                    Spacer()
                }
                    .background(AppTheme.carrot)
                    .cornerRadius(15)
            )
        default:
            return AnyView(EmptyView())
        }
    }
}






//#Preview {
//    MealEntryView()
//}


