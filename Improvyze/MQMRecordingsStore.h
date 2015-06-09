//
//  MQMRecordingsStore.h
//  Impromptu Prep
//
//  Created by Myhkail Mendoza on 3/4/15.
//  Copyright (c) 2015 Myhkail Mendoza. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MQMRecordingsStore : NSObject
{
    NSURL *url;
    NSString *quote;
    NSString *author;
}

@property (nonatomic) NSMutableArray *allRecordings;

- (void)removeRecording:(NSString *)filename;
- (void)deleteDictionary:(NSInteger)i;

@end
