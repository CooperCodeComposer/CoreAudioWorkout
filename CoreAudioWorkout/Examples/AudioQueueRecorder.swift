//
//  AudioQueueRecorder.swift
//  CoreAudioWorkout
//
//  Created by Alistair Cooper on 7/8/24.
//

import AVFoundation
import Combine

class AudioQueueRecorder: ObservableObject {
    var audioQueue: AudioQueueRef?
    var audioFile: AudioFileID?
    var bufferSize: UInt32 = 1024 * 8 // 8 KB buffer size
    var currentPacket: Int64 = 0
    @Published var isRecording: Bool = false

    func setupAudioQueue(filePath: URL) {
        var audioFormat = AudioStreamBasicDescription(
            mSampleRate: 44100.0,
            mFormatID: kAudioFormatLinearPCM,
            mFormatFlags: kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked,
            mBytesPerPacket: 2,
            mFramesPerPacket: 1,
            mBytesPerFrame: 2,
            mChannelsPerFrame: 1,
            mBitsPerChannel: 16,
            mReserved: 0
        )
        
        // Create the audio file
        var status = AudioFileCreateWithURL(filePath as CFURL, kAudioFileCAFType, &audioFormat, .eraseFile, &audioFile)
        guard status == noErr, let audioFile = audioFile else {
            print("Failed to create audio file: \(status)")
            return
        }

        // Create the audio queue
        status = AudioQueueNewInput(&audioFormat, audioQueueInputCallback, UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()), nil, nil, 0, &audioQueue)
        guard status == noErr, let audioQueue = audioQueue else {
            print("Failed to create audio queue: \(status)")
            return
        }

        // Allocate and enqueue buffers
        for _ in 0..<3 {
            var buffer: AudioQueueBufferRef?
            status = AudioQueueAllocateBuffer(audioQueue, bufferSize, &buffer)
            guard status == noErr, let buffer = buffer else {
                print("Failed to allocate buffer: \(status)")
                return
            }
            status = AudioQueueEnqueueBuffer(audioQueue, buffer, 0, nil)
            guard status == noErr else {
                print("Failed to enqueue buffer: \(status)")
                return
            }
        }

        print("Audio queue initialized successfully")
    }

    func startRecording() {
        guard let audioQueue = audioQueue else {
            print("Audio queue is not initialized")
            return
        }

        let status = AudioQueueStart(audioQueue, nil)
        guard status == noErr else {
            print("Failed to start audio queue: \(status)")
            return
        }

        DispatchQueue.main.async {
            self.isRecording = true
        }
        print("Audio queue started successfully")
    }

    func stopRecording() {
        guard let audioQueue = audioQueue else {
            print("Audio queue is not initialized")
            return
        }
        let status = AudioQueueStop(audioQueue, true)
        guard status == noErr else {
            print("Failed to stop audio queue: \(status)")
            return
        }

        // Clean up the audio queue and audio file
        AudioQueueDispose(audioQueue, true)
        
        if let audioFile = audioFile {
            AudioFileClose(audioFile)
            self.audioFile = nil
        }
        self.audioQueue = nil // Reset the audio queue to allow reinitialization

        DispatchQueue.main.async {
            self.isRecording = false
        }
        print("Audio queue stopped and disposed successfully")
    }

    private let audioQueueInputCallback: AudioQueueInputCallback = { (
        inUserData,
        inAQ,
        inBuffer,
        inStartTime,
        inNumPackets,
        inPacketDesc) in

        let audioQueueRecorder = Unmanaged<AudioQueueRecorder>.fromOpaque(inUserData!).takeUnretainedValue()

        guard let audioFile = audioQueueRecorder.audioFile else { return }

        if inNumPackets > 0 {
            var numPackets = inNumPackets // Make a mutable copy of inNumPackets
            let status = AudioFileWritePackets(audioFile, false, inBuffer.pointee.mAudioDataByteSize, inPacketDesc, audioQueueRecorder.currentPacket, &numPackets, inBuffer.pointee.mAudioData)
            if status == noErr {
                audioQueueRecorder.currentPacket += Int64(numPackets)
            } else {
                print("Failed to write packets: \(status)")
            }
        }

        // Only enqueue buffer if recording is still active
        if audioQueueRecorder.isRecording {
            let status = AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, nil)
            guard status == noErr else {
                print("Failed to enqueue buffer: \(status)")
                return
            }
        }
    }
}
