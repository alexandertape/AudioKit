//
//  ViewController.swift
//  HelloWorld
//
//  Created by Aurelius Prochazka on 12/5/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import UIKit
import AudioKit

class ViewController: UIViewController {

    let audiokit = AKManager.sharedInstance
    var oscillator = AKOscillator()

    @IBOutlet var plot: AKOutputWaveformPlot!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        audiokit.audioOutput = oscillator
        audiokit.start()
        
    }

    @IBAction func toggleSound(sender: UIButton) {
        if oscillator.isPlaying {
            oscillator.stop()
            sender.setTitle("Play Sine Wave", forState: .Normal)
        } else {
            oscillator.amplitude = random(0.5, 1)
            oscillator.frequency = random(220, 880)
            oscillator.start()
            sender.setTitle("Stop Sine Wave at \(Int(oscillator.frequency))Hz", forState: .Normal)
        }
        sender.setNeedsDisplay()
    }

}

