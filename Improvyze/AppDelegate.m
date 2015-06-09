//
//  AppDelegate.m
//  Impromptu Prep
//
//  Created by Myhkail Mendoza on 2/23/15.
//  Copyright (c) 2015 Myhkail Mendoza. All rights reserved.
//

#import "AppDelegate.h"
#import "MQMChooseViewController.h"
#import "MQMComptetitionViewController.h"
#import "MQMPlayViewController.h"
#import "MQMRecordingsViewController.h"
#import "MZTimerLabel.h"
#import "RFRateme.h"

// Register our class as a transaction observer
#import "MQMIAPHelper.h"
#import "MQMPurchaseOneTableViewController.h"

@interface AppDelegate ()
// Need this to pause the timer when app goes to background.
@property (nonatomic) MQMChooseViewController *cvc;

@end

@implementation AppDelegate

@synthesize tabBarController = _tabBarController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Apple will keep track of any purchase transactions that haven’t yet been fully processed by your app, and will notify the transaction observer about them, so call MQMIAPHelper immediately.
    [MQMIAPHelper sharedInstance];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    UIApplication* myApp = [UIApplication sharedApplication];
    myApp.idleTimerDisabled = YES;
    
    // Show rating
    [RFRateMe showRateAlertAfterTimesOpened:3];
    
    // Create playViewController and recordings
    self.cvc = [[MQMChooseViewController alloc] init];
    MQMComptetitionViewController *compvc = [[MQMComptetitionViewController alloc] init];
    MQMRecordingsViewController *recordingsViewController = [[MQMRecordingsViewController alloc] init];
    MQMPurchaseOneTableViewController *ptvc = [[MQMPurchaseOneTableViewController alloc] init];
    
    UINavigationController *nc1 = [[UINavigationController alloc] initWithRootViewController:self.cvc];
    nc1.navigationBar.hidden = YES;
    
    UINavigationController *nc2 = [[UINavigationController alloc] initWithRootViewController:compvc];
    nc2.navigationBar.hidden = YES;
    UINavigationController *nc3 = [[UINavigationController alloc] initWithRootViewController:recordingsViewController];
    UINavigationController *nc4 = [[UINavigationController alloc] initWithRootViewController:ptvc];
    
    nc3.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor colorWithRed:242.0f/255.0f green:116.0f/255.0f blue:19.0f/255.0f alpha:1.0f] forKey:NSForegroundColorAttributeName];
    nc4.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor colorWithRed:242.0f/255.0f green:116.0f/255.0f blue:19.0f/255.0f alpha:1.0f] forKey:NSForegroundColorAttributeName];
    
    self.tabBarController = [[UITabBarController alloc] init];
    
    [[UITabBar appearance] setTintColor:[UIColor colorWithRed:242.0f/255.0f green:116.0f/255.0f blue:19.0f/255.0f alpha:1.0f]];
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:242.0f/255.0f green:116.0f/255.0f blue:19.0f/255.0f alpha:1.0f]];
    [[UINavigationBar appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor colorWithRed:242.0f/255.0f green:116.0f/255.0f blue:19.0f/255.0f alpha:1.0f], NSForegroundColorAttributeName,
      [UIFont fontWithName:@"Helvetica Neue" size:20.0], NSFontAttributeName,nil]];
    
    self.tabBarController.viewControllers = @[nc1, nc2, nc3, nc4];
    
    self.window.rootViewController = self.tabBarController;
    self.tabBarController.selectedIndex = 0; // Make it so Comp screen launches first
    
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    if ([self.cvc.pvc.mainTimer counting]) {
        [self.cvc.pvc pauseRecorderAndTimer]; // Pause the timer and recoder when app goes to background
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
