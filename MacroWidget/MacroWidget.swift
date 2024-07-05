//
//  MacroWidget.swift
//  MacroWidget
//
//  Created by Sam Roman on 7/4/24.
//

import WidgetKit
import SwiftUI

struct MacronutrientView: View {
    @Environment(\.widgetFamily) var family
    var dailyLogManager: SimplifiedDailyLogManager
    var forcedMacro: MacroType?

    var body: some View {
        Group {
            switch family {
            case .systemSmall:
                smallWidget
            case .systemMedium:
                smallWidget
            case .systemLarge:
                largeWidget
            case .systemExtraLarge:
                largeWidget
            case .accessoryCircular:
                smallWidget
            case .accessoryRectangular:
                smallWidget
            case .accessoryInline:
                smallWidget
            @unknown default:
                smallWidget
            }
        }
        .background(.clear)
    }

    var smallWidget: some View {
           let macro = forcedMacro ?? .calories
           return MacronutrientRingView(
               isSelected: false,
               label: macro.rawValue.capitalized,
               consumed: macroValue(for: macro),
               goal: macroGoal(for: macro),
               color: color(for: macro)
           )
           .frame(width: 130, height: 130)
           .padding(10)
       }
    
    

     var largeWidget: some View {
         VStack(spacing: 20) {
             HStack(spacing: 20) {
                 MacronutrientRingView(
                     isSelected: false, label: "Calories",
                     consumed: dailyLogManager.totalCaloriesConsumed,
                     goal: dailyLogManager.calorieGoal,
                     color: AppTheme.sageGreen
                 )
                 MacronutrientRingView(
                     isSelected: false, label: "Protein",
                     consumed: dailyLogManager.totalGramsProtein,
                     goal: dailyLogManager.proteinGoal,
                     color: AppTheme.lavender
                 )
             }
             HStack(spacing: 20) {
                 MacronutrientRingView(
                     isSelected: false, label: "Carbs",
                     consumed: dailyLogManager.totalGramsCarbs,
                     goal: dailyLogManager.carbGoal,
                     color: AppTheme.goldenrod
                 )
                 MacronutrientRingView(
                     isSelected: false, label: "Fats",
                     consumed: dailyLogManager.totalGramsFats,
                     goal: dailyLogManager.fatGoal,
                     color: AppTheme.carrot
                 )
             }
         }
         .padding(15)
     }

    func macroValue(for macro: MacroType) -> Double {
        switch macro {
        case .calories: return dailyLogManager.totalCaloriesConsumed
        case .protein: return dailyLogManager.totalGramsProtein
        case .carbs: return dailyLogManager.totalGramsCarbs
        case .fats: return dailyLogManager.totalGramsFats
        }
    }

    func macroGoal(for macro: MacroType) -> Double {
        switch macro {
        case .calories: return dailyLogManager.calorieGoal
        case .protein: return dailyLogManager.proteinGoal
        case .carbs: return dailyLogManager.carbGoal
        case .fats: return dailyLogManager.fatGoal
        }
    }

    func color(for macro: MacroType) -> Color {
        switch macro {
        case .calories: return AppTheme.sageGreen
        case .protein: return AppTheme.lavender
        case .carbs: return AppTheme.goldenrod
        case .fats: return AppTheme.carrot
        }
    }
}

class MacroLabel {
    
    static let shared = MacroLabel()
    
