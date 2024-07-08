//
//  AudioFileServiceExample.swift
//  CoreAudioWorkout
//
//  Created by Alistair Cooper on 7/8/24.
//

import AVFoundation

class AudioFileServicesExample: ObservableObject {
    var audioFile: AudioFileID?
    var audioFormat = AudioStreamBasicDescription()
    var filePath: URL
    var outputFilePath: URL

    init(filePath: URL, outputFilePath: URL) {
        self.filePath = filePath
        self.outputFilePath = outputFilePath
    }

    func setupAudioFile() {
        let audioFileURL = filePath as CFURL

        // Open the audio file
        var status = AudioFileOpenURL(audioFileURL, .readPermission, 0, &audioFile)
        guard status == noErr, let audioFile = audioFile else {
            print("Failed to open audio file: \(status)")
            return
        }

        // Get the audio format
        var dataSize = UInt32(MemoryLayout<AudioStreamBasicDescription>.size)
        status = AudioFileGetProperty(audioFile, kAudioFilePropertyDataFormat, &dataSize, &audioFormat)
        guard status == noErr else {
            print("Failed to get audio format: \(status)")
            return
        }

        // Can print audio format if desired
        print("Audio format sample rate: \(audioFormat.mSampleRate)")
        print("Audio format channels per frame: \(audioFormat.mChannelsPerFrame)")
        print("Audio format bits per channel: \(audioFormat.mBitsPerChannel)")
        print("Audio format ID: \(audioFormat.mFormatID)")

        // Can check for specific format if desired
        assert(audioFormat.mSampleRate == 44100)
        assert(audioFormat.mChannelsPerFrame == 2)
        assert(audioFormat.mBitsPerChannel == 16)
        assert(audioFormat.mFormatID == kAudioFormatLinearPCM)

        print("Audio format: \(audioFormat)")
    }

    func readAudioData() -> Data {
        guard let audioFile = audioFile else { return Data() }

        var audioData = Data()
        let bufferSize: UInt32 = 1024 * 8 // 8 KB buffer size
        var buffer = [UInt8](repeating: 0, count: Int(bufferSize))
        var numBytesToRead = bufferSize
        var numPackets: UInt32 = bufferSize / audioFormat.mBytesPerPacket
        let packetDescriptions: UnsafeMutablePointer<AudioStreamPacketDescription>? = nil

        var packetOffset: Int64 = 0

        repeat {
            let status = AudioFileReadPacketData(audioFile, false, &numBytesToRead, packetDescriptions, packetOffset, &numPackets, &buffer)
            if status == noErr {
                audioData.append(buffer, count: Int(numBytesToRead))
                packetOffset += Int64(numPackets)
            } else if status != kAudioFileEndOfFileError {
                print("Failed to read audio data: \(status)")
                break
            }
        } while numPackets > 0

        // Close the output audio file to release resource
        AudioFileClose(audioFile)

        return audioData
    }

    func writeAudioFile(audioData: Data) {
       
        // Create the output audio file
        var outputAudioFile: AudioFileID?
        var status = AudioFileCreateWithURL(outputFilePath as CFURL, kAudioFileWAVEType, &audioFormat, .eraseFile, &outputAudioFile)
        guard status == noErr, let outputAudioFile = outputAudioFile else {
            print("Failed to create output audio file: \(status)")
            return
        }

        // Write audio data to the output file
        var bytesWritten = UInt32(audioData.count)
        status = AudioFileWritePackets(outputAudioFile, false, UInt32(audioData.count), nil, 0, &bytesWritten, [UInt8](audioData))
        guard status == noErr else {
            print("Failed to write audio data: \(status)")
            return
        }

        // Close the output audio file to release resource
        AudioFileClose(outputAudioFile)
        print("Successfully wrote \(audioData.count) bytes to output file")
    }
}


