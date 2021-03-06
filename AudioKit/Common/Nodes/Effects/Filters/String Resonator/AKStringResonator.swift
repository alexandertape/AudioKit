//
//  AKStringResonator.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// AKStringResonator passes the input through a network composed of comb,
/// low-pass and all-pass filters, similar to the one used in some versions of
/// the Karplus-Strong algorithm, creating a string resonator effect. The
/// fundamental frequency of the “string” is controlled by the
/// fundamentalFrequency.  This operation can be used to simulate sympathetic
/// resonances to an input signal.
///
/// - parameter input: Input node to process
/// - parameter fundamentalFrequency: Fundamental frequency of string.
/// - parameter feedback: Feedback amount (value between 0-1). A value close to 1 creates a slower decay and a more pronounced resonance. Small values may leave the input signal unaffected. Depending on the filter frequency, typical values are > .9.
///
public class AKStringResonator: AKNode, AKToggleable {

    // MARK: - Properties


    internal var internalAU: AKStringResonatorAudioUnit?
    internal var token: AUParameterObserverToken?

    private var fundamentalFrequencyParameter: AUParameter?
    private var feedbackParameter: AUParameter?

    /// Fundamental frequency of string.
    public var fundamentalFrequency: Double = 100 {
        willSet(newValue) {
            if fundamentalFrequency != newValue {
                fundamentalFrequencyParameter?.setValue(Float(newValue), originator: token!)
            }
        }
    }
    /// Feedback amount (value between 0-1). A value close to 1 creates a slower decay and a more pronounced resonance. Small values may leave the input signal unaffected. Depending on the filter frequency, typical values are > .9.
    public var feedback: Double = 0.95 {
        willSet(newValue) {
            if feedback != newValue {
                feedbackParameter?.setValue(Float(newValue), originator: token!)
            }
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    public var isStarted: Bool {
        return internalAU!.isPlaying()
    }

    // MARK: - Initialization

    /// Initialize this filter node
    ///
    /// - parameter input: Input node to process
    /// - parameter fundamentalFrequency: Fundamental frequency of string.
    /// - parameter feedback: Feedback amount (value between 0-1). A value close to 1 creates a slower decay and a more pronounced resonance. Small values may leave the input signal unaffected. Depending on the filter frequency, typical values are > .9.
    ///
    public init(
        _ input: AKNode,
        fundamentalFrequency: Double = 100,
        feedback: Double = 0.95) {

        self.fundamentalFrequency = fundamentalFrequency
        self.feedback = feedback

        var description = AudioComponentDescription()
        description.componentType         = kAudioUnitType_Effect
        description.componentSubType      = 0x73747265 /*'stre'*/
        description.componentManufacturer = 0x41754b74 /*'AuKt'*/
        description.componentFlags        = 0
        description.componentFlagsMask    = 0

        AUAudioUnit.registerSubclass(
            AKStringResonatorAudioUnit.self,
            asComponentDescription: description,
            name: "Local AKStringResonator",
            version: UInt32.max)

        super.init()
        AVAudioUnit.instantiateWithComponentDescription(description, options: []) {
            avAudioUnit, error in

            guard let avAudioUnitEffect = avAudioUnit else { return }

            self.avAudioNode = avAudioUnitEffect
            self.internalAU = avAudioUnitEffect.AUAudioUnit as? AKStringResonatorAudioUnit

            AKManager.sharedInstance.engine.attachNode(self.avAudioNode)
            input.addConnectionPoint(self)
        }

        guard let tree = internalAU?.parameterTree else { return }

        fundamentalFrequencyParameter = tree.valueForKey("fundamentalFrequency") as? AUParameter
        feedbackParameter             = tree.valueForKey("feedback")             as? AUParameter

        token = tree.tokenByAddingParameterObserver {
            address, value in

            dispatch_async(dispatch_get_main_queue()) {
                if address == self.fundamentalFrequencyParameter!.address {
                    self.fundamentalFrequency = Double(value)
                } else if address == self.feedbackParameter!.address {
                    self.feedback = Double(value)
                }
            }
        }
        fundamentalFrequencyParameter?.setValue(Float(fundamentalFrequency), originator: token!)
        feedbackParameter?.setValue(Float(feedback), originator: token!)
    }

    /// Function to start, play, or activate the node, all do the same thing
    public func start() {
        self.internalAU!.start()
    }

    /// Function to stop or bypass the node, both are equivalent
    public func stop() {
        self.internalAU!.stop()
    }
}
