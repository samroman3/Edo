//
//  AppTheme.swift
//  caloriecounter
//
//  Created by Sam Roman on 11/30/23.
//

import Foundation
import SwiftUI
#if canImport(WidgetKit)
import WidgetKit
#endif

struct ThemePalette {
    let id: String
    let name: String
    let description: String
    let lime: Color
    let carrot: Color
    let lavender: Color
    let coral: Color
    let teal: Color
    let goldenrod: Color
    let sageGreen: Color
    let dustyRose: Color
    let skyBlue: Color
    let softPurple: Color
    let peach: Color
    let dustyGreen: Color
    let dustyBlue: Color
    let milk: Color
    let prunes: Color
    let grayLight: Color
    let grayMiddle: Color
    let grayDark: Color
    let grayExtra: Color
    let coolGrey: Color
}

final class ThemeManager: ObservableObject {
    static let shared = ThemeManager()

    private enum Keys {
        static let selectedThemeID = "selectedThemeID"
        static let appGroupIdentifier = "group.com.samroman.caloriecounter"
    }

    private let userDefaults: UserDefaults
    @Published private(set) var selectedThemeID: String

    var selectedTheme: ThemePalette {
        let persistedID = userDefaults.string(forKey: Keys.selectedThemeID) ?? selectedThemeID
        return AppTheme.palette(for: persistedID)
    }

    init(userDefaults: UserDefaults = ThemeManager.defaultUserDefaults()) {
        self.userDefaults = userDefaults
        let savedID = userDefaults.string(forKey: Keys.selectedThemeID) ?? AppTheme.ThemeOption.classic.rawValue
        self.selectedThemeID = AppTheme.ThemeOption(rawValue: savedID)?.rawValue ?? AppTheme.ThemeOption.classic.rawValue
    }

    func apply(_ theme: AppTheme.ThemeOption) {
        selectedThemeID = theme.rawValue
        userDefaults.set(theme.rawValue, forKey: Keys.selectedThemeID)
        #if canImport(WidgetKit)
        WidgetCenter.shared.reloadAllTimelines()
        #endif
    }

    private static func defaultUserDefaults() -> UserDefaults {
        if let groupDefaults = UserDefaults(suiteName: Keys.appGroupIdentifier) {
            return groupDefaults
        }
        return .standard
    }
}

struct AppTheme {
    enum ThemeOption: String, CaseIterable, Identifiable {
        case classic
        case sunrise
        case forest

        var id: String { rawValue }

        var palette: ThemePalette {
            AppTheme.palette(for: rawValue)
        }
    }

    private static let defaultPalette = ThemePalette(
        id: ThemeOption.classic.rawValue,
        name: "Classic",
        description: "The original Edo palette.",
        lime: dynamicColor(light: UIColor(red: 163 / 255, green: 195 / 255, blue: 34 / 255, alpha: 1), dark: UIColor(red: 213 / 255, green: 245 / 255, blue: 84 / 255, alpha: 1)),
        carrot: Color(red: 255 / 255, green: 88 / 255, blue: 51 / 255),
        lavender: Color(red: 135 / 255, green: 97 / 255, blue: 216 / 255),
        coral: Color(red: 255 / 255, green: 127 / 255, blue: 80 / 255),
        teal: Color(red: 79 / 255, green: 216 / 255, blue: 194 / 255),
        goldenrod: Color(red: 218 / 255, green: 165 / 255, blue: 32 / 255),
        sageGreen: Color(red: 183 / 255, green: 195 / 255, blue: 176 / 255),
        dustyRose: Color(red: 192 / 255, green: 132 / 255, blue: 151 / 255),
        skyBlue: Color(red: 135 / 255, green: 206 / 255, blue: 235 / 255),
        softPurple: Color(red: 190 / 255, green: 160 / 255, blue: 220 / 255),
        peach: Color(red: 255 / 255, green: 229 / 255, blue: 180 / 255),
        dustyGreen: Color(red: 183 / 255, green: 195 / 255, blue: 176 / 255),
        dustyBlue: Color.blue.opacity(0.7),
        milk: Color(red: 247 / 255, green: 247 / 255, blue: 247 / 255),
        prunes: .black,
        grayLight: Color(red: 208 / 255, green: 208 / 255, blue: 208 / 255),
        grayMiddle: Color(red: 140 / 255, green: 140 / 255, blue: 140 / 255),
        grayDark: Color(red: 94 / 255, green: 94 / 255, blue: 94 / 255),
        grayExtra: Color(red: 28 / 255, green: 28 / 255, blue: 28 / 255),
        coolGrey: Color(red: 38 / 255, green: 40 / 255, blue: 44 / 255)
    )