    func labelView(macro: String, value: Text) -> some View {
        switch macro {
        case "calories":
            return AnyView(
                HStack(alignment: .center) {
                    Image(systemName: "c.circle")
                        .font(.title2)
                        .foregroundStyle(.black)
                    value
                        .font(AppTheme.standardBookCaption)
                        .foregroundStyle(.black)
                    Spacer()
                }
                    .background(AppTheme.sageGreen)
                    .cornerRadius(15)
            )
        case "protein":
            return AnyView(
                HStack(alignment: .center) {
                    Image(systemName: "p.circle")
                        .font(.title2)
                        .foregroundStyle(.black)
                    value
                        .font(AppTheme.standardBookCaption)
                        .foregroundStyle(.black)
                    Spacer()
                }
                    .background(AppTheme.softPurple)
                    .cornerRadius(15)
            )
        case "carbs":
            return AnyView(
                HStack(alignment: .center) {
                    Image(systemName: "c.circle")
                        .font(.title2)
                        .foregroundStyle(.black)
                    value
                        .font(AppTheme.standardBookCaption)
                        .foregroundStyle(.black)
                    Spacer()
                }
                    .background(AppTheme.goldenrod)
                    .cornerRadius(15)
            )
        case "fats":
            return AnyView(
                HStack(alignment: .center) {
                    Image(systemName: "f.circle")
                        .font(.title2)
                        .foregroundStyle(.black)
                    value
                        .font(AppTheme.standardBookCaption)
                        .foregroundStyle(.black)
                    Spacer()
                }
                    .background(AppTheme.carrot)
                    .cornerRadius(15)
            )
        case "water":
            return AnyView(
                HStack(alignment: .center) {
                    Image(systemName: "w.circle")
                        .font(.title2)
                        .foregroundStyle(.black)
                    value
                        .font(AppTheme.standardBookCaption)
                        .foregroundStyle(.black)
                    Spacer()
                }
                    .background(AppTheme.skyBlue)
                    .cornerRadius(15)
            )
        default:
            return AnyView(EmptyView())
        }
    }
}


struct MacronutrientRingView: View {
    var isSelected: Bool
    var label: String
    var consumed: Double
    var goal: Double
    var color: Color
    
    var body: some View {
        VStack() {
            RingView(consumed: consumed, goal: goal, color: isSelected ? AppTheme.milk : color, isSelected: isSelected)
                .frame(width: 80, height: 80)
                .shadow(radius: 4, x: 2, y: 4)
            
            Text(label)
                .font(AppTheme.standardBookBody)
                .foregroundStyle(AppTheme.textColor)
                .padding(.top, 5)
            
            MacroLabel.shared.labelView(macro: label.lowercased(), value: Text("\(Int(consumed))/\(Int(goal))g"))
                .frame(height: 25)
        }
        .background(.clear)
    }
}

struct RingView: View {
    var consumed: Double
    var goal: Double
    var color: Color
    var isSelected: Bool
    
    var percentageFilled: String {
        let percentage = (consumed / goal) * 100
        return String(format: "%.1f%%", percentage)
    }
    
    var body: some View {
        ZStack {
            // Base circle
            Circle()
                .stroke(lineWidth: 8)
                .opacity(0.5)
                .foregroundColor(AppTheme.dynamicGray)
            
            // Filled portion of the circle
            Circle()
                .trim(from: 0, to: min(CGFloat(consumed / goal), 1))
                .stroke(color, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .rotationEffect(.degrees(-90))
            
            // Display the percentage in the middle of the ring
            Text(percentageFilled)
                .font(.caption)
                .fontWeight(.bold)
        }
        .frame(width: 80, height: 80)
        .overlay(
            // Overlay for the portion exceeding 100%
            GeometryReader { geometry in
                let radius = geometry.size.width / 2
                let excessPercentage = min(max((consumed - goal) / goal, 0), 1)
                
                // Calculate start and end angles for the excess portion
                let startAngle = Angle(degrees: 360 * (1 - excessPercentage) - 90)
                let endAngle = Angle(degrees: 360 * -90)
                if consumed > goal {
                    Path { path in
                        path.addArc(center: CGPoint(x: radius, y: radius), radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
                    }
                    .trim(from: 0, to: 1)
                    .stroke(style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [5]))
                    .foregroundColor(AppTheme.grayExtra)
                }
            }
        )
    }
}

enum MacroType: String, CaseIterable {
    case calories, protein, carbs, fats
    
