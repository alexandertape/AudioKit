//
//  AKDelay.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

/// AudioKit version of Apple's Delay Audio Unit
///
/// - parameter input: Input audio AKNode to process
/// - parameter time: Delay time in seconds (Default: 1)
/// - parameter feedback: Amount of feedback (Normalized Value) ranges from 0 to 1 (Default: 0.5)
/// - parameter lowPassCutoff: Low-pass cutoff frequency in Hz (Default 15000)
/// - parameter dryWetMix: Amount of unprocessed (dry) to delayed (wet) audio (Normalized Value) ranges from 0 to 1 (Default: 0.5)
///
public class AKDelay: AKNode, AKToggleable {
    let delayAU = AVAudioUnitDelay()

    private var lastKnownMix: Double = 0.5
    
    /// Delay time in seconds (Default: 1)
    public var time: NSTimeInterval = 1 {
        didSet {
            if time < 0 {
                time = 0
            }
            delayAU.delayTime = time
        }
    }
    
    /// Feedback (Normalized Value) ranges from 0 to 1 (Default: 0.5)
    public var feedback: Double = 0.5 {
        didSet {
            if feedback < 0 {
                feedback = 0
            }
            if feedback > 1 {
                feedback = 1
            }
            delayAU.feedback = Float(feedback) * 100.0
        }
    }
    
    /// Low pass cut-off frequency in Hertz (Default: 15000)
    public var lowPassCutoff: Double = 15000.00 {
        didSet {
            if lowPassCutoff < 0 {
                lowPassCutoff = 0
            }
            delayAU.lowPassCutoff = Float(lowPassCutoff)
        }
    }
    
    /// Dry/Wet Mix (Normalized Value) ranges from 0 to 1 (Default: 0.5)
    public var dryWetMix: Double = 0.5 {
        didSet {
            setDryWetMix(dryWetMix)
        }
    }
    
    internal func setDryWetMix(var value: Double) {
        if value < 0 {
            value = 0
        }
        if value > 1 {
            value = 1
        }
        delayAU.wetDryMix = Float(value) * 100.0
    }
    
    /// Tells whether the node is processing (ie. started, playing, or active)
    public var isStarted = true
    
    /// Initialize the delay node
    ///
    /// - parameter input: Input audio AKNode to process
    /// - parameter time: Delay time in seconds (Default: 1)
    /// - parameter feedback: Amount of feedback (Normalized Value) ranges from 0 to 1 (Default: 0.5)
    /// - parameter lowPassCutoff: Low-pass cutoff frequency in Hz (Default 15000)
    /// - parameter dryWetMix: Amount of unprocessed (dry) to delayed (wet) audio (Normalized Value) ranges from 0 to 1 (Default: 0.5)
    ///
    public init(
        _ input: AKNode,
        time: Double = 1,
        feedback: Double = 0.5,
        lowPassCutoff: Double = 15000,
        dryWetMix: Double = 0.5) {
            
            self.time = NSTimeInterval(Double(time))
            self.feedback = feedback
            self.lowPassCutoff = lowPassCutoff
            self.dryWetMix = dryWetMix
            
            super.init()
            self.avAudioNode = delayAU
            AKManager.sharedInstance.engine.attachNode(self.avAudioNode)
            input.addConnectionPoint(self)
            
            
            delayAU.delayTime = self.time
            delayAU.feedback = Float(feedback) * 100.0
            delayAU.lowPassCutoff = Float(lowPassCutoff)
            setDryWetMix(dryWetMix)
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
