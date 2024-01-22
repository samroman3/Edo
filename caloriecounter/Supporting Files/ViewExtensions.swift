//
//  ViewExtensions.swift
//  caloriecounter
//
//  Created by Sam Roman on 1/21/24.
//

import SwiftUI

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
