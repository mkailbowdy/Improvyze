//
//  MQMReviewViewController.m
//  Impromptu Prep
//
//  Created by Myhkail Mendoza on 3/11/15.
//  Copyright (c) 2015 Myhkail Mendoza. All rights reserved.
//

#import "MQMQuotesStore.h"
#import "MQMRecordingsStore.h"
#import "MQMReviewViewController.h"
#import "MZTimerLabel.h"
#import <iAd/iAd.h>
#import "MQMIAPHelper.h"
#import "MQMInformationViewController.h"


@interface MQMReviewViewController ()
{
    AVAudioPlayer *player;
    BOOL playerFinished;
}

@property (weak, nonatomic) IBOutlet UILabel *formatLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *formatControl;
@property (weak, nonatomic) IBOutlet UIButton *playPauseRestart;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UIButton *emailButton;
@property (nonatomic, strong) NSTimer *updateTimer;
@property (nonatomic) MQMRecordingsStore *recordingStore;
@property (nonatomic, copy) NSArray *quotesArray;
@property (nonatomic, copy) NSString *filename;

// Constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *formatBottomSpace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timerBottomSpace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timerTopSpace;


@end

@implementation MQMReviewViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        [self.playPauseRestart setImage:[UIImage imageNamed:@"PlayFilled@2x.png"] forState:UIControlStateNormal];

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.formatLabel.text = @"";
    /*== Timer Configuration ==*/
    self.mainTimer = [[MZTimerLabel alloc] initWithLabel:self.timerLabel andTimerType:MZTimerLabelTypeStopWatch];
    self.mainTimer.timeFormat = @"HH:mm:ss:SS";
    [self.mainTimer setDelegate:self];
    /*== Timer Config. End ==*/

    self.filename = [self.currentDictionary objectForKey:@"filename"];
    self.quotation.text = [self.currentDictionary objectForKey:@"quote"];
    self.author.text = [self.currentDictionary objectForKey:@"quoteAuthor"];
    
    [self setupPlayer];
    [self adjustConstraints];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
    
    [self setupPlayer];
    [self.playPauseRestart setImage:[UIImage imageNamed:@"PlayFilled@2x.png"] forState:UIControlStateNormal];
    
    if ([[MQMIAPHelper sharedInstance] productPurchased:@"com.myhkailmendoza.Improvyze.nonconsumable1"]) {
        self.canDisplayBannerAds = NO;
        //NSLog(@"Product purchased, wont show ads");
    } else {
        self.canDisplayBannerAds = YES;
       // NSLog(@"Product NOT purchased, will show ads");
    }
    

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (player.playing) {
        [player stop];
        [self.mainTimer pause];
        [self.mainTimer reset];
    }
}


