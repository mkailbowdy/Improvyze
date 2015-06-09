//
//  MQMChooseViewController.m
//  Impromptu Prep
//
//  Created by Myhkail Mendoza on 3/8/15.
//  Copyright (c) 2015 Myhkail Mendoza. All rights reserved.
//

#import "MQMChooseCompViewController.h"
#import "MQMQuotesStore.h"
#import "MQMPlayViewController.h"
#import "MQMRecordingsViewController.h"
#import "MQMButton.h"
#import "MQMIAPHelper.h"

@interface MQMChooseCompViewController ()
{
    AVAudioRecorder *recorder;
    BOOL savedAlready;
    BOOL ranOnce;
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *quote2VertConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *quote3VertConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeLeftLabelVertConst;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UILabel *quote1;
@property (weak, nonatomic) IBOutlet UILabel *quote2;
@property (weak, nonatomic) IBOutlet UILabel *quote3;
@property (weak, nonatomic) IBOutlet UILabel *author1;
@property (weak, nonatomic) IBOutlet UILabel *author2;
@property (weak, nonatomic) IBOutlet UILabel *author3;

@property (nonatomic) MQMRecordingsStore *recordingStore; // We fill the array before adding new entries
@property (nonatomic, copy) NSString *currentQuote; // Gets assigned when button clicked
@property (nonatomic, copy) NSString *currentAuthor; // Gets assigned when button clicked

@property (nonatomic) NSMutableArray *threeDict; // The 3 final quotes
@property (nonatomic, copy) NSArray *quotesInPlist1;
@property (nonatomic, copy) NSArray *quotesInPlist2;
@property (nonatomic, copy) NSArray *quotesInPlist3;
@property (nonatomic, copy) NSArray *quotesSample;

// Constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *button1Height;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *button2Height;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *button3Height;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *quote2TopSpace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *quote3TopSpace;


@end

@implementation MQMChooseCompViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    savedAlready = NO;
    ranOnce = NO;
    self.timeSignal.text = @"";
    [self.saveButton setEnabled:NO]; // set to no until a quote is chosen
    
    [self.firstButton makeRounded];
    [self.secondButton makeRounded];
    [self.thirdButton makeRounded];
    
    // Do any additional setup after loading the view from its nib.
    self.quotesInPlist1 =  [[MQMQuotesStore sharedStore] quotesInPlist]; // Get the quotes from quotesStore
    self.quotesInPlist2 =  [[MQMQuotesStore sharedStore] quotesInPlist2]; // Get the quotes from quotesStore
    self.quotesInPlist3 =  [[MQMQuotesStore sharedStore] quotesInPlist3]; // Get the quotes from quotesStore
    self.quotesSample = [[MQMQuotesStore sharedStore] quotesSample]; // Get the quotes from quotesStore
    //NSLog(@"ChooseCompViewController - quotes count:%lu, %lu, %lu", (unsigned long)[self.quotesInPlist1 count], (unsigned long)[self.quotesInPlist2 count], (unsigned long)[self.quotesInPlist3 count]);
    
    [self threeRandomQuoteDict];
    [self setQuotesAndAuthors];
    [self adjustConstraints];
    
    /*=== Set up the recorder ===*/
    self.recordingStore = [[MQMRecordingsStore alloc] init];
    [self setupRecorder];
    
