//
//  AKPanner.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// Stereo Panner
///
/// - parameter input: Input node to process
/// - parameter pan: Panning. A value of -1 is hard left, and a value of 1 is hard right, and 0 is center.
///
public class AKPanner: AKNode {

    // MARK: - Properties


    internal var internalAU: AKPannerAudioUnit?
    internal var token: AUParameterObserverToken?

    private var panParameter: AUParameter?

    /// Panning. A value of -1 is hard left, and a value of 1 is hard right, and 0 is center.
    public var pan: Double = 0 {
        willSet(newValue) {
            if pan != newValue {
                panParameter?.setValue(Float(newValue), originator: token!)
            }
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    public var isStarted: Bool {
        return internalAU!.isPlaying()
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    public var isPlaying: Bool {
        return internalAU!.isPlaying()
    }

    /// Tells whether the node is not processing (ie. stopped or bypassed)
    public var isStopped: Bool {
        return !internalAU!.isPlaying()
    }

    /// Tells whether the node is not processing (ie. stopped or bypassed)
    public var isBypassed: Bool {
        return !internalAU!.isPlaying()
    }

    // MARK: - Initialization

    /// Initialize this panner node
    ///
    /// - parameter input: Input node to process
    /// - parameter pan: Panning. A value of -1 is hard left, and a value of 1 is hard right, and 0 is center.
    ///
    public init(
        _ input: AKNode,
        pan: Double = 0) {

        self.pan = pan

        var description = AudioComponentDescription()
        description.componentType         = kAudioUnitType_Effect
        description.componentSubType      = 0x70616e32 /*'pan2'*/
        description.componentManufacturer = 0x41754b74 /*'AuKt'*/
        description.componentFlags        = 0
        description.componentFlagsMask    = 0

        AUAudioUnit.registerSubclass(
            AKPannerAudioUnit.self,
            asComponentDescription: description,
            name: "Local AKPanner",
            version: UInt32.max)

        super.init()
        AVAudioUnit.instantiateWithComponentDescription(description, options: []) {
            avAudioUnit, error in

            guard let avAudioUnitEffect = avAudioUnit else { return }

            self.avAudioNode = avAudioUnitEffect
            self.internalAU = avAudioUnitEffect.AUAudioUnit as? AKPannerAudioUnit

            AKManager.sharedInstance.engine.attachNode(self.avAudioNode)
            input.addConnectionPoint(self)
        }

        guard let tree = internalAU?.parameterTree else { return }

        panParameter   = tree.valueForKey("pan")   as? AUParameter

        token = tree.tokenByAddingParameterObserver {
            address, value in

            dispatch_async(dispatch_get_main_queue()) {
                if address == self.panParameter!.address {
                    self.pan = Double(value)
                }
            }
        }
        panParameter?.setValue(Float(pan), originator: token!)
    }

    /// Function to start, play, or activate the node, all do the same thing
    public func start() {
        self.internalAU!.start()
    }

    /// Function to stop or bypass the node, both are equivalent
    public func stop() {
        self.internalAU!.stop()
    }

    /// Function to start, play, or activate the node, all do the same thing
    public func play() {
        self.internalAU!.start()
    }

    /// Function to stop or bypass the node, both are equivalent
    public func bypass() {
        self.internalAU!.stop()
    }
}
