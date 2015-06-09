//
//  MQMPlayViewController.h
//  Impromptu Prep
//
//  Created by Myhkail Mendoza on 2/23/15.
//  Copyright (c) 2015 Myhkail Mendoza. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "MZTimerLabel.h"
@class MQMRecordingsStore;

@interface MQMPlayViewController : UIViewController <MZTimerLabelDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate,UIAlertViewDelegate>

@property (nonatomic) MZTimerLabel *mainTimer;
@property (nonatomic, weak) NSArray *recordingsArray; // I set it to weak to see if leak stops
@property (weak, nonatomic) NSString *quote;
@property (weak, nonatomic) NSString *author;
@property (nonatomic, copy) NSString *filename;
@property (nonatomic) MQMRecordingsStore *recordingStore;
@property (nonatomic, copy) NSArray *quotesArray;

@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UILabel *quotation;
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (weak, nonatomic) IBOutlet UILabel *formatLabel;
@property (weak, nonatomic) IBOutlet UIButton *timerButton;
@property (weak, nonatomic) IBOutlet UIButton *resetButton;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;

- (IBAction)resetStopwatch:(id)sender;
- (IBAction)startOrResumeStopwatch:(id)sender;
- (void)pauseRecorderAndTimer;

@end
