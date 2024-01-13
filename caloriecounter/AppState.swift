//
//  AppState.swift
//  caloriecounter
//
//  Created by Sam Roman on 1/11/24.
//

import Foundation

class AppState: ObservableObject {
    static let shared = AppState()

    @Published var isLoggedIn: Bool {
        didSet {
            UserDefaults.standard.set(isLoggedIn, forKey: "isLoggedIn")
        }
    }

    init() {
        // Initialize the logged in state from UserDefaults
        isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
    }

    func login() {
        isLoggedIn = true
    }

    func logout() {
        isLoggedIn = false
    }
}
