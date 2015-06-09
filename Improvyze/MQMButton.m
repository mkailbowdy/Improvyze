//
//  MQMButton.m
//  Impromptu Prep
//
//  Created by Myhkail Mendoza on 3/15/15.
//  Copyright (c) 2015 Myhkail Mendoza. All rights reserved.
//

#import "MQMButton.h"
#import <QuartzCore/QuartzCore.h>

@implementation MQMButton

- (void) setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    // When the button is held own, the button color gets lighter;
    if (highlighted) {
        self.alpha = 0.5;
    }
    else {
        self.alpha = 1.0;
    }
}

- (void) makeRounded {
    CALayer *btnLayer = [self layer];
    [btnLayer setMasksToBounds:YES];
    [btnLayer setCornerRadius:16.0f];
}

- (void)makeShadow {
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    self.layer.masksToBounds = NO;
    self.layer.shadowRadius = 2.5f;
    self.layer.shadowOpacity = 1.0;
}

@end
