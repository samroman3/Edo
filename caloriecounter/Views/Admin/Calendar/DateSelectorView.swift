//
//  DateSelectorView.swift
//  caloriecounter
//
//  Created by Sam Roman on 11/24/23.
//

import SwiftUI

struct DateSelectorView: View {
    @StateObject var selectionManager: DailyLogManager
    @Binding var selectedDate: Date
    @State private var weekDates: [Date] = []
    
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E dd"
        return formatter
    }()
    
    var body: some View {
        HStack{
            Button("<") {
                moveWeek(by: -1)
                provideHapticFeedback()
            }
            .foregroundStyle(AppTheme.basic)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(weekDates, id: \.self) { date in
                        Button(action: {
                            self.selectedDate = date
                            selectionManager.updateSelectedDate(newDate: date)
                            provideHapticFeedback()
                        }) {
                            Text(dateFormatter.string(from: date))
                                .foregroundColor(isDateSelected(date) ? AppTheme.reverse : AppTheme.textColor)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(isDateSelected(date) ? AppTheme.basic : AppTheme.reverse)
                                .cornerRadius(20)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .onAppear {
                generateWeekDates()
            }
            .onChange(of: selectedDate) { newDate in
                if !weekDates.contains(where: { calendar.isDate($0, inSameDayAs: newDate) }) {
                        generateWeekDates(from: newDate)
                    }
                   }
            Button(">") {
                moveWeek(by: 1)
                provideHapticFeedback()
            }
            .foregroundStyle(AppTheme.basic)
        }
    }

    private func generateWeekDates() {
        guard let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: selectedDate)) else { return }
        weekDates = (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: weekStart)
        }
    }
    
    private func moveWeek(by offset: Int) {
        if let newWeekStart = calendar.date(byAdding: .weekOfYear, value: offset, to: weekDates.first ?? selectedDate),
           let newWeekEnd = calendar.date(byAdding: .day, value: -1, to: newWeekStart) {
            
            generateWeekDates(from: offset < 0 ? newWeekEnd : newWeekStart)

            // Set selectedDate to the last day of the previous week when moving to previous week
            // and to the first day of the next week when moving to next week.
            selectedDate = offset < 0 ? newWeekEnd : newWeekStart
            selectionManager.updateSelectedDate(newDate: selectedDate)
        }
    }

    private func generateWeekDates(from startDate: Date) {
        let startOfWeek = startDate
        weekDates = (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: startOfWeek)
        }
    }

    func resetToCurrentWeek() {
        let today = Date()
        selectedDate = today
        generateWeekDates(from: today)
        selectionManager.updateSelectedDate(newDate: today)
    }
    private func isDateSelected(_ date: Date) -> Bool {
        return calendar.isDate(selectedDate, inSameDayAs: date)
    }
    
    private func provideHapticFeedback() {
           let generator = UIImpactFeedbackGenerator(style: .medium)
           generator.impactOccurred()
       }
}





//#Preview {
//    DateSelectorView()
//}
