//
//  ContentView.swift
//  CoreAudioWorkout
//
//  Created by Alistair Cooper on 7/8/24.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject private var audioFileServicesExample = AudioFileServicesExample(filePath: URL(fileURLWithPath: ""), outputFilePath: URL(fileURLWithPath: ""))
    @State private var audioData: Data = Data()
    
    var body: some View {
        VStack {
            Text("Audio File Services Example")
                .font(.largeTitle)
                .padding()
            
            Button(action: readAudioFile) {
                Text("Read Audio File")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()

            Button(action: writeAudioFile) {
                Text("Write Audio File")
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()

            Text("Read \(audioData.count) bytes of audio data")
                .padding()
        }
        .padding()
        .onAppear {
            setupPaths()
        }
    }
    
    func setupPaths() {
        if let inputPath = Bundle.main.path(forResource: "closed-hi-hat-1", ofType: "wav", inDirectory: "AudioFiles") {
            let inputFilePath = inputPath
            audioFileServicesExample.filePath = URL(fileURLWithPath: inputFilePath)
            print("Input file path: \(inputFilePath)")
        } else {
            print("Input file not found.")
            let bundlePath = Bundle.main.bundlePath
            print("Bundle path: \(bundlePath)")
            
            // List all files in the bundle directory for debugging
            let fileManager = FileManager.default
            do {
                let contents = try fileManager.contentsOfDirectory(atPath: bundlePath)
                print("Bundle contents: \(contents)")
            } catch {
                print("Failed to list bundle contents: \(error)")
            }
        }
        
        let outputFilePath = (Bundle.main.bundlePath as NSString).appendingPathComponent("outputfile.wav")
        audioFileServicesExample.outputFilePath = URL(fileURLWithPath: outputFilePath)
        print("Output file path: \(outputFilePath)")
    }
    
    func readAudioFile() {
        audioFileServicesExample.setupAudioFile()
        audioData = audioFileServicesExample.readAudioData()
    }
    
    func writeAudioFile() {
        audioFileServicesExample.writeAudioFile(audioData: audioData)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}



