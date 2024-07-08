//
//  AudioSessionManager.swift
//  CoreAudioWorkout
//
//  Created by Alistair Cooper on 7/8/24.
//

import AVFoundation

class AudioSessionManager: ObservableObject {
    let audioSession = AVAudioSession.sharedInstance()

    init() {
        setupAudioSession()
    }

    func setupAudioSession() {
        do {
            // Set the audio session category to play and record
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            
            // Activate the audio session
            try audioSession.setActive(true)
            print("Audio session activated successfully")
            
            // Add an observer for interruption notifications
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(handleInterruption(_:)),
                name: AVAudioSession.interruptionNotification,
                object: audioSession
            )
        } catch {
            print("Failed to set up and activate audio session: \(error)")
        }
    }

    @objc func handleInterruption(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }

        switch type {
        case .began:
            // Interruption began, deactivate the audio session
            print("Audio session interruption began")
            do {
                try audioSession.setActive(false)
            } catch {
                print("Failed to deactivate audio session: \(error)")
            }
        case .ended:
            // Interruption ended, reactivate the audio session
            print("Audio session interruption ended")
            do {
                try audioSession.setActive(true)
            } catch {
                print("Failed to reactivate audio session: \(error)")
            }
        @unknown default:
            break
        }
    }
}

