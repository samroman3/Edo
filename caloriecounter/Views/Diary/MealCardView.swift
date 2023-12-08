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
                    .foregroundStyle(AppTheme.lime)
                Spacer()
                Button(action: onAddTapped) {
                    Image(systemName: "plus.circle")
                        .resizable()
                        .tint(Color.blue)
                        .foregroundStyle(AppTheme.lime)
                        .frame(width: 30, height: 30)
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
                                            .foregroundStyle(AppTheme.prunes)
                                            .frame(width: 30, height: 30)
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
    var totalCalories: Int
    
    var body: some View {
        VStack {
            Spacer()
            Image(systemName: isExpanded.wrappedValue ? "chevron.up" : "chevron.down")
                .foregroundStyle(AppTheme.lime)
                .font(.system(size: 25))
            Spacer()
            Text("\(totalCalories) calories")
                .font(.caption)
                .foregroundStyle(AppTheme.lime)
        }
        .onTapGesture {
            withAnimation {
                isExpanded.wrappedValue.toggle()
            }
        }
    }
}



//#Preview {
//    MealEntryView()
//}


