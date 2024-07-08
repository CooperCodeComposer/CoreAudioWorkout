//
//  AudioFileServiceView.swift
//  CoreAudioWorkout
//
//  Created by Alistair Cooper on 7/8/24.
//



import SwiftUI
import AVFoundation



struct AudioFileServiceView: View {
    let audioFileServiceExample = AudioFileServicesExample(filePath: URL(fileURLWithPath: ""), outputFilePath: URL(fileURLWithPath: "outputFile.wav"))
    @State private var audioData: Data = Data()

    var body: some View {
        VStack {
            Button("Read Audio File") {
                if let filePath = Bundle.main.url(forResource: "closed-hi-hat-1", withExtension: "wav", subdirectory: "AudioFiles") {
                    audioFileServiceExample.filePath = filePath
                    audioFileServiceExample.setupAudioFile()
                    audioData = audioFileServiceExample.readAudioData()
                } else {
                    print("Audio file not found")
                }
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)

            Button("Write Audio File") {
                let outputPath = FileManager.default.temporaryDirectory.appendingPathComponent("outputFile.wav")
                audioFileServiceExample.outputFilePath = outputPath
                audioFileServiceExample.writeAudioFile(audioData: audioData)
            }
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(8)

            Text("Read \(audioData.count) bytes of audio data")
                .padding()
        }
        .navigationTitle("Audio File Service Example")
    }
}

struct AudioFileServiceView_Previews: PreviewProvider {
    static var previews: some View {
        AudioFileServiceView()
    }
}

