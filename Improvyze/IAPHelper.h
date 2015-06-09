//
//  IAPHelper.h
//  Improvyze
//
//  Created by Myhkail Mendoza on 3/30/15.
//  Copyright (c) 2015 Myhkail Mendoza. All rights reserved.
//

/* Process of purchasing
 Now we have a user interface that shows nice fruits we can buy and the helper-classes set up, we want to set up the purchasing process.
 
 The basic gist of making a purchase is the following:
 
 First: you create a SKPayment object and specify what productIdentifier the user wants to purchase and add it to a payment queue.
 
 Second: StoreKit will prompt the user “Are you sure?”, ask them to enter their username/password, make the charge, and send you a success or failure. StoreKit also handles the case where the user already paid for the product and is just re-downloading it, and give you a message for that as well.
 
 Third: you designate a particular object to receive purchase notifications. That object needs to start the process of downloading the content (not necessary in your case, since it’s hardcoded) and unlocking the content (which in your case is just setting that flag in NSUserDefaults and storing it in the purchasedProducts array).
 
 Once again, most of this is going to be in the IAPHelper class for easy reuse. */

@import Foundation;
@import StoreKit;

// UIKIT_EXTERN is a notification you’ll use to notify listeners when a product has been purchased
UIKIT_EXTERN NSString *const IAPHelperProductPurchasedNotification;
// Block Definition
typedef void (^RequestProductsCompletionHandler)(BOOL success, NSArray *products);

@interface IAPHelper : NSObject

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers;
/* requestProductsWithCompletionHandler retrieves information about the products from iTunes Connect. This method is asynchronous, and it takes a block as a parameter so it can notify the caller when it is complete. */
- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler;

- (void)buyProduct:(SKProduct *)product;
- (BOOL)productPurchased:(NSString *)productIdentifier;

- (void)restoreCompletedTransactions;
@end
