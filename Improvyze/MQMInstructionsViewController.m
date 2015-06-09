//
//  MQMInstructionsViewController.m
//  Improvyze
//
//  Created by Myhkail Mendoza on 4/14/15.
//  Copyright (c) 2015 Myhkail Mendoza. All rights reserved.
//

#import "MQMInstructionsViewController.h"
#import "MQMIAPHelper.h"
#import <iAd/iAd.h>

@interface MQMInstructionsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet UILabel *label2;
@property (weak, nonatomic) IBOutlet UILabel *label3;
@property (weak, nonatomic) IBOutlet UILabel *label4;
@property (weak, nonatomic) IBOutlet UILabel *label5;
@property (weak, nonatomic) IBOutlet UILabel *label6;

@end

@implementation MQMInstructionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Info";
    [self adjustLabels];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
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
    self.navigationController.navigationBar.hidden = YES;
}

- (void)adjustLabels {
    // Now add the quote text to the labels. I need to add the strings from the dictionaries inside of the array
    self.label1.adjustsFontSizeToFitWidth = YES;
    self.label2.adjustsFontSizeToFitWidth = YES;
    self.label3.adjustsFontSizeToFitWidth = YES;
    self.label4.adjustsFontSizeToFitWidth = YES;
    self.label5.adjustsFontSizeToFitWidth = YES;
    self.label6.adjustsFontSizeToFitWidth = YES;
    
    self.label1.lineBreakMode = NSLineBreakByWordWrapping; // wrap to two lines
    self.label1.numberOfLines = 0;
    self.label2.lineBreakMode = NSLineBreakByWordWrapping; // wrap to two lines
    self.label2.numberOfLines = 0;
    self.label3.lineBreakMode = NSLineBreakByWordWrapping; // wrap to two lines
    self.label3.numberOfLines = 0;
    self.label4.lineBreakMode = NSLineBreakByWordWrapping; // wrap to two lines
    self.label4.numberOfLines = 0;
    self.label5.lineBreakMode = NSLineBreakByWordWrapping; // wrap to two lines
    self.label5.numberOfLines = 0;
    self.label6.lineBreakMode = NSLineBreakByWordWrapping; // wrap to two lines
    self.label6.numberOfLines = 0;
    // Here we handle different screen sizes
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        if ([[UIScreen mainScreen] scale] == 2.0) {
            
            if([UIScreen mainScreen].bounds.size.height == 667){
                // iPhone retina-4.7 inch(iPhone 6)
                self.label1.font = [self.label1.font fontWithSize:22];
                self.label2.font = [self.label2.font fontWithSize:22];
                self.label3.font = [self.label3.font fontWithSize:22];
                self.label4.font = [self.label3.font fontWithSize:22];
                self.label5.font = [self.label3.font fontWithSize:22];
                self.label6.font = [self.label3.font fontWithSize:22];
            }
            else if([UIScreen mainScreen].bounds.size.height == 568){
                // iPhone retina-4 inch(iPhone 5 or 5s)
                self.label1.font = [self.label1.font fontWithSize:18];
                self.label2.font = [self.label2.font fontWithSize:18];
                self.label3.font = [self.label3.font fontWithSize:18];
                self.label4.font = [self.label3.font fontWithSize:18];
                self.label5.font = [self.label3.font fontWithSize:18];
                self.label6.font = [self.label3.font fontWithSize:18];
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
                self.label1.font = [self.label1.font fontWithSize:25];
                self.label2.font = [self.label2.font fontWithSize:25];
                self.label3.font = [self.label3.font fontWithSize:25];
                self.label4.font = [self.label3.font fontWithSize:25];
                self.label5.font = [self.label3.font fontWithSize:25];
                self.label6.font = [self.label3.font fontWithSize:25];
            }
            //iPhone retina-5.5 inch screen(iPhone 6 plus)
        }
    }
    
}


@end
