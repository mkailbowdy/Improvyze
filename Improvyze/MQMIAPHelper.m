//
//  FruitIAPHelper.m
//  BuyFruit
//
//  Created by Michael Beyer on 16.09.13.
//  Copyright (c) 2013 Michael Beyer. All rights reserved.
//

#import "MQMIAPHelper.h"

static NSString *kIdentifierUnlockFull = @"com.myhkailmendoza.Improvyze.nonconsumable1";

@implementation MQMIAPHelper

// Obj-C Singleton pattern
+ (MQMIAPHelper *)sharedInstance {
    static dispatch_once_t once;
    static MQMIAPHelper *sharedInstance;
    dispatch_once(&once, ^{
        NSSet *productIdentifiers = [NSSet setWithObjects:
                                     kIdentifierUnlockFull,
                                     nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}

@end
