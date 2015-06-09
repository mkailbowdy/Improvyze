//
//  MQMQuotesStore.m
//  Impromptu Prep
//
//  Created by Myhkail Mendoza on 3/3/15.
//  Copyright (c) 2015 Myhkail Mendoza. All rights reserved.
//

#import "MQMQuotesStore.h"

@interface MQMQuotesStore ()

@end

@implementation MQMQuotesStore

+ (instancetype)sharedStore {
    // static variables are not destroyed when method is finished
    // Like a global variable, they are not on the stack
    static MQMQuotesStore *sharedStore; // inits to nil
    
    // Do I need to create a sharedStore?
    if (!sharedStore) {
        sharedStore = [[self alloc] initPrivate];
    }
    return sharedStore;
}

// If a programmer calls [[MQMQuotesStore alloc] init], let him know the error of his ways
- (instancetype)init {
    [NSException raise:@"Singleton" format:@"Use +[MQMQuotesStore sharedStore]"];
    return nil;
}


- (instancetype)initPrivate {
    self = [super init];
    if (self) {
        // Get the path for the plist in bundle
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"quotes" ofType:@"plist"];
        self.quotesInPlist = [NSArray arrayWithContentsOfFile:plistPath];
        plistPath = [[NSBundle mainBundle] pathForResource:@"quotes2" ofType:@"plist"];
        self.quotesInPlist2 = [NSArray arrayWithContentsOfFile:plistPath];
        plistPath = [[NSBundle mainBundle] pathForResource:@"quotes3" ofType:@"plist"];
        self.quotesInPlist3 = [NSArray arrayWithContentsOfFile:plistPath];
        plistPath = [[NSBundle mainBundle] pathForResource:@"quotesSample" ofType:@"plist"];
        self.quotesSample = [NSArray arrayWithContentsOfFile:plistPath];
        
        //NSLog(@"QuotesStore - quotesInPlist count: %lu, %lu, %lu", (unsigned long)[self.quotesInPlist count], (unsigned long)[self.quotesInPlist2 count], (unsigned long)[self.quotesInPlist3 count]);
    }
    return self;
}

@end