- (IBAction)playPauseReplay:(id)sender {
    if (playerFinished) {
        [self.mainTimer reset];
        [self.playPauseRestart setImage:[UIImage imageNamed:@"PlayFilled@2x.png"] forState:UIControlStateNormal];
    }
    if ([self.mainTimer counting]) {
        [self.mainTimer pause];
        [player pause];
        [self.playPauseRestart setImage:[UIImage imageNamed:@"PlayFilled@2x.png"] forState:UIControlStateNormal];
    } else {
        playerFinished = NO;
        [self.mainTimer start];
        [player play];
        // schedule the timer to start up the scrub bar
        self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateSlider) userInfo:nil repeats:YES];
        [self.playPauseRestart setImage:[UIImage imageNamed:@"PauseFilled@2x.png"] forState:UIControlStateNormal];
    }
}
- (IBAction)scrubAudio:(id)sender {
    [self.mainTimer pause];// so does the timer
    
    [player pause]; // player always pauses while scrub in use
    
    player.currentTime = self.slider.value; // Set players currentTime to the slider's value
    [self.mainTimer setStopWatchTime:player.currentTime]; // This matches up the timers time with the audio
    [self.slider addTarget:self
                    action:@selector(scrubEnded)
          forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
}

- (void)scrubEnded {
    [player play];
    [self.mainTimer start];
    
    UIImage *img= [UIImage imageNamed:@"PlayFilled@2x.png"];
    if ([self.playPauseRestart.imageView.image isEqual:img]) {
        [self.playPauseRestart setImage:[UIImage imageNamed:@"PauseFilled@2x.png"] forState:UIControlStateNormal];
    } else {
        [self.playPauseRestart setImage:[UIImage imageNamed:@"PauseFilled@2x.png"] forState:UIControlStateNormal];
    }
    
}

- (void)updateSlider {
    // This is to update the ball on the slider
    float progress = player.currentTime;
    [self.slider setValue:progress];
}

- (IBAction)sendEmail:(id)sender {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
        mail.mailComposeDelegate = self;
        
        [mail setSubject:@"A practice impromptu recording"];
        
        NSString *body = @"Here is a recording of me doing an impromptu speech of the following quotation: ";
        NSString *quote = self.quotation.text;
        NSString *emailBody = [body stringByAppendingString:quote];
        [mail setMessageBody:emailBody isHTML:YES];
        
        NSArray *pathComponents = [NSArray arrayWithObjects:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject], self.filename, nil];
        NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents]; // Get the audio from the docs
        
        NSError *error = nil;
        NSData *audioData = [NSData dataWithContentsOfURL:outputFileURL options:0 error:&error];
        [mail addAttachmentData:audioData mimeType:@"audio/mp4" fileName:self.filename];
        
        [self presentViewController:mail animated:YES completion:NULL];
    } else {
        //NSLog(@"This device cannot send mail");
    }

}

- (void)adjustConstraints {
    // Here we handle different screen sizes
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        if ([[UIScreen mainScreen] scale] == 2.0) {
            
            if([UIScreen mainScreen].bounds.size.height == 667){
                // iPhone retina-4.7 inch(iPhone 6)
                self.quotation.font = [self.quotation.font fontWithSize:25];
                self.author.font = [self.author.font fontWithSize:20];
            }
            else if([UIScreen mainScreen].bounds.size.height == 568){
                // iPhone retina-4 inch(iPhone 5 or 5s)
            }
            else {
                // iPhone retina-3.5 inch(iPhone 4s)
                self.formatBottomSpace.constant = 5;
                self.timerBottomSpace.constant = 35;
                self.timerTopSpace.constant = 0;
            }
        }
        else if ([[UIScreen mainScreen] scale] == 3.0)
        {
            //if you want to detect the iPhone 6+ only
            if([UIScreen mainScreen].bounds.size.height == 736.0){
                //iPhone retina-5.5 inch screen(iPhone 6 plus)
                self.quotation.font = [self.quotation.font fontWithSize:30];
                self.author.font = [self.author.font fontWithSize:25];
            }
            //iPhone retina-5.5 inch screen(iPhone 6 plus)
        }
    }
}

- (void)setupPlayer {
    
    // Setup audio session
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    NSArray *pathComponents = [NSArray arrayWithObjects:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject], self.filename, nil];
    NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents]; // Get the audio from the docs
    
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:outputFileURL error:nil];
    [player setDelegate:self]; // set self as delegate
    
    // Setup the slider
    self.slider.minimumValue = 0;
    self.slider.maximumValue = player.duration;
    self.slider.continuous = YES;
}


- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [self.mainTimer pause];
    playerFinished = YES;
    //[self.playPauseRestart setTitle:@"Replay" forState:UIControlStateNormal];
    [self.playPauseRestart setImage:[UIImage imageNamed:@"PlayFilled@2x.png"] forState:UIControlStateNormal];
}
- (IBAction)information:(id)sender {
    MQMInformationViewController *ivc = [[MQMInformationViewController alloc] init];
    [self.navigationController pushViewController:ivc animated:YES];
}

