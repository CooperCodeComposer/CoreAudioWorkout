//
//  CoreAudioWorkoutApp.swift
//  CoreAudioWorkout
//
//  Created by Alistair Cooper on 7/8/24.
//

import SwiftUI

@main
struct CoreAudioWorkoutApp: App {
    @StateObject private var audioSessionManager = AudioSessionManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(audioSessionManager)
        }
    }
}
