//
//  MQMPlayViewController.m
//  Impromptu Prep
//
//  Created by Myhkail Mendoza on 2/23/15.
//  Copyright (c) 2015 Myhkail Mendoza. All rights reserved.
//

#import "MQMPlayViewController.h"
#import "MQMRecordingsStore.h"
#import "MQMQuotesStore.h"
#import <iAd/iAd.h>
#import "MQMIAPHelper.h"
#import "MQMInformationViewController.h"

@interface MQMPlayViewController ()
{
    AVAudioRecorder *recorder;
    AVAudioPlayer *player;
}

@property (weak, nonatomic) IBOutlet UISegmentedControl *formatControl;
// Constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *formatBottomSpace;

@end

@implementation MQMPlayViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.recordingStore = [[MQMRecordingsStore alloc] init];
        // Set the tab bar item's title
        self.tabBarItem.title = @"Play";
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self
               selector:@selector(pauseRecorderAndTimer)
                   name:AVAudioSessionInterruptionNotification
                 object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.formatLabel.text = @"";
    /*== Timer Configuration ==*/
    self.mainTimer = [[MZTimerLabel alloc] initWithLabel:self.timerLabel andTimerType:MZTimerLabelTypeStopWatch];
    
    self.mainTimer.delegate = self;
    self.mainTimer.timeFormat = @"HH:mm:ss:SS";
    /*== Timer Config. End ==*/
    
    /*== Recorder/Player Config. ERROR HANDLING NOT YET IMPLEMENTED==*/
    [self.doneButton setEnabled:NO];
    //[self.playButton setEnabled:NO];
    [self setupRecorder];
    
    /*=== Set the quote and author text ===*/
    self.quotation.text = self.quote;
    self.authorLabel.text = self.author;
    /*=== Set the format of the quote and author ===*/
    self.quotation.adjustsFontSizeToFitWidth = YES;
    self.quotation.lineBreakMode = NSLineBreakByWordWrapping; // wrap to two lines
    self.quotation.numberOfLines = 0;
    
    /*=== Set the font size of the quote and author ===*/
    [self adjustConstraints];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([[MQMIAPHelper sharedInstance] productPurchased:@"com.myhkailmendoza.Improvyze.nonconsumable1"]) {
        self.canDisplayBannerAds = NO;
        //NSLog(@"Product purchased, wont show ads");
    } else {
        self.canDisplayBannerAds = YES;
        //NSLog(@"Product NOT purchased, will show ads");
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self pauseRecorderAndTimer];
}

- (void)setupRecorder {
    // Generate a string for the audio file
    NSTimeInterval today = [[NSDate date] timeIntervalSince1970];
    NSString *intervalString = [NSString stringWithFormat:@"%f", today];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[intervalString doubleValue]];
    
    NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd-hhmm"];

    NSString *strdate =[formatter stringFromDate:date];
    self.filename = [strdate stringByAppendingString:@".m4a"];
    // Set the audio file
    NSArray *pathComponents = [NSArray arrayWithObjects:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject], self.filename, nil];
    NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    // Setup audio session
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    // Define the recorder setting
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
    
    // Initiate and prepare the recorder
    recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSetting error:NULL];
    recorder.delegate = self;
    recorder.meteringEnabled = YES;
    [recorder prepareToRecord];
    /*== Recorder/Player Config. End ==*/
}

- (IBAction)startOrResumeStopwatch:(id)sender {
    if (player.playing) {
        [player stop];
    }
    if([self.mainTimer counting]){
        [self.mainTimer pause];
        [recorder pause];
        [self.timerButton setTitle:@"Resume" forState:UIControlStateNormal];

        [self.resetButton setEnabled:YES];
        [self.doneButton setEnabled:YES];
        
    } else {
        if (player.playing) {
            [player stop];
        }
        [self.mainTimer start];
        
        [recorder record];
        [self.timerButton setTitle:@"Pause" forState:UIControlStateNormal];

        [self.resetButton setEnabled:NO];
        
    }
    
    [self.doneButton setEnabled:YES];
}

