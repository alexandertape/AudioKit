//
//  CSDSum.h
//  ExampleProject
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CSDOpcode.h"

@interface CSDSum : CSDOpcode {
    NSMutableArray * inputs;
    CSDParam * output;
}

@property (nonatomic, strong) CSDParam * output;

-(id) initWithInputs:(CSDParam *)firstInput,...;

@end
