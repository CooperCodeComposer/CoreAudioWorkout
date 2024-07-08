//
//  AudioSessionManager.swift
//  CoreAudioWorkout
//
//  Created by Alistair Cooper on 7/8/24.
//

import AVFoundation

class AudioSessionManager {
    static let shared = AudioSessionManager()

    private init() {}

    func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try audioSession.setActive(true)
        } catch {
            print("Audio Session error: \(error.localizedDescription)")
        }
    }
}