    // This handles interruptions
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(pauseRecorderAndTimer)
               name:AVAudioSessionInterruptionNotification
             object:nil];
    // Recording starts in Timer Configuration
    /*=== recorder end ===*/
    
    /*== Timer Configuration ==*/
    self.mainTimer = [[MZTimerLabel alloc] initWithTimerType:MZTimerLabelTypeTimer]; // Timer is a countdown timer
    self.mainTimer.delegate = self;
    [self.mainTimer setCountDownTime:7*60]; // 7 * 60 seconds = 7 minutes
    //self.mainTimer.timeFormat = @"HH:mm:ss";
    self.mainTimer.timeFormat = @"m";
    [self startTimer]; // Start the timer and start Recording
    /*== Timer Config. End ==*/
    
    /*== Add shadows to buttons == */
    [self makeShadows];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // Disable iOS 7 back gesture so that user doesnt accidentaly swipe out of view
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    if (self.currentQuote && !savedAlready) {
        // Enable iOS 7 back gesture
        if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
            self.navigationController.interactivePopGestureRecognizer.enabled = YES;
            self.navigationController.interactivePopGestureRecognizer.delegate = nil;
        }
        
        // save the recording and let user know
        [self.mainTimer pause];
        [recorder stop]; // 1 of 2 times the recorder will stop
        
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setActive:NO error:nil];
        
        // Now add the quote, author, and URL to the self.privateRecordings in MQMRecordingsStore
        
        NSDictionary *plistDict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:self.currentQuote, self.currentAuthor, self.filename, nil]
                                                              forKeys:[NSArray arrayWithObjects:@"quote", @"quoteAuthor", @"filename", nil]];
        
        [self.recordingStore.allRecordings addObject:plistDict]; // Add to recordingStores allRecording array
        
        NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *newPath = [rootPath stringByAppendingPathComponent:@"recordings.plist"];
        
        NSMutableArray *recordingsInStore = [NSMutableArray arrayWithContentsOfFile:newPath];
        
        [recordingsInStore addObject:plistDict];
        [recordingsInStore writeToFile:newPath atomically:YES];
        
        //NSLog(@"number of recordings in store: %lu", (long unsigned)[self.recordingStore.allRecordings count]);
        
        savedAlready = YES;
        self.hidesBottomBarWhenPushed = NO;
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Recording Finished!"
                                                        message:@"The recording has been saved!"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        // Enable iOS 7 back gesture
        if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
            self.navigationController.interactivePopGestureRecognizer.enabled = YES;
            self.navigationController.interactivePopGestureRecognizer.delegate = nil;
        }
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)startTimer {
    if (self.delayChoice == 0) {
        [self.mainTimer start];
    } if (self.delayChoice == 3) {
        [NSTimer scheduledTimerWithTimeInterval:3.0
                                         target:self
                                       selector:@selector(nstimerTarget)
                                       userInfo:nil
                                        repeats:NO];
    } if (self.delayChoice == 7) {
        [NSTimer scheduledTimerWithTimeInterval:7.0
                                         target:self
                                       selector:@selector(nstimerTarget)
                                       userInfo:nil
                                        repeats:NO];
    } if (self.delayChoice == 10) {
        [NSTimer scheduledTimerWithTimeInterval:10.0
                                         target:self
                                       selector:@selector(nstimerTarget)
                                       userInfo:nil
                                        repeats:NO];
    }
}

- (void)nstimerTarget {
    [self.mainTimer start]; // Starts after chosen delay
    
    // IMPORTANT: Think of a way to tell user that the timer has started
}