    func next() -> MacroType {
        let all = MacroType.allCases
        let idx = all.firstIndex(of: self)!
        let next = all.index(after: idx)
        return all[next % all.count]
    }
    
    func previous() -> MacroType {
        let all = MacroType.allCases
        let idx = all.firstIndex(of: self)!
        let previous = (idx - 1 + all.count) % all.count
        return all[previous]
    }
}


struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> MacroEntry {
        MacroEntry(date: Date(), dailyLogManager: SimplifiedDailyLogManager())
    }

    func getSnapshot(in context: Context, completion: @escaping (MacroEntry) -> ()) {
        let dailyLogManager = SimplifiedDailyLogManager()
        dailyLogManager.loadData()
        let entry = MacroEntry(date: Date(), dailyLogManager: dailyLogManager)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let dailyLogManager = SimplifiedDailyLogManager()
        dailyLogManager.loadData()

        let currentDate = Date()
        let calendar = Calendar.current
        
        // Create entries for the next 24 hours
        var entries: [MacroEntry] = []
        
        // Add an immediate entry
        entries.append(MacroEntry(date: currentDate, dailyLogManager: dailyLogManager))
        
        // Add entries for every hour
        for hourOffset in 1...24 {
            guard let entryDate = calendar.date(byAdding: .hour, value: hourOffset, to: currentDate) else { continue }
            
            // Create a new SimplifiedDailyLogManager for each entry to ensure fresh data
            let entryDailyLogManager = SimplifiedDailyLogManager()
            entryDailyLogManager.loadData()
            
            let entry = MacroEntry(date: entryDate, dailyLogManager: entryDailyLogManager)
            entries.append(entry)
        }
        
        // Create the timeline
        let timeline = Timeline(entries: entries, policy: .atEnd)
        
        completion(timeline)
    }
}

struct MacroEntry: TimelineEntry {
    let date: Date
    let dailyLogManager: SimplifiedDailyLogManager
}

struct MacronutrientWidget: Widget {
    let kind: String = "MacronutrientWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            MacronutrientWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Macronutrient Progress")
        .description("Track your daily macronutrient intake.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct CaloriesWidget: Widget {
    let kind: String = "CaloriesWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            MacronutrientWidgetEntryView(entry: entry, forcedMacro: .calories)
        }
        .configurationDisplayName("Calories")
        .description("Track your daily calorie intake.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct ProteinWidget: Widget {
    let kind: String = "ProteinWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            MacronutrientWidgetEntryView(entry: entry, forcedMacro: .protein)
        }
        .configurationDisplayName("Protein")
        .description("Track your daily protein intake.")
        .supportedFamilies([.systemSmall,.systemMedium])
    }
}

struct CarbsWidget: Widget {
    let kind: String = "CarbsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            MacronutrientWidgetEntryView(entry: entry, forcedMacro: .carbs)
        }
        .configurationDisplayName("Carbs")
        .description("Track your daily carb intake.")
        .supportedFamilies([.systemSmall,.systemMedium]) 
    }
}

struct FatsWidget: Widget {
    let kind: String = "FatsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            MacronutrientWidgetEntryView(entry: entry, forcedMacro: .fats)
        }
        .configurationDisplayName("Fats")
        .description("Track your daily fat intake.")
        .supportedFamilies([.systemSmall,.systemMedium])
    }
}

struct WaterIntakeWidget: Widget {
    let kind: String = "WaterIntakeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WaterIntakeWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Water Intake")
        .description("Track your daily water intake.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct WaterIntakeWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        GeometryReader { geometry in
            WaterIntakeView(dailyLogManager: entry.dailyLogManager)
                .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .containerBackground(.clear, for: .widget)
    }
}

struct WaterIntakeView: View {
    var dailyLogManager: SimplifiedDailyLogManager

