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
            print("Audio session set up successfully")
        } catch {
            print("Audio Session error: \(error.localizedDescription)")
        }
    }
    
    func observeInterruptions() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleInterruption(_:)),
            name: AVAudioSession.interruptionNotification,
            object: AVAudioSession.sharedInstance()
        )
    }

    @objc func handleInterruption(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }

        switch type {
        case .began:
            print("Audio session interruption began")
            // Pause audio playback or recording here

        case .ended:
            print("Audio session interruption ended - wheew")
            if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
                    // Resume audio playback or recording here
                    do {
                        try AVAudioSession.sharedInstance().setActive(true)
                        // Restart playback or recording
                    } catch {
                        print("Failed to reactivate audio session: \(error)")
                    }
                }
            }
        @unknown default:
            break
        }
    }
}


