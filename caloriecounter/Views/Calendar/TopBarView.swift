//
//  TopBarView.swift
//  caloriecounter
//
//  Created by Sam Roman on 11/24/23.
//
import SwiftUI
struct TopBarView: View {
    @ObservedObject var dateSelectionManager: DateSelectionManager
    @ObservedObject var nutritionDataStore: NutritionDataStore
    
    @Binding var selectedDate: Date
    
    var onDateTapped: () -> Void
    var onCalendarTapped: () -> Void
    
    var entryType: TopBarType

    @State var isExpanded = false
    
    var showMacronutrientWeeklyButton: Bool = false
    
    var body: some View {
        VStack(alignment: .center) {
            HStack() {
                Button(action:{
                    withAnimation(.easeIn) {
                        self.isExpanded.toggle()
                    }
                }
                ) {
                    Image(systemName: "calendar")
                        .imageScale(.medium)
                        .foregroundStyle(AppTheme.milk)
                }
                Spacer()
                VStack(alignment:.center){
                    Button(action: onDateTapped) {
                        
                        let calendar = Calendar.current
                        let todayComponents = calendar.dateComponents([.year, .month, .day], from: Date())
                        let selectedDateComponents = calendar.dateComponents([.year, .month, .day], from: selectedDate)
                        if isExpanded {
                            if todayComponents.year == selectedDateComponents.year &&
                                todayComponents.month == selectedDateComponents.month &&
                                todayComponents.day == selectedDateComponents.day {
                                HStack(alignment: .center){
                                    Text("Today")
                                        .font(.title2)
                                        .fontWeight(.light)
                                        .foregroundStyle(AppTheme.milk)
                                }
                                
                            }
                            Text(selectedDate, style: .date)
                                .font(.title2)
                                .fontWeight(.light)
                                .foregroundStyle(AppTheme.milk)
                            Spacer()
                        } else {
                            if todayComponents.year == selectedDateComponents.year &&
                                todayComponents.month == selectedDateComponents.month &&
                                todayComponents.day == selectedDateComponents.day {
                                HStack(alignment: .center){
                                    Text("Today")
                                        .font(.title2)
                                        .fontWeight(.light)
                                        .foregroundStyle(AppTheme.milk)
                                }
                                Spacer()
                            } else {
                                Text(selectedDate, style: .date)
                                    .font(.title2)
                                    .fontWeight(.light)
                                    .foregroundStyle(AppTheme.milk)
                            }
                        }
                        
                    }
                }
                if !isExpanded && entryType == .diary {
                    Text("\(dateSelectionManager.totalCaloriesConsumed.formattedAsString()) out of \(dateSelectionManager.calorieGoal.formattedAsString()) cal")
                        .font(.headline)
                        .fontWeight(.light)
                        .foregroundStyle(AppTheme.grayMiddle)
                }
            }
                .padding(.vertical)
                if isExpanded{
                DateSelectorView(selectionManager: dateSelectionManager, selectedDate: $dateSelectionManager.selectedDate)
                        .padding(.horizontal)
                }
            
            }

        }
    }





//#Preview {
//    TopBarView()
//}
