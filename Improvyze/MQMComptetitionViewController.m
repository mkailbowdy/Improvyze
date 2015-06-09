//
//  MQMComptetitionViewController.m
//  Impromptu Prep
//
//  Created by Myhkail Mendoza on 3/18/15.
//  Copyright (c) 2015 Myhkail Mendoza. All rights reserved.
//

#import "MQMComptetitionViewController.h"
#import "MQMChooseCompViewController.h"
#import "MQMIAPHelper.h"
#import "MQMInstructionsViewController.h"
#import "MQMButton.h"
#import <iAd/iAd.h>

@interface MQMComptetitionViewController ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *delayControl;
@property (weak, nonatomic) IBOutlet MQMButton *readyButton;
@property (weak, nonatomic) IBOutlet UILabel *label2;
@property (weak, nonatomic) IBOutlet UILabel *label6;
@property (nonatomic, strong) NSArray *products;

// Constraints

@end

@implementation MQMComptetitionViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tabBarItem.title = @"Competition";
        self.navigationItem.title = @"";
        
        // Create a UIImage from a file
        // use Podium@2x.png
        UIImage *image = [UIImage imageNamed:@"Podium@2x.png"];
        self.tabBarItem.image = image; // Put the image as the tabbar icon
    }
    
    return self;
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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self adjustLabels];
    [self adjustConstraints];
    [self.readyButton makeRounded];
    [self.readyButton makeShadow];
}

- (void)userDelayChoice {
    if (self.delayControl.selectedSegmentIndex == 0) {
        self.delayChoice = 0;
    }
    if (self.delayControl.selectedSegmentIndex == 1) {
        self.delayChoice = 3;
    }
    if (self.delayControl.selectedSegmentIndex == 2) {
        self.delayChoice = 7;
    }
    if (self.delayControl.selectedSegmentIndex == 3) {
        self.delayChoice = 10;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)startTiming:(id)sender {
    MQMChooseCompViewController *ccvc = [[MQMChooseCompViewController alloc] init];
    
    ccvc.delayChoice = self.delayChoice;
    [self.navigationController pushViewController:ccvc animated:YES];
}
- (IBAction)segmentPicked:(id)sender {
    [self userDelayChoice]; // Set the seconds
}
- (IBAction)showInstructions:(id)sender {
    MQMInstructionsViewController *ivc = [[MQMInstructionsViewController alloc] init];
    [self.navigationController pushViewController:ivc animated:YES];
}

- (void)adjustLabels {
    // Now add the quote text to the labels.
    // I need to add the strings from the dictionaries inside of the array
    self.label2.adjustsFontSizeToFitWidth = YES;
    self.label6.adjustsFontSizeToFitWidth = YES;

    self.label2.lineBreakMode = NSLineBreakByWordWrapping;
    self.label2.numberOfLines = 0;
    self.label6.lineBreakMode = NSLineBreakByWordWrapping;
    self.label6.numberOfLines = 0;
}

- (void)adjustConstraints {
    // Here we handle different screen sizes
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        if ([[UIScreen mainScreen] scale] == 2.0) {
            if([UIScreen mainScreen].bounds.size.height == 667){
                // iPhone retina-4.7 inch(iPhone 6)
                //self.label2.font = [self.label2.font fontWithSize:20];
            }
            else if([UIScreen mainScreen].bounds.size.height == 568){
                // iPhone retina-4 inch(iPhone 5 or 5s)
            }
            else{
                // iPhone retina-3.5 inch(iPhone 4s)
            }
        }
        else if ([[UIScreen mainScreen] scale] == 3.0)
        {
            //if you want to detect the iPhone 6+ only
            if([UIScreen mainScreen].bounds.size.height == 736.0){
                //iPhone retina-5.5 inch screen(iPhone 6 plus)
            }
            //iPhone retina-5.5 inch screen(iPhone 6 plus)
        }
    }
}
@end
