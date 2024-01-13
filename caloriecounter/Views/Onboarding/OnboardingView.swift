//
//  OnboardingView.swift
//  caloriecounter
//
//  Created by Sam Roman on 12/11/23.
//

import SwiftUI

struct OnboardingView: View {
    
    @State private var showConsent = false
    @State private var consentGiven = false
    
    var onOnboardingComplete: () -> Void
    
    var onLoginSuccess: () -> Void

    var body: some View {
        VStack {
            if !showConsent && !consentGiven {
                WelcomeScreen(onGetStarted: {
                    withAnimation(.spring()) {
                        showConsent.toggle()
                    }
                })
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            }
            else if !showConsent && consentGiven {
                PersonalHealthDataFormView(onBoardEntry: true, onOnboardingComplete: onOnboardingComplete, onLoginSuccess: onLoginSuccess)
                    .transition(.asymmetric(insertion: .move(edge: .top), removal: .move(edge: .bottom)))
            } else {
                ConsentView(consentGiven: $consentGiven, onConsentGiven: {
                    withAnimation(.spring()){
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
            Image("Logo")
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
struct ConsentView: View {
    @Binding var consentGiven: Bool
    var onConsentGiven: () -> Void

    var body: some View {
        VStack {
            ScrollView {
                Text("User Consent")
                    .font(AppTheme.titleFont)
                    .foregroundColor(AppTheme.lime)
                    .padding()

                Text("We Respect Your Privacy")
                    .font(AppTheme.bodyFont)
                    .foregroundColor(AppTheme.grayMiddle)
                    .padding(.bottom)

                Text("""
                    Eazeat is committed to protecting your privacy. We ask for your consent to collect and use your health and dietary data to personalize your experience and provide you with accurate nutritional insights.
                    
                    Data Collection:
                    - We collect data related to your meals, nutritional intake, and physical activities.
                    - With your permission, we will access your HealthKit data to enhance your meal tracking and goal setting.
                    
                    Data Use:
                    - Your data helps us tailor your dietary goals and recommendations.
                    - We use your data to provide you with progress reports and nutritional analysis.
                    
                    Data Sharing:
                    - We do not share your personal data with third parties without your explicit consent.
                    - Anonymized data may be used for improving the app and related services.

                    You have the right to withdraw your consent at any time in the app settings.
                    
                    By giving consent, you agree to our Privacy Policy and Terms of Service.
                    """)
                    .font(AppTheme.bodyFont)
                    .foregroundColor(AppTheme.grayLight)
                    .padding()

                HStack {
                    Button("Decline", action: {
                        consentGiven = false
                    })
                    .font(AppTheme.bodyFont)
                    .foregroundColor(.red)
                    .padding()
                    
                    Button("Consent", action: {
                        consentGiven = true
                        onConsentGiven()
                    })
                    .font(AppTheme.bodyFont)
                    .foregroundColor(AppTheme.lavender)
                    .padding()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.grayExtra)
        .cornerRadius(20)
        .shadow(color: .gray, radius: 10, x: 0, y: 10)
    }
}

