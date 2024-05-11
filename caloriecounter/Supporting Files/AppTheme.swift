//
//  AppTheme.swift
//  caloriecounter
//
//  Created by Sam Roman on 11/30/23.
//

import Foundation
import SwiftUI



struct AppTheme {
    
    static let lime = Color(UIColor { traitCollection in
            // Adjust colors for light and dark mode
            switch traitCollection.userInterfaceStyle {
            case .dark:
                // Use the original lime color for dark mode
                return UIColor(red: 213 / 255, green: 245 / 255, blue: 84 / 255, alpha: 1)
            default:
                // Use a darker shade of lime for light mode for better contrast
                return UIColor(red: 163 / 255, green: 195 / 255, blue: 34 / 255, alpha: 1)
            }
        })

    
    static let basic = Color(UIColor { traitCollection in
            // Adjust colors for light and dark mode
            switch traitCollection.userInterfaceStyle {
            case .dark:
                // Use white color for dark mode
                return .white
            default:
                // Use black for light
                return .black
            }
        })
    
    static let reverse = Color(UIColor { traitCollection in
            // Adjust colors for light and dark mode
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return .black
            default:
                return .white
            }
        })
    static let dynamicGray = Color(UIColor { traitCollection in
        // Adjust colors for light and dark mode
        switch traitCollection.userInterfaceStyle {
        case .dark:
            return UIColor(red: 140 / 255, green: 140 / 255, blue: 140 / 255, alpha: 1) //greyLight
        default:
            return UIColor(red: 28 / 255, green: 28 / 255, blue: 28 / 255, alpha: 1) //greyExtra
        }
    })
    
    static let milk = Color(red: 247 / 255, green: 247 / 255, blue: 247 / 255)
    static let carrot = Color(red: 255 / 255, green: 88 / 255, blue: 51 / 255)
    static let prunes = Color(red: 0, green: 0, blue: 0)
    static let lavender = Color(red: 135 / 255, green: 97 / 255, blue: 216 / 255)
    
    static let coral = Color(red: 255 / 255, green: 127 / 255, blue: 80 / 255)
    static let teal = Color(red: 79 / 255, green: 216 / 255, blue: 194 / 255)
    static let goldenrod = Color(red: 218 / 255, green: 165 / 255, blue: 32 / 255)
    static let sageGreen = Color(red: 183 / 255, green: 195 / 255, blue: 176 / 255)
    static let dustyRose = Color(red: 192 / 255, green: 132 / 255, blue: 151 / 255)
    static let skyBlue = Color(red: 135 / 255, green: 206 / 255, blue: 235 / 255)
    static let softPurple = Color(red: 190 / 255, green: 160 / 255, blue: 220 / 255)
    static let peach = Color(red: 255 / 255, green: 229 / 255, blue: 180 / 255)
    static let dustyGreen = Color(red: 183 / 255, green: 195 / 255, blue: 176 / 255)
    static let dustyBlue = Color.blue.opacity(0.7)
    
    static let grayLight = Color(red: 208 / 255, green: 208 / 255, blue: 208 / 255)
    static let grayMiddle = Color(red: 140 / 255, green: 140 / 255, blue: 140 / 255)
    static let grayDark = Color(red: 94 / 255, green: 94 / 255, blue: 94 / 255)
    static let grayExtra = Color(red: 28 / 255, green: 28 / 255, blue: 28 / 255)
    
    
    
    static let coolGrey = Color(red: 38 / 255, green: 40 / 255, blue: 44 / 255)
    
    static let textColor = Color(UIColor { traitCollection in
           switch traitCollection.userInterfaceStyle {
           case .dark:
               return .white // White text in dark mode
           default:
               return .black // Black text in light mode
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

