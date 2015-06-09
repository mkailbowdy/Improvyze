//
//  MQMChooseViewController.h
//  Impromptu Prep
//
//  Created by Myhkail Mendoza on 3/8/15.
//  Copyright (c) 2015 Myhkail Mendoza. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MQMPlayViewController;
@class MQMButton;

@interface MQMChooseViewController : UIViewController <UIAlertViewDelegate>

@property (strong, nonatomic) MQMPlayViewController *pvc;

@property (weak, nonatomic) IBOutlet MQMButton *firstButton;
@property (weak, nonatomic) IBOutlet MQMButton *secondButton;
@property (weak, nonatomic) IBOutlet MQMButton *thirdButton;
@property (weak, nonatomic) IBOutlet MQMButton *shuffleButton;




@end
