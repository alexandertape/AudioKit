//
//  sawtoothWave.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

extension AKOperation {

    /// Bandlimited sawtooth oscillator This is a bandlimited sawtooth oscillator
    /// ported from the "sawtooth" function from the Faust programming language.
    ///
    /// - returns: AKOperation
    /// - parameter frequency: In cycles per second, or Hz. (Default: 440, Minimum: 0.0, Maximum: 20000.0)
    /// - parameter amplitude: Output Amplitude. (Default: 0.5, Minimum: 0.0, Maximum: 1.0)
     ///
    public static func sawtoothWave(
        frequency frequency: AKParameter = 440,
        amplitude: AKParameter = 0.5
        ) -> AKOperation {
            return AKOperation("(\(frequency) \(amplitude) blsaw)")
    }
}
