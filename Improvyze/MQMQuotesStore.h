//
//  MQMQuotesStore.h
//  Impromptu Prep
//
//  Created by Myhkail Mendoza on 3/3/15.
//  Copyright (c) 2015 Myhkail Mendoza. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MQMQuotesStore : NSObject
{
    NSString *author;
    NSString *quote;
}

@property (nonatomic, copy) NSArray *quotesInPlist;
@property (nonatomic, copy) NSArray *quotesInPlist2;
@property (nonatomic, copy) NSArray *quotesInPlist3;
@property (nonatomic, copy) NSArray *quotesSample;
+ (instancetype)sharedStore;

@end
