//
//  MQMRecordings.m
//  Impromptu Prep
//
//  Created by Myhkail Mendoza on 2/25/15.
//  Copyright (c) 2015 Myhkail Mendoza. All rights reserved.
//

#import "MQMRecordingsViewController.h"
#import "MQMPlayViewController.h"
#import "MQMRecordingsStore.h"
#import "MQMIAPHelper.h"
#import <iAd/iAd.h>

@interface MQMRecordingsViewController ()
@property (nonatomic) MQMRecordingsStore *recordingStore;
@end

@implementation MQMRecordingsViewController

- (instancetype)init {
    // Call the superclass' designated initializer
    
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.navigationItem.title = @"Recordings";
        self.tabBarItem.title = @"Recordings";
        
        // Create a UIImage from a file
        // use Archive@2x.png
        UIImage *image = [UIImage imageNamed:@"Archive@2x.png"];
        self.tabBarItem.image = image; // Put the image as the tabbar icon
        self.navigationItem.leftBarButtonItem = self.editButtonItem;
    }
    return self;
}
- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    return self;
    // This will ensure that all instances of BNRItemsViewController use the UITableViewStylePlain style,
    // no matter what initialization message is sent to them.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([[MQMIAPHelper sharedInstance] productPurchased:@"com.myhkailmendoza.Improvyze.nonconsumable1"]) {
        self.canDisplayBannerAds = NO;
      //  NSLog(@"Product purchased, wont show ads");
    } else {
        self.canDisplayBannerAds = YES;
        //NSLog(@"Product NOT purchased, will show ads");
    }
    [self.tableView reloadData];
}


- (void)viewWillDisappear:(BOOL)animated {
    if ([self isEditing]) {
        [self setEditing:NO]; // Exit edit mode if you leave screen
    }
}

#pragma mark - TableView Protocol

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return number of recordings saved.
    self.recordingStore = [[MQMRecordingsStore alloc] init];
    
    return [self.recordingStore.allRecordings count];
    
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *recordings = [self.recordingStore allRecordings];
    NSDictionary *recording = recordings[indexPath.row];
    
    NSString *quote = [recording objectForKey:@"quote"]; // We have to assign the labels text using NSString, cant it in reviewvc's init
    NSString *author = [recording objectForKey:@"quoteAuthor"];// same as quote
    // Here we will alloc/init the MQMReviewVC
    MQMReviewViewController *rvc = [[MQMReviewViewController alloc] init];
    
    rvc.currentDictionary = recording;
    rvc.quotation.text = quote;
    rvc.author.text = author;
    
    //NSLog(@"nsdictionary: %@", [recording objectForKey:@"quote"]);
    [self.navigationController pushViewController:rvc animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Create an instance of uitableviewcell with subtitle appearance
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                   reuseIdentifier:@"UITableViewCell"];
    
    // Set the text of the cell using the quotes 
    NSArray *recordings = self.recordingStore.allRecordings;
    NSDictionary *recording = recordings[indexPath.row];
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:16.0];
    cell.textLabel.text = [recording objectForKey:@"quote"];
    cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:14.0];
    cell.detailTextLabel.textColor = [UIColor grayColor];
    cell.detailTextLabel.text = [recording objectForKey:@"quoteAuthor"];
    
    
    return cell;
}
- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    // If the table view is asking to commit a delete command...
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the recording
        NSMutableArray *recordings = [self.recordingStore allRecordings]; // Get the array from recordingStore
        NSDictionary *recording = recordings[indexPath.row]; // The dictionary that was chosen
        NSString *filename = [recording objectForKey:@"filename"]; // Use filename to delete in docs
        
        [self.recordingStore deleteDictionary:indexPath.row]; // Delete the dictionary from array
        //NSLog(@"RecordingsView count of recordings in allRecordings: %lu", (unsigned long)[self.recordingStore.allRecordings count]);
        
        [self.recordingStore removeRecording:filename];
        
        // Also remove that row from the table view with an animation
        [tableView deleteRowsAtIndexPaths:@[indexPath]
                         withRowAnimation:UITableViewRowAnimationFade];
    }
}

@end
