- (void)adjustConstraints {
    // Here we handle different screen sizes
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        if ([[UIScreen mainScreen] scale] == 2.0) {
            
            if([UIScreen mainScreen].bounds.size.height == 667){
                // iPhone retina-4.7 inch(iPhone 6)
                self.quote1.font = [self.quote1.font fontWithSize:20];
                self.quote2.font = [self.quote2.font fontWithSize:20];
                self.quote3.font = [self.quote3.font fontWithSize:20];
                self.author1.font = [self.quote3.font fontWithSize:16];
                self.author2.font = [self.quote3.font fontWithSize:16];
                self.author3.font = [self.quote3.font fontWithSize:16];
            }
            else if([UIScreen mainScreen].bounds.size.height == 568){
                // iPhone retina-4 inch(iPhone 5 or 5s)
            }
            else{
                // iPhone retina-3.5 inch(iPhone 4s)
                self.button1Height.constant = 110;
                self.button2Height.constant = 110;
                self.button3Height.constant = 110;
                
                self.quote2TopSpace.constant = 160;
                self.quote3TopSpace.constant = 280;
            }
        }
        else if ([[UIScreen mainScreen] scale] == 3.0)
        {
            //if you want to detect the iPhone 6+ only
            if([UIScreen mainScreen].bounds.size.height == 736.0){
                //iPhone retina-5.5 inch screen(iPhone 6 plus)
                self.quote1.font = [self.quote1.font fontWithSize:22];
                self.quote2.font = [self.quote2.font fontWithSize:22];
                self.quote3.font = [self.quote3.font fontWithSize:22];
                self.author1.font = [self.quote3.font fontWithSize:16];
                self.author2.font = [self.quote3.font fontWithSize:16];
                self.author3.font = [self.quote3.font fontWithSize:16];
            }
            //iPhone retina-5.5 inch screen(iPhone 6 plus)
        }
    }
}

- (void)setQuotesAndAuthors {
    // Now add the quote text to the labels. I need to add the strings from the dictionaries inside of the array
    self.quote1.adjustsFontSizeToFitWidth = YES;
    self.quote2.adjustsFontSizeToFitWidth = YES;
    self.quote3.adjustsFontSizeToFitWidth = YES;
    self.quote1.lineBreakMode = NSLineBreakByWordWrapping; // wrap to two lines
    self.quote1.numberOfLines = 0;
    self.quote2.lineBreakMode = NSLineBreakByWordWrapping; // wrap to two lines
    self.quote2.numberOfLines = 0;
    self.quote3.lineBreakMode = NSLineBreakByWordWrapping; // wrap to two lines
    self.quote3.numberOfLines = 0;
    // Now do the same thing for the author text.
    self.author1.adjustsFontSizeToFitWidth = YES;
    self.author2.adjustsFontSizeToFitWidth = YES;
    self.author3.adjustsFontSizeToFitWidth = YES;
    self.author1.lineBreakMode = NSLineBreakByWordWrapping; // wrap to two lines
    self.author1.numberOfLines = 0;
    self.author2.lineBreakMode = NSLineBreakByWordWrapping; // wrap to two lines
    self.author2.numberOfLines = 0;
    self.author3.lineBreakMode = NSLineBreakByWordWrapping; // wrap to two lines
    self.author3.numberOfLines = 0;
    // Now do the same thing for the timeLeftLabel
    self.timeSignal.adjustsFontSizeToFitWidth = YES;
    self.timeSignal.lineBreakMode = NSLineBreakByWordWrapping;
    self.timeSignal.numberOfLines = 0;
    
    self.quote1.text = [self.threeDict[0] objectForKey:@"quote"]; // Access first dictionary in array, get value at key "quote"
    self.quote2.text = [self.threeDict[1] objectForKey:@"quote"]; // same as above
    self.quote3.text = [self.threeDict[2] objectForKey:@"quote"]; // same as above
    
    self.author1.text = [self.threeDict[0] objectForKey:@"author"]; // Access first dictionary in array, get value at key "quote"
    self.author2.text = [self.threeDict[1] objectForKey:@"author"]; // same as above
    self.author3.text = [self.threeDict[2] objectForKey:@"author"]; // same as above
}

