//
//  AKLowShelfParametricEqualizerFilterDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#ifndef AKLowShelfParametricEqualizerFilterDSPKernel_hpp
#define AKLowShelfParametricEqualizerFilterDSPKernel_hpp

#import "AKDSPKernel.hpp"
#import "AKParameterRamper.hpp"

extern "C" {
#include "soundpipe.h"
}

enum {
    cornerFrequencyAddress = 0,
    gainAddress = 1,
    qAddress = 2
};

class AKLowShelfParametricEqualizerFilterDSPKernel : public AKDSPKernel {
public:
    // MARK: Member Functions

    AKLowShelfParametricEqualizerFilterDSPKernel() {}

    void init(int channelCount, double inSampleRate) {
        channels = channelCount;

        sampleRate = float(inSampleRate);

        sp_create(&sp);
        sp_pareq_create(&pareq);
        sp_pareq_init(sp, pareq);
        pareq->fc = 1000;
        pareq->v = 1.0;
        pareq->q = 0.707;
        pareq->mode = 1;
    }

    void start() {
        started = true;
    }

    void stop() {
        started = false;
    }

    void destroy() {
        sp_pareq_destroy(&pareq);
        sp_destroy(&sp);
    }

    void reset() {
    }

    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case cornerFrequencyAddress:
                cornerFrequencyRamper.set(clamp(value, (float)12.0, (float)20000.0));
                break;

            case gainAddress:
                gainRamper.set(clamp(value, (float)0.0, (float)10.0));
                break;

            case qAddress:
                qRamper.set(clamp(value, (float)0.0, (float)2.0));
                break;

        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case cornerFrequencyAddress:
                return cornerFrequencyRamper.goal();

            case gainAddress:
                return gainRamper.goal();

            case qAddress:
                return qRamper.goal();

            default: return 0.0f;
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            case cornerFrequencyAddress:
                cornerFrequencyRamper.startRamp(clamp(value, (float)12.0, (float)20000.0), duration);
                break;

            case gainAddress:
                gainRamper.startRamp(clamp(value, (float)0.0, (float)10.0), duration);
                break;

            case qAddress:
                qRamper.startRamp(clamp(value, (float)0.0, (float)2.0), duration);
                break;

        }
    }

    void setBuffers(AudioBufferList *inBufferList, AudioBufferList *outBufferList) {
        inBufferListPtr = inBufferList;
        outBufferListPtr = outBufferList;
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        // For each sample.
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            double cornerFrequency = double(cornerFrequencyRamper.getStep());
            double gain = double(gainRamper.getStep());
            double q = double(qRamper.getStep());

            int frameOffset = int(frameIndex + bufferOffset);

            pareq->fc = (float)cornerFrequency;
            pareq->v = (float)gain;
            pareq->q = (float)q;

            if (!started) {
                outBufferListPtr->mBuffers[0] = inBufferListPtr->mBuffers[0];
                outBufferListPtr->mBuffers[1] = inBufferListPtr->mBuffers[1];
                return;
            }
            for (int channel = 0; channel < channels; ++channel) {
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;

                sp_pareq_compute(sp, pareq, in, out);
            }
        }
    }

    // MARK: Member Variables

private:

    int channels = 2;
    float sampleRate = 44100.0;

    AudioBufferList *inBufferListPtr = nullptr;
    AudioBufferList *outBufferListPtr = nullptr;

    sp_data *sp;
    sp_pareq *pareq;

public:
    bool started = true;
    AKParameterRamper cornerFrequencyRamper = 1000;
    AKParameterRamper gainRamper = 1.0;
    AKParameterRamper qRamper = 0.707;
};

#endif /* AKLowShelfParametricEqualizerFilterDSPKernel_hpp */
