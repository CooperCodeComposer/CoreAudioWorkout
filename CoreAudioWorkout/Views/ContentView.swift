//
//  ContentView.swift
//  CoreAudioWorkout
//
//  Created by Alistair Cooper on 7/8/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: AudioGraphView()) {
                    Text("Audio Graph - Sine Wave")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()

                NavigationLink(destination: AudioFileServiceView()) {
                    Text("Audio File Service")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
            }
            .onAppear {
                AudioSessionManager.shared.setupAudioSession()
            }
            .navigationTitle("Core Audio Workout 💪🏻")
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}




