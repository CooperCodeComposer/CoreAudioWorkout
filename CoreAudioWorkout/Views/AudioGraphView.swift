//
//  AudioGraphView.swift
//  CoreAudioWorkout
//
//  Created by Alistair Cooper on 7/8/24.
//

import SwiftUI

struct AudioGraphView: View {
    let audioGraphExample = AudioGraphExample()

    var body: some View {
        VStack {
            Button("Start Sine Wave") {
                audioGraphExample.start()
            }
            .padding()

            Button("Stop Sine Wave") {
                audioGraphExample.stop()
            }
            .padding()
        }
        .navigationTitle("Audio Graph Example")
    }
}

struct AudioGraphView_Previews: PreviewProvider {
    static var previews: some View {
        AudioGraphView()
    }
}