- (void)pauseRecorderAndTimer {
    // Use this to pause timer and recorder when interrupted
    if (player.playing) {
        [player stop];
    }
    if([self.mainTimer counting]){// If you change views while recording.
        [self.mainTimer pause];
        [recorder pause];
        [self.timerButton setTitle:@"Resume" forState:UIControlStateNormal];
        [self.resetButton setEnabled:YES];
        [self.doneButton setEnabled:YES];
    }
}

- (IBAction)resetStopwatch:(id)sender {
    // If tapped, ask user if they are sure they want to redo the recording
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                    message:@"Redo this recording from the beginning?"
                                                   delegate:self
                                          cancelButtonTitle:@"No"
                                          otherButtonTitles:@"Yes", nil];
    [alert show];
    
    [self.mainTimer pause];
    if (player.playing) {
        [player stop];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // This gets called when the alert view shows up
    switch(buttonIndex) {
        case 0: //"No" pressed
            //do something?
            break;
        case 1: //"Yes" pressed
            //here you pop the viewController
            [self.mainTimer reset];
            [self.timerButton setTitle:@"Record" forState:UIControlStateNormal];
            [self.timerButton setEnabled:YES];
            [self.doneButton setEnabled:NO];
            
            [self setupRecorder]; // resets the recorder settings
            break;
    }
}
- (IBAction)informationTapped:(id)sender {
    MQMInformationViewController *ivc = [[MQMInformationViewController alloc] init];
    [self.navigationController pushViewController:ivc animated:YES];
}

#pragma mark - Recording

- (IBAction)doneTapped:(id)sender {
    // STILL NEED TO ADD THIS FUNCTIONALITY: AFTER PRESSING THE DONE/SAVE BUTTON,
    // CONFIRM IF THE USER IS FINISHED, THEN SAVE THE RECORDING TO THE PHONE
    [self.mainTimer pause];
    [recorder stop];
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
    [self.timerButton setEnabled:NO];
    [self.resetButton setEnabled:YES];
    
    // Now add the quote, author, and URL to the self.privateRecordings in MQMRecordingsStore
    NSDictionary *plistDict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:self.quote, self.author, self.filename, nil]
                                                          forKeys:[NSArray arrayWithObjects:@"quote", @"quoteAuthor", @"filename", nil]];
    
    [self.recordingStore.allRecordings addObject:plistDict]; // Add to recordingStores allRecording array
    
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *newPath = [rootPath stringByAppendingPathComponent:@"recordings.plist"];
    NSMutableArray *recordingsInStore = [NSMutableArray arrayWithContentsOfFile:newPath];
    
    [recordingsInStore addObject:plistDict];
    [recordingsInStore writeToFile:newPath atomically:YES];
    
    //NSLog(@"number of recordings in store: %lu", (long unsigned)[self.recordingStore.allRecordings count]);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Recording Finished!"
                                                    message:@"The recording has been saved!"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    [self.doneButton setEnabled:NO];
}

- (void)adjustConstraints {
    // Here we handle different screen sizes
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        if ([[UIScreen mainScreen] scale] == 2.0) {
            
            if([UIScreen mainScreen].bounds.size.height == 667){
                // iPhone retina-4.7 inch(iPhone 6)
                self.quotation.font = [self.quotation.font fontWithSize:25];
                self.authorLabel.font = [self.authorLabel.font fontWithSize:22];
                self.formatLabel.font = [self.formatLabel.font fontWithSize:45];
                self.timerLabel.font = [self.timerLabel.font fontWithSize:50];
            }
            else if([UIScreen mainScreen].bounds.size.height == 568){
                // iPhone retina-4 inch(iPhone 5 or 5s)
            }
            else {
            }
        }
        else if ([[UIScreen mainScreen] scale] == 3.0)
        {
            //if you want to detect the iPhone 6+ only
            if([UIScreen mainScreen].bounds.size.height == 736.0){
                //iPhone retina-5.5 inch screen(iPhone 6 plus)
                self.quotation.font = [self.quotation.font fontWithSize:30];
                self.authorLabel.font = [self.authorLabel.font fontWithSize:25];
                self.formatLabel.font = [self.formatLabel.font fontWithSize:45];
                self.timerLabel.font = [self.timerLabel.font fontWithSize:50];
            }
            //iPhone retina-5.5 inch screen(iPhone 6 plus)
        }
    }
}

/*****THIS IS MZTimerLabel DELEGATE Method*****/
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