#pragma mark - Email Delegate
/* == EMAIL DELEGATE == */
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    switch (result) {
        case MFMailComposeResultSent:
            //NSLog(@"You sent the mail.");
            break;
        case MFMailComposeResultSaved:
            //NSLog(@"You saved a draft.");
            break;
        case MFMailComposeResultCancelled:
            //NSLog(@"Mail failed: An error occured");
            break;
        case MFMailComposeResultFailed:
            //NSLog(@"An error occured when trying to compose mail");
            break;
        default:
            //NSLog(@"Error occured when composing mail");
            break;
    }
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - MZTimerLabel Delegate

- (void)timerLabel:(MZTimerLabel *)timerlabel countingTo:(NSTimeInterval)time timertype:(MZTimerLabelType)timerType {
    if (self.formatControl.selectedSegmentIndex == 1) {
        /* == THREE POINT FORMAT == */
        if([timerlabel isEqual:self.mainTimer] && time < 60){
            timerlabel.timeLabel.textColor = [UIColor greenColor];
            self.formatLabel.text = @"Introduction";
        }
        if([timerlabel isEqual:self.mainTimer] && time >= 60){
            timerlabel.timeLabel.textColor = [UIColor blueColor];
            self.formatLabel.text = @"Main Point 1";
        }
        
        if([timerlabel isEqual:self.mainTimer] && time >= 120){
            timerlabel.timeLabel.textColor = [UIColor purpleColor];
            self.formatLabel.text = @"Main Point 2";
        }
        
        if([timerlabel isEqual:self.mainTimer] && time >= 180){
            timerlabel.timeLabel.textColor = [UIColor grayColor];
            self.formatLabel.text = @"Main Point 3";
        }
        
        if([timerlabel isEqual:self.mainTimer] && time >= 240){
            timerlabel.timeLabel.textColor = [UIColor brownColor];
            self.formatLabel.text = @"Conclusion";
        }
        if([timerlabel isEqual:self.mainTimer] && time >= 300){
            timerlabel.timeLabel.textColor = [UIColor redColor];
            self.formatLabel.text = @"Speech Limit!";
        }
    }
    if (self.formatControl.selectedSegmentIndex == 0) {
        // TWO POINT FORMAT
        if([timerlabel isEqual:self.mainTimer] && time < 60){
            timerlabel.timeLabel.textColor = [UIColor greenColor];
            self.formatLabel.text = @"Introduction";
        }
        if([timerlabel isEqual:self.mainTimer] && time >= 60){
            timerlabel.timeLabel.textColor = [UIColor blueColor];
            self.formatLabel.text = @"Main Point 1";
        }
        
        if([timerlabel isEqual:self.mainTimer] && time >= 90){
            timerlabel.timeLabel.textColor = [UIColor blueColor];
            self.formatLabel.text = @"MP1: Example 1";
        }
        
        if([timerlabel isEqual:self.mainTimer] && time >= 120){
            timerlabel.timeLabel.textColor = [UIColor purpleColor];
            self.formatLabel.text = @"MP1: Example 2";
        }
        if([timerlabel isEqual:self.mainTimer] && time >= 150){
            timerlabel.timeLabel.textColor = [UIColor purpleColor];
            self.formatLabel.text = @"Main Point 2";
        }
        if([timerlabel isEqual:self.mainTimer] && time >= 180){
            timerlabel.timeLabel.textColor = [UIColor grayColor];
            self.formatLabel.text = @"MP2: Example 1";
        }
        if([timerlabel isEqual:self.mainTimer] && time >= 210){
            timerlabel.timeLabel.textColor = [UIColor grayColor];
            self.formatLabel.text = @"MP2: Example 2";
        }
        if([timerlabel isEqual:self.mainTimer] && time >= 240){
            timerlabel.timeLabel.textColor = [UIColor brownColor];
            self.formatLabel.text = @"Conclusion";
        }
        if([timerlabel isEqual:self.mainTimer] && time >= 300){
            timerlabel.timeLabel.textColor = [UIColor redColor];
            self.formatLabel.text = @"Speech Limit!";
        }
    }
}


@end