- (void)threeRandomQuoteDict {
    // NOTE: In our quotes database, the last dictionary entry in thearray is a filler.
    // Without it, the quotes wont shuffle right as a quote will get stuck on the bottom.
    
    if ([[MQMIAPHelper sharedInstance] productPurchased:@"com.myhkailmendoza.Improvyze.nonconsumable1"]) {
        self.threeDict = nil;
        self.threeDict = [[NSMutableArray alloc] init];
        
        // We want to make an array with quotes consisting from all three plist files...
        
        float quoteCount = [self.quotesInPlist1 count]; // Total number of quotes in quote database
        NSUInteger r = arc4random_uniform(quoteCount - 1); // Get random number between 0 and quoteCount-1
        NSDictionary *temp1 = self.quotesInPlist1[r]; // Assign the value associated with the r number to a temp dictionary
        
        quoteCount = [self.quotesInPlist2 count]; // Total number of quotes in quote database
        r = arc4random_uniform(quoteCount - 1); // Get random number between 0 and quoteCount-1
        NSDictionary *temp2 = self.quotesInPlist2[r]; // Assign the value associated with the r number to a temp dictionary
        
        quoteCount = [self.quotesInPlist3 count]; // Total number of quotes in quote database
        r = arc4random_uniform(quoteCount - 1); // Get random number between 0 and quoteCount-1
        NSDictionary *temp3 = self.quotesInPlist3[r]; // Assign the value associated with the r number to a temp dictionary
        
        [self.threeDict addObject:temp1]; // Add that dictionary to the seld.threeDict array used for labels
        [self.threeDict addObject:temp2]; // Add that dictionary to the seld.threeDict array used for labels
        [self.threeDict addObject:temp3]; // Add that dictionary to the seld.threeDict array used for labels
    } else {
        NSMutableArray *quotesSampleCopy = [NSMutableArray arrayWithArray:self.quotesSample];
        self.threeDict = nil;
        self.threeDict = [[NSMutableArray alloc] init];
        
        // We want to make an array with quotes consisting from all three plist files...
        for (int i = 0; i < 3; i++) {
            float quoteCount = [quotesSampleCopy count]; // Total number of quotes in quote database
            NSUInteger r = arc4random_uniform(quoteCount - 1); // Get random number between 0 and quoteCount-1
            NSDictionary *temp = quotesSampleCopy[r]; // Assign the value associated with the r number to a temp dictionary
            [self.threeDict addObject:temp];
            [quotesSampleCopy removeObject:temp];
        }
    }
}

- (IBAction)firstQuotePressed:(id)sender {
    // When a quote is pressed, the recroder starts. Then delete the other buttons, quotes, and authors
    // then it has to change its constraint top space to superview to the position of where the first button and quote were.
    [recorder record];
    self.currentQuote = self.quote1.text;
    self.currentAuthor = self.author1.text;
    
    // Now Disable other buttons
    [self.secondButton setEnabled:NO];
    [self.thirdButton setEnabled:NO];
    // Now hide the buttons, the quotes, and the authors
    self.secondButton.hidden = YES;
    self.thirdButton.hidden = YES;
    self.quote2.hidden = YES;
    self.author2.hidden = YES;
    self.quote3.hidden = YES;
    self.author3.hidden = YES;
    
    // Now enable the save button
    [self.saveButton setEnabled:YES];
    
    // Now handle moving the constraints. Top Space should equal 40. Button will move upwards
    [self.view layoutIfNeeded]; // Call once to see if the layout needs any changes
    self.timeLeftLabelVertConst.constant = 250;
    [UIView animateWithDuration:0.5 animations:^{
        [self.view layoutIfNeeded]; // Update the layout on the screen. This triggers the animation.
    }];
    
}

- (IBAction)secondQuotePresssed:(id)sender {
    [recorder record];
    self.currentQuote = self.quote2.text;
    self.currentAuthor = self.author2.text;
    
    // Now Disable other buttons
    [self.firstButton setEnabled:NO];
    [self.thirdButton setEnabled:NO];
    // Now hide the buttons, the quotes, and the authors
    self.firstButton.hidden = YES;
    self.thirdButton.hidden = YES;
    self.quote1.hidden = YES;
    self.author1.hidden = YES;
    self.quote3.hidden = YES;
    self.author3.hidden = YES;
    
    // Now enable the save button
    [self.saveButton setEnabled:YES];
    
    // Now handle moving the constraints. Top Space should equal 40. Button will move upwards
    [self.view layoutIfNeeded]; // Call once to see if the layout needs any changes
    self.quote2VertConstraint.constant = 40; // Change the value of the constraint
    self.timeLeftLabelVertConst.constant = 250;
    [UIView animateWithDuration:0.5 animations:^{
        [self.view layoutIfNeeded]; // Update the layout on the screen. This triggers the animation.
    }];
}

