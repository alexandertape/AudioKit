//
//  AKLowPassFilter.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// AudioKit version of Apple's LowPassFilter Audio Unit
///
/// - parameter input: Input node to process
/// - parameter cutoffFrequency: Cutoff Frequency (Hz) ranges from 10 to 22050 (Default: 6900)
/// - parameter resonance: Resonance (dB) ranges from -20 to 40 (Default: 0)
///
public class AKLowPassFilter: AKNode, AKToggleable {

    private let cd = AudioComponentDescription(
        componentType: kAudioUnitType_Effect,
        componentSubType: kAudioUnitSubType_LowPassFilter,
        componentManufacturer: kAudioUnitManufacturer_Apple,
        componentFlags: 0,
        componentFlagsMask: 0)

    internal var internalEffect = AVAudioUnitEffect()
    internal var internalAU = AudioUnit()

    private var mixer: AKMixer

    /// Cutoff Frequency (Hz) ranges from 10 to 22050 (Default: 6900)
    public var cutoffFrequency: Double = 6900 {
        didSet {
            if cutoffFrequency < 10 {
                cutoffFrequency = 10
            }            
            if cutoffFrequency > 22050 {
                cutoffFrequency = 22050
            }
            AudioUnitSetParameter(
                internalAU,
                kLowPassParam_CutoffFrequency,
                kAudioUnitScope_Global, 0,
                Float(cutoffFrequency), 0)
        }
    }

    /// Resonance (dB) ranges from -20 to 40 (Default: 0)
    public var resonance: Double = 0 {
        didSet {
            if resonance < -20 {
                resonance = -20
            }            
            if resonance > 40 {
                resonance = 40
            }
            AudioUnitSetParameter(
                internalAU,
                kLowPassParam_Resonance,
                kAudioUnitScope_Global, 0,
                Float(resonance), 0)
        }
    }

    /// Dry/Wet Mix (Default 100)
    public var dryWetMix: Double = 100 {
        didSet {
            if dryWetMix < 0 {
                dryWetMix = 0
            }
            if dryWetMix > 100 {
                dryWetMix = 100
            }
            inputGain?.volume = 1 - dryWetMix / 100
            effectGain?.volume = dryWetMix / 100
        }
    }

    private var lastKnownMix: Double = 100
    private var inputGain: AKMixer?
    private var effectGain: AKMixer?

    /// Tells whether the node is processing (ie. started, playing, or active)
    public var isStarted = true

    /// Initialize the low pass filter node
    ///
    /// - parameter input: Input node to process
    /// - parameter cutoffFrequency: Cutoff Frequency (Hz) ranges from 10 to 22050 (Default: 6900)
    /// - parameter resonance: Resonance (dB) ranges from -20 to 40 (Default: 0)
    ///
    public init(
        _ input: AKNode,
        cutoffFrequency: Double = 6900,
        resonance: Double = 0) {

            self.cutoffFrequency = cutoffFrequency
            self.resonance = resonance

            inputGain = AKMixer(input)
            inputGain!.volume = 0
            mixer = AKMixer(inputGain!)

            effectGain = AKMixer(input)
            effectGain!.volume = 1

            internalEffect = AVAudioUnitEffect(audioComponentDescription: cd)
            super.init()
            
            AKManager.sharedInstance.engine.attachNode(internalEffect)
            internalAU = internalEffect.audioUnit
            AKManager.sharedInstance.engine.connect((effectGain?.avAudioNode)!, to: internalEffect, format: AKManager.format)
            AKManager.sharedInstance.engine.connect(internalEffect, to: mixer.avAudioNode, format: AKManager.format)
            avAudioNode = mixer.avAudioNode

            AudioUnitSetParameter(internalAU, kLowPassParam_CutoffFrequency, kAudioUnitScope_Global, 0, Float(cutoffFrequency), 0)
            AudioUnitSetParameter(internalAU, kLowPassParam_Resonance, kAudioUnitScope_Global, 0, Float(resonance), 0)
    }

    /// Function to start, play, or activate the node, all do the same thing
    public func start() {
        if isStopped {
            dryWetMix = lastKnownMix
            isStarted = true
        }
    }

    /// Function to stop or bypass the node, both are equivalent
    public func stop() {
        if isPlaying {
            lastKnownMix = dryWetMix
            dryWetMix = 0
            isStarted = false
        }
    }
}
