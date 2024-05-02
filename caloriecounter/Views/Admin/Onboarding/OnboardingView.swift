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
    let player = AVPlayer(url:  Bundle.main.url(forResource: "fullloop", withExtension: "mov")!)
    var body: some View {
        ZStack {
            AVPlayerControllerRepresented(player: player)
                .onAppear {
                    player.play()
                    player.rate = 2
                }
                .scaledToFit()
                .padding(.leading,10)
            let _ =  NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: nil) { _ in
                withAnimation(){
                    player.seek(to: .zero)
                    player.play()
                    player.rate = 2
                }
            }
        VStack(spacing: 15) {
            Spacer()
                HStack{
                    Text("Track meals.")
                        .multilineTextAlignment(.center)
                        .font(.title3)
                        .font(AppTheme.bodyFont)
                        .foregroundColor(.white)
                    Text("Meet goals.")
                        .multilineTextAlignment(.center)
                        .font(.title3)
                        .font(AppTheme.bodyFont)
                        .foregroundStyle(.white)
                }
                Text("Edo")
                    .font(AppTheme.titleFont)
                    .foregroundColor(.white)
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
        }
        .background(AppTheme.coolGrey)
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
                        .font(.title)
                        .foregroundColor(AppTheme.textColor)
                        .padding()

                    VStack(alignment: .leading) {
                        HStack {
                            Image(systemName: "icloud.fill")
                                .foregroundColor(.blue)
                                .imageScale(.large)
                            Text("iCloud Sync")
                                .font(.headline)
                                .foregroundStyle(AppTheme.textColor)
                        }
                        Text("Your data is securely stored in iCloud, ensuring it's private and accessible across all your devices. We use iCloud to keep your meal entries and nutrition data in sync.")
                            .foregroundStyle(AppTheme.textColor)
                            .padding(.bottom)

                        HStack {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.red)
                                .imageScale(.large)
                            Text("HealthKit Integration")
                                .font(.headline)
                                .foregroundStyle(AppTheme.textColor)
                        }
                        Text("With your consent, we access HealthKit to track relevant health data, activity levels, and calories burned. This data remains on your device to maintain your privacy.")
                            .foregroundStyle(AppTheme.textColor)
                    }
                    .padding()

                    ConsentAgreementText()

                    Button("Continue", action: onConsentGiven)
                        .font(.headline)
                        .foregroundColor(AppTheme.milk)
                        .padding()
                        .background(AppTheme.carrot)
                        .cornerRadius(10)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .cornerRadius(20)
    }
}

struct ConsentAgreementText: View {
    var body: some View {
        Text("""
            By continuing, you acknowledge and agree to the use of iCloud for storage and HealthKit for health data integration as outlined above. Your privacy is our top priority, and you have full control over your data.
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
        WelcomeScreen(onGetStarted: {})
            .previewLayout(.sizeThatFits)
    }
}