    var body: some View {
        VStack {
            RingView(consumed: dailyLogManager.currentWaterIntake,
                     goal: dailyLogManager.waterIntakeGoal,
                     color: AppTheme.skyBlue,
                     isSelected: false)
            .frame(width: 80, height: 80)
            .shadow(radius: 4, x: 2, y: 4)
            
            Text("Water")
                .font(AppTheme.standardBookBody)
                .foregroundStyle(AppTheme.textColor)
                .padding(.top, 5)

            MacroLabel.shared.labelView(macro: "water", value: Text("\(dailyLogManager.currentWaterIntake, specifier: "%.1f") / \(dailyLogManager.waterIntakeGoal, specifier: "%.1f") L"))
                .foregroundColor(AppTheme.textColor)
                .frame(height: 25)
        }
    }
}

struct MacronutrientWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    var forcedMacro: MacroType?

    var body: some View {
        GeometryReader { geometry in
            MacronutrientView(dailyLogManager: entry.dailyLogManager, forcedMacro: forcedMacro)
                .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .containerBackground(.clear, for: .widget)
    }
}

#Preview(as: .systemSmall) {
    MacronutrientWidget()
} timeline: {
    MacroEntry(date: .now, dailyLogManager: SimplifiedDailyLogManager())
}

#Preview(as: .systemMedium) {
    MacronutrientWidget()
} timeline: {
    MacroEntry(date: .now, dailyLogManager: SimplifiedDailyLogManager())
}


class SimplifiedDailyLogManager: ObservableObject {
    @Published var breakfastCalories: Double = 0
    @Published var lunchCalories: Double = 0
    @Published var dinnerCalories: Double = 0
    @Published var snackCalories: Double = 0
    
    @Published var calorieGoal: Double = 0
    @Published var totalGramsProtein: Double = 0
    @Published var proteinGoal: Double = 0
    @Published var totalGramsCarbs: Double = 0
    @Published var carbGoal: Double = 0
    @Published var totalGramsFats: Double = 0
    @Published var fatGoal: Double = 0
    
    @Published var currentWaterIntake: Double = 0.0
    @Published var waterIntakeGoal: Double = 2.7

    var totalCaloriesConsumed: Double {
        return breakfastCalories + lunchCalories + dinnerCalories + snackCalories
    }

    private let userDefaults: UserDefaults
    private let appGroupIdentifier = "group.com.samroman.caloriecounter"

    init() {
        guard let groupDefaults = UserDefaults(suiteName: appGroupIdentifier) else {
            fatalError("Failed to initialize UserDefaults with App Group")
        }
        self.userDefaults = groupDefaults
        loadData()
    }

    func loadData() {
        breakfastCalories = userDefaults.double(forKey: "breakfastCalories")
        lunchCalories = userDefaults.double(forKey: "lunchCalories")
        dinnerCalories = userDefaults.double(forKey: "dinnerCalories")
        snackCalories = userDefaults.double(forKey: "snackCalories")
        
        calorieGoal = userDefaults.double(forKey: "calorieGoal")
        
        totalGramsProtein = userDefaults.double(forKey: "totalGramsProtein")
        proteinGoal = userDefaults.double(forKey: "proteinGoal")
        totalGramsCarbs = userDefaults.double(forKey: "totalGramsCarbs")
        carbGoal = userDefaults.double(forKey: "carbGoal")
        totalGramsFats = userDefaults.double(forKey: "totalGramsFats")
        fatGoal = userDefaults.double(forKey: "fatGoal")
        
        // Ensure default values if data is not available
        if calorieGoal == 0 { calorieGoal = 2000 }
        if proteinGoal == 0 { proteinGoal = 50 }
        if carbGoal == 0 { carbGoal = 250 }
        if fatGoal == 0 { fatGoal = 70 }
        
        currentWaterIntake = userDefaults.double(forKey: "currentWaterIntake")
        waterIntakeGoal = userDefaults.double(forKey: "waterIntakeGoal")

        // Ensure default value if data is not available
        if waterIntakeGoal == 0 { waterIntakeGoal = 2.7 }
        
        objectWillChange.send()
    }
}
