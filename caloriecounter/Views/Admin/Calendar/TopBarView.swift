//
//  TopBarView.swift
//  caloriecounter
//
//  Created by Sam Roman on 11/24/23.
//
import SwiftUI
struct TopBarView: View {
    @ObservedObject var dailyLogManager: DailyLogManager
    @ObservedObject var nutritionDataStore: NutritionDataStore
    @EnvironmentObject var userSettings: UserSettingsManager
    
    @Binding var selectedDate: Date
    
    var onDateTapped: () -> Void
    var onCalendarTapped: () -> Void
    
    @State var isExpanded = false
    
    var showMacronutrientWeeklyButton: Bool = false
    
    var body: some View {
        VStack(alignment: .center) {
            HStack() {
                Spacer()
                Button(action:{
                    withAnimation(.easeIn) {
                        self.isExpanded.toggle()
                    }
                }
                ) {
                    Image(systemName: "calendar")
                        .imageScale(.medium)
                        .foregroundStyle(AppTheme.textColor)
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
                                        .font(AppTheme.standardBookTitle)
                                        .foregroundStyle(AppTheme.textColor)
                                    
                                }
                                
                            }
                            Text(selectedDate, style: .date)
                                .font(AppTheme.standardBookBody)
                                .foregroundStyle(AppTheme.textColor)
                            Spacer()
                        } else {
                            if todayComponents.year == selectedDateComponents.year &&
                                todayComponents.month == selectedDateComponents.month &&
                                todayComponents.day == selectedDateComponents.day {
                                HStack(alignment: .center){
                                    Text("Today")
                                        .font(AppTheme.standardBookTitle)
                                        .foregroundStyle(AppTheme.textColor)
                                }
                                Spacer()
                            } else {
                                Text(selectedDate, style: .date)
                                    .font(AppTheme.standardBookTitle)
                                    .foregroundStyle(AppTheme.textColor)
                                Spacer()
                            }
                        }
                        
                    }
                }
            }
            .padding(.vertical)
            if isExpanded {
                DateSelectorView(selectionManager: dailyLogManager, selectedDate: $dailyLogManager.selectedDate)
                    .padding(.horizontal)
            }
            
        }
        
    }
}

//#Preview {
//    TopBarView()
//}
