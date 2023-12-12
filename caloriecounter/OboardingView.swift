//
//  OboardingView.swift
//  caloriecounter
//
//  Created by Sam Roman on 12/11/23.
//

import SwiftUI

struct OnboardingView: View {
    @State private var showConsent = false
    // Include additional state variables as needed for the onboarding process
    
    var body: some View {
        VStack {
            if !showConsent {
                WelcomeScreen(onGetStarted: {
                    withAnimation(.spring()) {
                        showConsent.toggle()
                    }
                })
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            } else {
                UserConsentScreen(onConsentGiven: {
                    // Handle consent given
                }, onNavigateBack: {
                    withAnimation(.spring()) {
                        showConsent.toggle()
                    }
                })
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            }
        }
    }
}

struct WelcomeScreen: View {
    var onGetStarted: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Replace with your own images and text
            Image("WelcomeImage")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding()
            Text("Welcome to Eazeat")
                .font(AppTheme.titleFont)
                .foregroundColor(AppTheme.lime)
            Text("Track your meals and meet your goals!")
                .font(AppTheme.bodyFont)
                .foregroundColor(AppTheme.grayMiddle)
            Button(action: onGetStarted) {
                HStack {
                    Text("Get Started")
                        .font(AppTheme.titleFont)
                    Image(systemName: "arrow.right.circle.fill")
                }
                .foregroundColor(.white)
                .padding()
                .background(AppTheme.carrot)
                .cornerRadius(10)
            }
        }
        .padding()
        .background(AppTheme.grayDark)
        .cornerRadius(20)
        .shadow(color: .gray, radius: 10, x: 0, y: 10)
    }
}

struct UserConsentScreen: View {
    var onConsentGiven: () -> Void
    var onNavigateBack: () -> Void
    
    var body: some View {
        VStack {
            Text("User Consent")
                .font(AppTheme.titleFont)
                .foregroundColor(AppTheme.lime)
            Text("Please give your consent to continue")
                .font(AppTheme.bodyFont)
                .foregroundColor(AppTheme.grayMiddle)
                .padding()
            Button("Consent and Continue", action: onConsentGiven)
                .font(AppTheme.bodyFont)
                .foregroundColor(.white)
                .padding()
                .background(AppTheme.lavender)
                .cornerRadius(10)
            Button("Back", action: onNavigateBack)
                .font(AppTheme.captionFont)
                .foregroundColor(AppTheme.grayMiddle)
        }
        .padding()
        .background(AppTheme.grayExtra)
        .cornerRadius(20)
        .shadow(color: .gray, radius: 10, x: 0, y: 10)
    }
}

