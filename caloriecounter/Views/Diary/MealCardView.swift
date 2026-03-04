//
//  MealCardView.swift
//  caloriecounter
//
//  Created by Sam Roman on 11/24/23.

import SwiftUI
import CoreData
import UniformTypeIdentifiers
import UIKit

struct MealCardView: View {
    let mealType: String
    let entries: [NutritionEntry]
    @Binding var isExpanded: Bool
    var onAddTapped: () -> Void
    var onEntryTapped: (NutritionEntry) -> Void
    var onDropEntry: (UUID) -> Bool
    
    @State private var isDropTargeted = false

    private var previewEntries: [(entry: NutritionEntry, image: UIImage)] {
        entries.compactMap { entry in
            guard let imageData = NutritionDataStore.storedImageData(for: entry).first,
                  let image = UIImage(data: imageData) else {
                return nil
            }
            return (entry, image)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(mealType)
                        .font(AppTheme.standardBookLargeTitle)
                        .foregroundStyle(AppTheme.textColor)

                    if !isExpanded && !previewEntries.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(Array(previewEntries.enumerated()), id: \.element.entry.objectID) { _, item in
                                    Button {
                                        onEntryTapped(item.entry)
                                    } label: {
                                        Image(uiImage: item.image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 44, height: 44)
                                            .clipShape(RoundedRectangle(cornerRadius: 14))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 14)
                                                    .stroke(AppTheme.grayLight.opacity(0.55), lineWidth: 1)
                                            )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .frame(height: 44)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
                Spacer()
                Button(action:{
                    let _ = HapticFeedbackProvider.impact()
                    onAddTapped()
                }
                ) {
                    Image(systemName: "plus")
                        .resizable()
                        .font(AppTheme.standardBookLargeTitle)
                        .foregroundStyle(AppTheme.textColor)
                        .frame(width: 25, height: 25)
                }
                .padding(.vertical)
            }
            
            .padding(.horizontal)
            .contentShape(Rectangle())
            .onTapGesture {
                onAddTapped()
            }
            if isExpanded {
                ForEach(entries, id: \.self) { entry in
                    NutritionEntryView(entry: entry)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .contentShape(Rectangle())
                        .onTapGesture {
                            onEntryTapped(entry)
                        }
                        .onDrag {
                            HapticFeedbackProvider.impact()
                            return dragProvider(for: entry.id)
                        }
                }
            }
        }
        .padding(.vertical, 8)
        .background(isDropTargeted ? AppTheme.grayLight.opacity(0.25) : .clear)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .onDrop(of: [UTType.plainText], isTargeted: $isDropTargeted) { providers in
            handleDrop(providers: providers)
        }
    }

    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first,
              provider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) else {
            return false
        }

        provider.loadDataRepresentation(forTypeIdentifier: UTType.plainText.identifier) { data, _ in
            guard let data,
                  let identifier = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
                  let entryID = UUID(uuidString: identifier) else {
                return
            }

            DispatchQueue.main.async {
                if onDropEntry(entryID) {
                    HapticFeedbackProvider.impact()
                }
            }
        }

        return true
    }

    private func dragProvider(for id: UUID) -> NSItemProvider {
        let provider = NSItemProvider()
        let data = Data(id.uuidString.utf8)
        provider.registerDataRepresentation(forTypeIdentifier: UTType.plainText.identifier, visibility: .all) { completion in
            completion(data, nil)
            return nil
        }
        return provider
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
            HStack(alignment: .firstTextBaseline, spacing: 3){
                MacroLabel.shared.labelView(macro: "calories", value: "\(Int(totalCalories))g")
                MacroLabel.shared.labelView(macro: "protein", value: "\(Int(totalProtein))g")
                MacroLabel.shared.labelView(macro: "carbs", value: "\(Int(totalCarbs))g")
                MacroLabel.shared.labelView(macro: "fats", value: "\(Int(totalFats))g")
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
    
    func labelView(macro: String, value: String) -> some View {
        switch macro {
        case "calories":
            return AnyView(
                HStack(alignment: .center) {
                    Image(systemName: "c.circle")
                        .font(.title2)
                        .foregroundStyle(.black)
                    Text(value)
                        .font(AppTheme.standardBookCaption)
                        .foregroundStyle(.black)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                        .allowsTightening(true)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(AppTheme.sageGreen)
                .cornerRadius(15)
            )
        case "protein":
            return AnyView(
                HStack(alignment: .center) {
                    Image(systemName: "p.circle")
                        .font(.title2)
                        .foregroundStyle(.black)
                    Text(value)
                        .font(AppTheme.standardBookCaption)
                        .foregroundStyle(.black)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                        .allowsTightening(true)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(AppTheme.softPurple)
                .cornerRadius(15)
            )
        case "carbs":
            return AnyView(
                HStack(alignment: .center) {
                    Image(systemName: "c.circle")
                        .font(.title2)
                        .foregroundStyle(.black)
                    Text(value)
                        .font(AppTheme.standardBookCaption)
                        .foregroundStyle(.black)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                        .allowsTightening(true)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(AppTheme.goldenrod)
                .cornerRadius(15)
            )
        case "fats":
            return AnyView(
                HStack(alignment: .center) {
                    Image(systemName: "f.circle")
                        .font(.title2)
                        .foregroundStyle(.black)
                    Text(value)
                        .font(AppTheme.standardBookCaption)
                        .foregroundStyle(.black)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                        .allowsTightening(true)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
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
