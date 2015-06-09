//
//  MQMRecordingsStore.m
//  Impromptu Prep
//
//  Created by Myhkail Mendoza on 3/4/15.
//  Copyright (c) 2015 Myhkail Mendoza. All rights reserved.
//

#import "MQMRecordingsStore.h"

@interface MQMRecordingsStore ()

@end

@implementation MQMRecordingsStore

- (instancetype)init {
    self = [super init];
    if (self) {
        NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *plistPath = [rootPath stringByAppendingPathComponent:@"recordings.plist"];
        
        NSFileManager *defaultManager = [NSFileManager defaultManager];
        if ([defaultManager fileExistsAtPath:plistPath]) {
           // NSLog(@"The documentation file is NOT EMPTY");
        } else {
           // NSLog(@"The documentation file IS EMPTY");
        }
        
        // If there's no plist file in Documentation folder, look for it in the bundle and copy it to Documents
        // then in okay view controller we'll write it into the documents folder.
        if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
            plistPath = [[NSBundle mainBundle] pathForResource:@"recordings" ofType:@"plist"];
            
            NSError *error;
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSString *newPath = [rootPath stringByAppendingPathComponent:@"recordings.plist"];
            [fileManager copyItemAtPath:plistPath toPath:newPath error:&error];
            
            //NSLog(@"Changed plist path to app bundle");
        }
        
        // Load whatever's in the recordings.plist file into an privateRecordings
        NSArray *recordingsInPlist = [NSArray arrayWithContentsOfFile:plistPath];
        
        self.allRecordings = [NSMutableArray arrayWithArray:recordingsInPlist];
       // NSLog(@"Number of recordings in store: %lu", (unsigned long)[self.allRecordings count]);
    }
    return self;
}

// Implement method that adds recordings to self.privateRecordings after doneTapped: is pressed

- (void)newRecording:(NSDictionary *)d {
    [self.allRecordings addObject:d];
}

- (void)deleteDictionary:(NSInteger)i {
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [rootPath stringByAppendingPathComponent:@"recordings.plist"];
    
    [self.allRecordings removeObjectAtIndex:i]; // i is the indexPath.row from the tableView.
    
    [self.allRecordings writeToFile:filePath atomically:YES]; // Overwrite the Plist to reflect deletion
    
    //NSLog(@"RecordingStore: count of recordings in allRecordings: %lu", (unsigned long)[self.allRecordings count]);
}

- (void)removeRecording:(NSString *)filename {
    // WE'RE GOING TO TRY JUST DELETING ONLY THE FILE AND NOT REMOVING FROM ARRAY
    // Delete the recording from the documents directory
    NSFileManager *fileManager = [NSFileManager defaultManager]; // we use it to delete the .m4a file
    NSError *error;
    
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *filePath = [rootPath stringByAppendingPathComponent:filename];
   // NSLog(@"filePath is: %@", filePath);
    BOOL success = [fileManager removeItemAtPath:filePath error:&error];
    if (success) {
      //  NSLog(@"Successfully Deleted");
    } else {
       // NSLog(@"Couldn't delete file -: %@", [error localizedDescription]);
    }
}

@end
