//
//  AudioGraphExample.swift
//  CoreAudioWorkout
//
//  Created by Alistair Cooper on 7/8/24.
//

import AudioToolbox

class AudioGraphExample {
    var audioUnit: AudioUnit?
    var theta: Double = 0.0
    let sampleRate: Double = 44100.0
    let frequency: Double = 440.0
    let amplitude: Float = 0.25

    init() {
        setupAudioGraph()
    }

    func setupAudioGraph() {
        var componentDesc = AudioComponentDescription()
        componentDesc.componentType = kAudioUnitType_Output
        componentDesc.componentSubType = kAudioUnitSubType_RemoteIO
        componentDesc.componentManufacturer = kAudioUnitManufacturer_Apple
        componentDesc.componentFlags = 0
        componentDesc.componentFlagsMask = 0

        guard let component = AudioComponentFindNext(nil, &componentDesc) else {
            fatalError("Can't find component")
        }

        var status = AudioComponentInstanceNew(component, &audioUnit)
        guard status == noErr, let audioUnit = audioUnit else {
            fatalError("AudioComponentInstanceNew error: \(status)")
        }

        // Audio Unit calls this to render the audio data
        var input = AURenderCallbackStruct(inputProc: renderCallback, 
                                           inputProcRefCon: UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()))
        status = AudioUnitSetProperty(audioUnit,
                                      kAudioUnitProperty_SetRenderCallback,
                                      kAudioUnitScope_Input,
                                      0,
                                      &input,
                                      UInt32(MemoryLayout<AURenderCallbackStruct>.size))
        guard status == noErr else {
            fatalError("AudioUnitSetProperty error: \(status)")
        }

        var streamFormat = AudioStreamBasicDescription()
        streamFormat.mSampleRate = sampleRate
        streamFormat.mFormatID = kAudioFormatLinearPCM
        streamFormat.mFormatFlags = kAudioFormatFlagIsFloat | kAudioFormatFlagIsPacked
        streamFormat.mFramesPerPacket = 1
        streamFormat.mChannelsPerFrame = 1
        streamFormat.mBitsPerChannel = 32
        streamFormat.mBytesPerFrame = 4
        streamFormat.mBytesPerPacket = 4

        status = AudioUnitSetProperty(audioUnit,
                                      kAudioUnitProperty_StreamFormat,
                                      kAudioUnitScope_Input,
                                      0,
                                      &streamFormat,
                                      UInt32(MemoryLayout<AudioStreamBasicDescription>.size))
        guard status == noErr else {
            fatalError("AudioUnitSetProperty error: \(status)")
        }

        status = AudioUnitInitialize(audioUnit)
        guard status == noErr else {
            fatalError("AudioUnitInitialize error: \(status)")
        }
    }

    func start() {
        guard let audioUnit = audioUnit else { return }
        let status = AudioOutputUnitStart(audioUnit)
        guard status == noErr else {
            fatalError("AudioOutputUnitStart error: \(status)")
        }
    }

    func stop() {
        guard let audioUnit = audioUnit else { return }
        let status = AudioOutputUnitStop(audioUnit)
        guard status == noErr else {
            fatalError("AudioOutputUnitStop error: \(status)")
        }
    }

    // callback that's rendering the sine wave
    private let renderCallback: AURenderCallback = { (
        inRefCon,
        ioActionFlags,
        inTimeStamp,
        inBusNumber,
        inNumberFrames,
        ioData) -> OSStatus in

        let example = Unmanaged<AudioGraphExample>.fromOpaque(inRefCon).takeUnretainedValue()
        let amplitude: Float = example.amplitude
        let frequency: Float = Float(example.frequency)

        // amount that angle of sine wave should be incremented
        let thetaIncrement = 2.0 * Float.pi * frequency / Float(example.sampleRate)

        if let channelData = ioData?.pointee.mBuffers.mData?.assumingMemoryBound(to: Float.self) {
            for frame in 0..<Int(inNumberFrames) {
                channelData[frame] = amplitude * sin(Float(example.theta))
                example.theta += Double(thetaIncrement)
                if example.theta > 2.0 * Double.pi {
                    example.theta -= 2.0 * Double.pi
                }
            }
        }

        return noErr
    }
}