    private static let sunrisePalette = ThemePalette(
        id: ThemeOption.sunrise.rawValue,
        name: "Sunrise",
        description: "Bright citrus reds, yellows, and warm neutrals.",
        lime: dynamicColor(light: UIColor(red: 244 / 255, green: 181 / 255, blue: 33 / 255, alpha: 1), dark: UIColor(red: 255 / 255, green: 216 / 255, blue: 95 / 255, alpha: 1)),
        carrot: Color(red: 230 / 255, green: 69 / 255, blue: 57 / 255),
        lavender: Color(red: 116 / 255, green: 90 / 255, blue: 191 / 255),
        coral: Color(red: 255 / 255, green: 111 / 255, blue: 76 / 255),
        teal: Color(red: 41 / 255, green: 163 / 255, blue: 156 / 255),
        goldenrod: Color(red: 245 / 255, green: 176 / 255, blue: 35 / 255),
        sageGreen: Color(red: 255 / 255, green: 142 / 255, blue: 111 / 255),
        dustyRose: Color(red: 219 / 255, green: 92 / 255, blue: 122 / 255),
        skyBlue: Color(red: 74 / 255, green: 161 / 255, blue: 255 / 255),
        softPurple: Color(red: 156 / 255, green: 119 / 255, blue: 219 / 255),
        peach: Color(red: 255 / 255, green: 227 / 255, blue: 206 / 255),
        dustyGreen: Color(red: 221 / 255, green: 184 / 255, blue: 92 / 255),
        dustyBlue: Color(red: 49 / 255, green: 115 / 255, blue: 214 / 255).opacity(0.8),
        milk: Color(red: 255 / 255, green: 247 / 255, blue: 240 / 255),
        prunes: Color(red: 35 / 255, green: 18 / 255, blue: 12 / 255),
        grayLight: Color(red: 233 / 255, green: 216 / 255, blue: 201 / 255),
        grayMiddle: Color(red: 169 / 255, green: 134 / 255, blue: 112 / 255),
        grayDark: Color(red: 111 / 255, green: 74 / 255, blue: 58 / 255),
        grayExtra: Color(red: 49 / 255, green: 28 / 255, blue: 18 / 255),
        coolGrey: Color(red: 88 / 255, green: 56 / 255, blue: 40 / 255)
    )

