//
//  MQMInformationViewController.m
//  Improvyze
//
//  Created by Myhkail Mendoza on 4/16/15.
//  Copyright (c) 2015 Myhkail Mendoza. All rights reserved.
//

#import "MQMInformationViewController.h"

@interface MQMInformationViewController ()
@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet UILabel *label2;
@property (weak, nonatomic) IBOutlet UILabel *label3;
@property (weak, nonatomic) IBOutlet UILabel *label4;



@end

@implementation MQMInformationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"Info";
    [self adjustLabels];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)adjustLabels {
    // Here we handle different screen sizes
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        if ([[UIScreen mainScreen] scale] == 2.0) {
            
            if([UIScreen mainScreen].bounds.size.height == 667){
                // iPhone retina-4.7 inch(iPhone 6)
                self.label1.font = [self.label1.font fontWithSize:22];
                self.label2.font = [self.label2.font fontWithSize:20];
                self.label3.font = [self.label1.font fontWithSize:22];
                self.label4.font = [self.label2.font fontWithSize:20];
            }
            else if([UIScreen mainScreen].bounds.size.height == 568){
                // iPhone retina-4 inch(iPhone 5 or 5s)
                self.label1.font = [self.label1.font fontWithSize:22];
                self.label2.font = [self.label2.font fontWithSize:18];
                self.label3.font = [self.label1.font fontWithSize:22];
                self.label4.font = [self.label2.font fontWithSize:18];
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
                self.label2.font = [self.label2.font fontWithSize:22];
                self.label3.font = [self.label1.font fontWithSize:24];
                self.label4.font = [self.label2.font fontWithSize:22];
            }
            //iPhone retina-5.5 inch screen(iPhone 6 plus)
        }
    }
    
}
@end
