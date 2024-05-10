//
//  OnboardingView.swift
//  caloriecounter
//
//  Created by Sam Roman on 12/11/23.
//

import SwiftUI
import AVKit

struct OnboardingView: View {
    
    @State private var showConsent = false
    @State private var consentGiven = false
    var onOnboardingComplete: () -> Void
    
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
                PersonalHealthDataFormView(onBoardEntry: true, onOnboardingComplete: {
                    onOnboardingComplete()
                })
                .transition(.asymmetric(insertion: .move(edge: .top), removal: .move(edge: .bottom)))
            } else {
                ConsentView(consentGiven: $consentGiven, onConsentGiven: {
                    withAnimation(.spring()){
                        showConsent.toggle()
                        consentGiven = true
                    }
                    
                })
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            }
        }
    }
}

struct AVPlayerControllerRepresented : UIViewControllerRepresentable {
    var player : AVPlayer
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = false
        controller.view.backgroundColor = .clear
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        
    }
}

struct WelcomeScreen: View {
    var onGetStarted: () -> Void
    var player = AVPlayer(url:  Bundle.main.url(forResource: "trimblackedo", withExtension: "mov")!)
    
    var body: some View {
        ZStack {
            VStack(spacing: 15) {
            VStack{
            AVPlayerControllerRepresented(player: player)
                .onAppear {
                    player.play()
                    player.rate = 2
                }
                .scaledToFill()
                let _ =  NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: nil) { _ in
                    withAnimation(){
                        player.seek(to: .zero)
                        player.play()
                        player.rate = 2
                    }
                }
            }.padding(.leading,20)
            Spacer()
                Text("EDO")
                    .font(AppTheme.standardBookLargeTitle)
                    .foregroundColor(.white)
                HStack{
                    Text("Track meals.")
                        .multilineTextAlignment(.center)
                        .font(AppTheme.standardBookBody)
                        .foregroundColor(.white)
                    Text("Meet goals.")
                        .multilineTextAlignment(.center)
                        .font(AppTheme.standardBookBody)
                        .foregroundColor(.white)
                }
                Spacer()
                Button(action: onGetStarted) {
                    HStack {
                        Image(systemName: "arrow.right.circle.fill")
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(AppTheme.carrot)
                    .cornerRadius(10)
                }
        }.padding(.vertical)
        }.background(.black)
    }
}

struct ConsentView: View {
    @Binding var consentGiven: Bool
    var onConsentGiven: () -> Void

    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Privacy & Data Use")
                        .font(AppTheme.standardBookLargeTitle)
                        .foregroundColor(AppTheme.textColor)
                        .padding(.vertical)

                    VStack(alignment: .leading) {
                        HStack {
                            Image(systemName: "icloud.fill")
                                .foregroundColor(.blue)
                                .imageScale(.large)
                            Text("iCloud Sync")
                                .font(AppTheme.standardBookTitle)
                                .foregroundStyle(AppTheme.textColor)
                        }
                        Spacer()
                        Text("Your data is securely stored in iCloud, ensuring it's private and accessible across all your devices. We use iCloud to keep your meal entries and nutrition data in sync.")
                            .foregroundStyle(AppTheme.textColor)
                            .font(.callout)
                            .padding(.vertical)

                        HStack {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.red)
                                .imageScale(.large)
                            Text("HealthKit Integration")
                                .font(AppTheme.standardBookTitle)
                                .foregroundStyle(AppTheme.textColor)
                        }
                        Spacer()
                        Text("With your consent, we access the Health app to track relevant health data, activity levels, and calories burned. This data remains on your device to maintain your privacy.")
                            .font(.callout)
                            .foregroundStyle(AppTheme.textColor)
                            .padding(.vertical)

                    }
                    .padding()
                    Spacer()
                    ConsentAgreementText()
                    Spacer()
                    continueButton
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .cornerRadius(20)
    }
    
    private var continueButton: some View {
        Button(action: {
            onConsentGiven()
            HapticFeedbackProvider.impact()
        }) {
            Text("Continue")
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppTheme.carrot)
                .cornerRadius(10)
        }
        .padding(.horizontal)
    }
    
}


struct ConsentAgreementText: View {
    var body: some View {
        Text("""
            By continuing, you acknowledge and agree to the use of iCloud for storage and Health app for health data integration as outlined above. Your privacy is our top priority, and you have full control over your data.
            """)
            .font(.callout)
            .foregroundStyle(AppTheme.textColor)
            .padding()
    }
}


struct ConsentView_Previews: PreviewProvider {
    static var previews: some View {
        ConsentView(consentGiven: .constant(false), onConsentGiven: {})
    }
}


struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(onOnboardingComplete: {})
            .environmentObject(AppState.shared)
    }
}

struct WelcomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        @Environment(\.colorScheme) var colorScheme
        WelcomeScreen(onGetStarted: {}, player: AVPlayer(url:  Bundle.main.url(forResource: String(colorScheme == .dark ? "trimblackedo" : "trimwhiteedo"), withExtension: "mov")!))
            .previewLayout(.sizeThatFits)
    }
}

