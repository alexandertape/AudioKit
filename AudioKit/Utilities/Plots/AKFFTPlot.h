//
//  AKFFTPlot.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 2/8/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "CsoundObj.h"
#import <Accelerate/Accelerate.h>


#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
@interface AKFFTPlot : UIView <CsoundBinding>
#elif TARGET_OS_MAC
#import <Cocoa/Cocoa.h>
@interface AKFFTPlot : NSView 
#endif

@end