- (IBAction)thirdQuotePressed:(id)sender {
    [recorder record];
    self.currentQuote = self.quote3.text;
    self.currentAuthor = self.author3.text;
    
    // Now Disable other buttons
    [self.firstButton setEnabled:NO];
    [self.secondButton setEnabled:NO];
    // Now hide the buttons, the quotes, and the authors
    self.secondButton.hidden = YES;
    self.firstButton.hidden = YES;
    self.quote1.hidden = YES;
    self.author1.hidden = YES;
    self.quote2.hidden = YES;
    self.author2.hidden = YES;
    
    // Now enable the save button
    [self.saveButton setEnabled:YES];
    
    // Now handle moving the constraints. Top Space should equal 40. Button will move upwards
    [self.view layoutIfNeeded]; // Call once to see if the layout needs any changes
    self.quote3VertConstraint.constant = 40; // Change the value of the constraint
    self.timeLeftLabelVertConst.constant = 250;
    [UIView animateWithDuration:0.5 animations:^{
        [self.view layoutIfNeeded]; // Update the layout on the screen. This triggers the animation.
    }];
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

- (void)pauseRecorderAndTimer {
    // Use this to pause timer and recorder when interrupted
    if([self.mainTimer counting]){// If you change views while recording.
        [self.mainTimer pause];
        [recorder pause];
        
        [self.saveButton setEnabled:YES];
    }
}

- (IBAction)saveRecording:(id)sender {
    if (self.currentAuthor && self.currentQuote) {
        savedAlready = YES;
        [self.mainTimer pause];
        [recorder stop]; // 1 of 2 times the recorder will stop
        
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setActive:NO error:nil];
        
        // Now add the quote, author, and URL to the self.privateRecordings in MQMRecordingsStore
        
        NSDictionary *plistDict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:self.currentQuote, self.currentAuthor, self.filename, nil]
                                                              forKeys:[NSArray arrayWithObjects:@"quote", @"quoteAuthor", @"filename", nil]];
        
        [self.recordingStore.allRecordings addObject:plistDict]; // Add to recordingStores allRecording array
        
        NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *newPath = [rootPath stringByAppendingPathComponent:@"recordings.plist"];
        
        NSMutableArray *recordingsInStore = [NSMutableArray arrayWithContentsOfFile:newPath];
        
        [recordingsInStore addObject:plistDict];
        [recordingsInStore writeToFile:newPath atomically:YES];
        
        //NSLog(@"number of recordings in store: %lu", (long unsigned)[self.recordingStore.allRecordings count]);
        
        
        self.hidesBottomBarWhenPushed = NO;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Recording Finished!"
                                                        message:@"The recording has been saved!"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [self.navigationController popToRootViewControllerAnimated:NO];
    }
}

- (void)makeShadows {
    // Give buttons shadows
    self.firstButton.layer.shadowColor = [UIColor blackColor].CGColor;
    self.firstButton.layer.shadowOffset = CGSizeMake(1.0f,2.0f);
    self.firstButton.layer.masksToBounds = NO;
    self.firstButton.layer.shadowRadius = 1.0f;
    self.firstButton.layer.shadowOpacity = 1.0;
    
    self.secondButton.layer.shadowColor = [UIColor blackColor].CGColor;
    self.secondButton.layer.shadowOffset = CGSizeMake(1.0f,2.0f);
    self.secondButton.layer.masksToBounds = NO;
    self.secondButton.layer.shadowRadius = 1.0f;
    self.secondButton.layer.shadowOpacity = 1.0;
    
    self.thirdButton.layer.shadowColor = [UIColor blackColor].CGColor;
    self.thirdButton.layer.shadowOffset = CGSizeMake(1.0f,2.0f);
    self.thirdButton.layer.masksToBounds = NO;
    self.thirdButton.layer.shadowRadius = 1.0f;
    self.thirdButton.layer.shadowOpacity = 1.0;
}

