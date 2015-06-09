//
//  MQMChooseCompViewController.h
//  Impromptu Prep
//
//  Created by Myhkail Mendoza on 3/18/15.
//  Copyright (c) 2015 Myhkail Mendoza. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "MZTimerLabel.h"
#import "MQMRecordingsStore.h"

@class MQMPlayViewController;
@class MQMButton;

// UIGestureRecognizerDelegate is to disable the back swipe.
@interface MQMChooseCompViewController : UIViewController <MZTimerLabelDelegate,AVAudioRecorderDelegate, UIAlertViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic) MZTimerLabel *mainTimer;
@property (nonatomic) int delayChoice; // How many seconds did they choose?
@property (nonatomic, copy) NSString *filename;
@property (strong, nonatomic) MQMPlayViewController *pvc;

@property (weak, nonatomic) IBOutlet MQMButton *firstButton;
@property (weak, nonatomic) IBOutlet MQMButton *secondButton;
@property (weak, nonatomic) IBOutlet MQMButton *thirdButton;
@property (weak, nonatomic) IBOutlet UILabel *timeSignal;

@end
