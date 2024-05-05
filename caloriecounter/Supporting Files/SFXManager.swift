//
//  SFXManager.swift
//  caloriecounter
//
//  Created by Sam Roman on 5/5/24.
//

import Foundation
import AVFoundation

class SFXManager {
    static let shared = SFXManager()
    private var audioPlayer: AVAudioPlayer?

    func playSound(named soundName: String) {
        guard let url = Bundle.main.url(forResource: soundName, withExtension: "mov") else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Could not load sound file.")
        }
    }
}
