//
//  IAPHelper.m
//  BuyFruit
//
//  Created by Michael Beyer on 12.09.13.
//  Copyright (c) 2013 Michael Beyer. All rights reserved.
//

#import "IAPHelper.h"
@import StoreKit;
/* IAPHELPER WILL GET THE LIST OF IN-APP PRODUCTS FROM ITUNESCONNECT. ALSO, KEEPS TRACK OF PREVIOUS PURCHASES 
 It will save the product identifier for each product that has been purchased in NSUserDefaults. */

// You need to use StoreKit to access the In-App Purchase APIs, so you import the StoreKit here.


NSString *const IAPHelperProductPurchasedNotification = @"IAPHelperProductPurchasedNotification";
/*
 To receive a list of products from StoreKit, you need to implement the SKProductsRequestDelegate protocol.
 Here you mark the class as implementing this protocol in the class extension.
 For purchasing: modify the class extension to mark the class as implementing the SKPaymentTransactionObserver:
 */
@interface IAPHelper () <SKProductsRequestDelegate, SKPaymentTransactionObserver>
@end

@implementation IAPHelper
{
    /* You create an instance variable to store the SKProductsRequest you will issue to retrieve a list of products, while it is active. You keep a reference to the request so a) you can know if you have one active already, and b) you’ll be guaranteed that it’s in memory while it’s active.*/
    SKProductsRequest *_productsRequest;
    
    /*You also keep track of the completion handler for the outstanding products request, the list of product identifiers passed in, and the list of product identifers that have been previously purchased. */
    RequestProductsCompletionHandler _completionHandler;
    
    // ... the list of product identifiers passed in, ...
    NSSet *_productIdentifiers;
    // ... and the list of product identifiers that have been previously purchased.
    NSMutableSet * _purchasedProductIdentifiers;
}

// Initialitzer to check which products have been purchased or not
- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers
{
    self = [super init];
    if (self) {
        // Store product identifiers
        _productIdentifiers = productIdentifiers;
        
        // Check for previously purchased products
        // This is important in order to check if a user already purchased products, so that we can show them to the user
        _purchasedProductIdentifiers = [NSMutableSet set];
        for (NSString *productIdentifier in _productIdentifiers) {
            // For every productIdentifier in the NSSet, check the NSUserDefaults if they are true or false
            BOOL productPurchased = [[NSUserDefaults standardUserDefaults] boolForKey:productIdentifier];
            if (productPurchased) {
                [_purchasedProductIdentifiers addObject:productIdentifier];
               // NSLog(@"Previously purchased: %@", productIdentifier);
            } else {
                //NSLog(@"Not purchased: %@", productIdentifier);
            }
        }
        // add self as transaction observer:
        // Code to identify when a payment “transaction” has finished, and process it accordingly.
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;
}

// requestProductsWithCompletionHandler retrieves the product information from iTunes Connect:
- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler
{
    // This squirrels a copy of the completion handler block inside the instance variable so it can notify the caller when the product request asynchronously completes.
    _completionHandler = [completionHandler copy];
    // Create a new instance of SKProductsRequest, which is the Apple-written class that contains the code to pull the info from iTunes Connect. you just give it a delegate (that conforms to the SKProductsRequestDelegate protocol) and then call start to get things running.
    _productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:_productIdentifiers];
    _productsRequest.delegate = self;
    // IAPHelper class will receive callback when product list completes/fails.
    [_productsRequest start];
}

#pragma mark - SKProductsRequestDelegate

// If requestProductsWithCH is successful, this is called
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
   // NSLog(@"Loaded products...");
    _productsRequest = nil;
    
    NSArray *skProducts = response.products;
    for (SKProduct *skProduct in skProducts) {
        NSLog(@"Found product: %@ %@ %0.2f", skProduct.productIdentifier, skProduct.localizedTitle, skProduct.price.floatValue);
    }
    
    // method definition; (BOOL success, NSArray * products) ... success YES, and the array of products is skProducts
    _completionHandler(YES, skProducts);
    _completionHandler = nil;
}

// If requestProductsWithCH fails, this is called
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Failed to load list of products."
                                                      message:nil
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    [message show];
    
    //NSLog(@"Failed to load list of products.");
    
    _productsRequest = nil;
    
    // method definition; (BOOL success, NSArray * products) ... success NO, and the array of products is nil
    _completionHandler(NO, nil);
    _completionHandler = nil;
}

- (BOOL)productPurchased:(NSString *)productIdentifier
{
    return [_purchasedProductIdentifiers containsObject:productIdentifier];
}

- (void)buyProduct:(SKProduct *)product
{
    //NSLog(@"Buying %@ ... (buyProduct in IAPHelper)", product.productIdentifier);
    
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

# pragma mark - SKPaymentTransactionObserver Protocol
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    };
}

// called when the transaction was successful
- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    //NSLog(@"completeTransaction...");
    
    [self provideContentForProductIdentifier:transaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

// called when a transaction has been restored and successfully completed
- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
   // NSLog(@"restoreTransaction...");
    
    [self provideContentForProductIdentifier:transaction.originalTransaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

// called when a transaction has failed
- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    //NSLog(@"failedTransaction...");
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
       // NSLog(@"Transaction error: %@", transaction.error.localizedDescription);
    }
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

/* When a product is purchased, this method adds the product identifier to the list of purchaed product identifiers, marks it as purchased in NSUserDefaults, and sends a notification so others can be aware of the purchase */
- (void)provideContentForProductIdentifier:(NSString *)productIdentifier
{
   // NSLog(@"provideContentForProductIdentifier");
    
    [_purchasedProductIdentifiers addObject:productIdentifier];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:productIdentifier];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductPurchasedNotification
                                                        object:productIdentifier
                                                      userInfo:nil];
}

- (void)restoreCompletedTransactions
{
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

@end