- (void)flashColorIn {
    [UIView animateWithDuration: 0.5
                          delay: 0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations: ^{
                         self.view.backgroundColor = [UIColor redColor];
                     }
                     completion:NULL];
}

- (void)flashColorOut {
    [UIView animateWithDuration: 0.5
                          delay: 0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations: ^{
                         self.view.backgroundColor = [UIColor whiteColor];
                     }
                     completion:NULL];
}
/*****THIS IS MZTimerLabel DELEGATE Method*****/
- (void)timerLabel:(MZTimerLabel *)timerlabel countingTo:(NSTimeInterval)time timertype:(MZTimerLabelType)timerType{
    if (time <= 7*60) {
        if (!ranOnce) {
            // if it hasnt been ran yet
            self.timeSignal.text = @"2 min. prep started";
            ranOnce = YES;
        }
    }
    if (time <= 6*60+30) {
        if ([self.timeSignal.text  isEqual: @"2 min. prep started"]) {
            ranOnce = NO;
            self.timeSignal.text = nil;
            [self flashColorIn];
        }
        if (!ranOnce) {
            // if it hasnt been ran yet
            [self flashColorOut];
            self.timeSignal.text = @"00:30 used";
            ranOnce = YES;
        }
    }
    if (time <= 6*60) {
        if ([self.timeSignal.text  isEqual: @"00:30 used"]) {
            ranOnce = NO;
            self.timeSignal.text = nil;
            [self flashColorIn];
        }
        if (!ranOnce) {
            // if it hasnt been ran yet
            [self flashColorOut];
            self.timeSignal.text = @"01:00 used";
            ranOnce = YES;
        }
    }
    if (time <= 6*60-30) {
        if ([self.timeSignal.text  isEqual: @"01:00 used"]) {
            ranOnce = NO;
            self.timeSignal.text = nil;
            [self flashColorIn];
        }
        if (!ranOnce) {
            // if it hasnt been ran yet
            [self flashColorOut];
            self.timeSignal.text = @"01:30 used";
            ranOnce = YES;
        }
    }
    if (time <= 5*60) {
        if ([self.timeSignal.text  isEqual: @"01:30 used"]) {
            ranOnce = NO;
            self.timeSignal.text = nil;
            [self flashColorIn];
        }
        if (!ranOnce) {
            // if it hasnt been ran yet
            [self flashColorOut];
            self.timeSignal.text = @"02:00 used";
            ranOnce = YES;
        }
    }
    if(time <= 4*60) {
        if ([self.timeSignal.text  isEqual: @"02:00 used"]) {
            ranOnce = NO;
            self.timeSignal.text = nil;
            [self flashColorIn];
        }
        if (!ranOnce) {
            // if it hasnt been ran yet
            [self flashColorOut];
            self.timeSignal.text = @"04:00 remaining";
            ranOnce = YES;
        }
    }
    if(time <= 3*60) {
        if ([self.timeSignal.text  isEqual: @"04:00 remaining"]) {
            ranOnce = NO;
            self.timeSignal.text = nil;
            [self flashColorIn];
        }
        if (!ranOnce) {
            // if it hasnt been ran yet
            [self flashColorOut];
            self.timeSignal.text = @"03:00 remaining";
            ranOnce = YES;
        }
    }
    if(time <= 2*60) {
        if ([self.timeSignal.text  isEqual: @"03:00 remaining"]) {
            ranOnce = NO;
            self.timeSignal.text = nil;
            [self flashColorIn];
        }
        if (!ranOnce) {
            // if it hasnt been ran yet
            [self flashColorOut];
            self.timeSignal.text = @"02:00 remaining";
            ranOnce = YES;
        }
    }
    if(time <= 1*60) {
        if ([self.timeSignal.text  isEqual: @"02:00 remaining"]) {
            ranOnce = NO;
            self.timeSignal.text = nil;
            [self flashColorIn];
        }
        if (!ranOnce) {
            // if it hasnt been ran yet
            [self flashColorOut];
            self.timeSignal.text = @"01:00 remaining";
            ranOnce = YES;
        }
    }
    if(time <= 30) {
        if ([self.timeSignal.text  isEqual: @"01:00 remaining"]) {
            ranOnce = NO;
            self.timeSignal.text = nil;
            [self flashColorIn];
        }
        if (!ranOnce) {
            // if it hasnt been ran yet
            [self flashColorOut];
            self.timeSignal.text = @"00:30 remaining";
            ranOnce = YES;
        }
    }
    if(time <= 15) {
        if ([self.timeSignal.text  isEqual: @"00:30 remaining"]) {
            ranOnce = NO;
            self.timeSignal.text = nil;
            [self flashColorIn];
        }
        if (!ranOnce){
            // if it hasnt been ran yet
            [self flashColorOut];
            self.timeSignal.text = @"00:15 remaining";
            ranOnce = YES;
        }
    }
    if(time <= 10) {
        if ([self.timeSignal.text  isEqual: @"00:15 remaining"]) {
            ranOnce = NO;
            self.timeSignal.text = nil;
            [self flashColorIn];
        }
        if (!ranOnce) {
            // if it hasnt been ran yet
            [self flashColorOut];
            self.timeSignal.text = @"00:10 remaining";
            ranOnce = YES;
        }
    }
    if(time <= 5) {
        if ([self.timeSignal.text  isEqual: @"00:10 remaining"]) {
            ranOnce = NO;
            self.timeSignal.text = nil;
            [self flashColorIn];
        }
        if (!ranOnce) {
            // if it hasnt been ran yet
            [self flashColorOut];
            self.timeSignal.text = @"5";
            ranOnce = YES;
        }
    }
    if(time <= 4) {
        if ([self.timeSignal.text  isEqual: @"5"]) {
            ranOnce = NO;
            self.timeSignal.text = nil;
            [self flashColorIn];
        }
        if (!ranOnce) {
            // if it hasnt been ran yet
            [self flashColorOut];
            self.timeSignal.text = @"4";
            ranOnce = YES;
        }
    }
    if(time <= 3) {
        if ([self.timeSignal.text  isEqual: @"4"]) {
            ranOnce = NO;
            self.timeSignal.text = nil;
            [self flashColorIn];
        }
        if (!ranOnce) {
            // if it hasnt been ran yet
            [self flashColorOut];
            self.timeSignal.text = @"3";
            ranOnce = YES;
        }
    }
    if(time <= 2) {
        if ([self.timeSignal.text  isEqual: @"3"]) {
            ranOnce = NO;
            self.timeSignal.text = nil;
            [self flashColorIn];
        }
        if (!ranOnce) {
            // if it hasnt been ran yet
            [self flashColorOut];
            self.timeSignal.text = @"2";
            ranOnce = YES;
        }
    }
    if(time <= 1) {
        if ([self.timeSignal.text  isEqual: @"2"]) {
            ranOnce = NO;
            self.timeSignal.text = nil;
            [self flashColorIn];
        }
        if (!ranOnce) {
            // if it hasnt been ran yet
            [self flashColorOut];
            self.timeSignal.text = @"1";
            ranOnce = YES;
        }
    }
}

- (void)timerLabel:(MZTimerLabel*)timerLabel finshedCountDownTimerWithTime:(NSTimeInterval)countTime {
    self.timeSignal.text = @"Speaking Time Over";
}

@end