    private static let forestPalette = ThemePalette(
        id: ThemeOption.forest.rawValue,
        name: "Forest",
        description: "Deep evergreen tones with cooler blue contrast.",
        lime: dynamicColor(light: UIColor(red: 53 / 255, green: 163 / 255, blue: 109 / 255, alpha: 1), dark: UIColor(red: 118 / 255, green: 226 / 255, blue: 165 / 255, alpha: 1)),
        carrot: Color(red: 176 / 255, green: 85 / 255, blue: 44 / 255),
        lavender: Color(red: 68 / 255, green: 115 / 255, blue: 214 / 255),
        coral: Color(red: 183 / 255, green: 102 / 255, blue: 84 / 255),
        teal: Color(red: 22 / 255, green: 130 / 255, blue: 114 / 255),
        goldenrod: Color(red: 160 / 255, green: 142 / 255, blue: 56 / 255),
        sageGreen: Color(red: 76 / 255, green: 145 / 255, blue: 95 / 255),
        dustyRose: Color(red: 126 / 255, green: 112 / 255, blue: 150 / 255),
        skyBlue: Color(red: 61 / 255, green: 149 / 255, blue: 204 / 255),
        softPurple: Color(red: 108 / 255, green: 142 / 255, blue: 214 / 255),
        peach: Color(red: 204 / 255, green: 214 / 255, blue: 189 / 255),
        dustyGreen: Color(red: 77 / 255, green: 132 / 255, blue: 86 / 255),
        dustyBlue: Color(red: 38 / 255, green: 92 / 255, blue: 176 / 255).opacity(0.8),
        milk: Color(red: 233 / 255, green: 242 / 255, blue: 235 / 255),
        prunes: Color(red: 10 / 255, green: 30 / 255, blue: 18 / 255),
        grayLight: Color(red: 190 / 255, green: 210 / 255, blue: 194 / 255),
        grayMiddle: Color(red: 101 / 255, green: 127 / 255, blue: 109 / 255),
        grayDark: Color(red: 46 / 255, green: 77 / 255, blue: 56 / 255),
        grayExtra: Color(red: 9 / 255, green: 34 / 255, blue: 18 / 255),
        coolGrey: Color(red: 17 / 255, green: 55 / 255, blue: 34 / 255)
    )

    private static func dynamicColor(light: UIColor, dark: UIColor) -> Color {
        Color(UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return dark
            default:
                return light
            }
        })
    }

    static func palette(for id: String) -> ThemePalette {
        switch ThemeOption(rawValue: id) {
        case .sunrise:
            return sunrisePalette
        case .forest:
            return forestPalette
        case .classic, .none:
            return defaultPalette
        }
    }

    static var current: ThemePalette {
        ThemeManager.shared.selectedTheme
    }

    static let basic = Color(UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return .white
        default:
            return .black
        }
    })

    static let reverse = Color(UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return .black
        default:
            return .white
        }
    })

    static let dynamicGray = Color(UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return UIColor(red: 140 / 255, green: 140 / 255, blue: 140 / 255, alpha: 1)
        default:
            return UIColor(red: 28 / 255, green: 28 / 255, blue: 28 / 255, alpha: 1)
        }
    })

    static var milk: Color { current.milk }
    static var carrot: Color { current.carrot }
    static var prunes: Color { current.prunes }
    static var lavender: Color { current.lavender }
    static var coral: Color { current.coral }
    static var teal: Color { current.teal }
    static var goldenrod: Color { current.goldenrod }
    static var sageGreen: Color { current.sageGreen }
    static var dustyRose: Color { current.dustyRose }
    static var skyBlue: Color { current.skyBlue }
    static var softPurple: Color { current.softPurple }
    static var peach: Color { current.peach }
    static var dustyGreen: Color { current.dustyGreen }
    static var dustyBlue: Color { current.dustyBlue }
    static var lime: Color { current.lime }
    static var grayLight: Color { current.grayLight }
    static var grayMiddle: Color { current.grayMiddle }
    static var grayDark: Color { current.grayDark }
    static var grayExtra: Color { current.grayExtra }
    static var coolGrey: Color { current.coolGrey }

    static let textColor = Color(UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return .white
        default:
            return .black
        }
    })

    static let standardBookLargeTitle = Font.custom("JF Standard", size: 34)
    static let standardBookTitle = Font.custom("JF Standard", size: 28)
    static let standardBookBody = Font.custom("JF Standard", size: 17)
    static let standardBookCaption = Font.custom("JF Standard", size: 15)

    static let titleFont = Font.system(size: 28, weight: .bold, design: .default)
    static let bodyFont = Font.system(size: 17, weight: .regular, design: .default)
    static let captionFont = Font.system(size: 15, weight: .regular, design: .default)
}
