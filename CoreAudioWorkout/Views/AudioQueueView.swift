//
//  AudioQueueView.swift
//  CoreAudioWorkout
//
//  Created by Alistair Cooper on 7/8/24.
//

import SwiftUI
import AVFoundation

struct AudioQueueView: View {
    @StateObject private var audioQueueRecorder = AudioQueueRecorder()
    @State private var audioPlayer: AVAudioPlayer?
    @State private var filePath: URL? = nil

    var body: some View {
        VStack {
            Button("Start Recording") {
                if filePath == nil {
                    if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                        filePath = documentsDirectory.appendingPathComponent("recording.caf")
                    } else {
                        print("Unable to get documents directory")
                        return
                    }
                }
                
                audioQueueRecorder.setupAudioQueue(filePath: filePath!)
                audioQueueRecorder.startRecording()
            }
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(8)

            Button("Stop Recording") {
                audioQueueRecorder.stopRecording()
            }
            .padding()
            .background(audioQueueRecorder.isRecording ? Color.blue : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(8)
            .disabled(!audioQueueRecorder.isRecording)

            Button("Play Recording") {
                playRecording()
            }
            .padding()
            .background(filePath == nil ? Color.gray : Color.green)
            .foregroundColor(.white)
            .cornerRadius(8)
            .disabled(filePath == nil)
        }
        .navigationTitle("Audio Queue Recorder")
    }

    func playRecording() {
        guard let filePath = filePath else {
            print("Recording file path not found")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: filePath)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("Failed to play recording: \(error)")
        }
    }
}

struct AudioQueueView_Previews: PreviewProvider {
    static var previews: some View {
        AudioQueueView()
    }
}





