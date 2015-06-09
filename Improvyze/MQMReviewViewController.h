//
//  MQMReviewViewController.h
//  Impromptu Prep
//
//  Created by Myhkail Mendoza on 3/11/15.
//  Copyright (c) 2015 Myhkail Mendoza. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "MZTimerLabel.h"
#import <MessageUI/MessageUI.h>



@class MQMQuotesStore;

@interface MQMReviewViewController : UIViewController <MZTimerLabelDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic) MZTimerLabel *mainTimer;
@property (nonatomic, copy) NSDictionary *currentDictionary;

@property (weak, nonatomic) IBOutlet UILabel *quotation;
@property (weak, nonatomic) IBOutlet UILabel *author;
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;

@end
