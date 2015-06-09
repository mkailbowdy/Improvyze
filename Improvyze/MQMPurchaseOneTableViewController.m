//
//  MQMPurchaseOneTableViewController.m
//  Improvyze
//
//  Created by Myhkail Mendoza on 3/31/15.
//  Copyright (c) 2015 Myhkail Mendoza. All rights reserved.
//

#import "MQMPurchaseOneTableViewController.h"

// 1
#import "MQMIAPHelper.h"
#import <StoreKit/StoreKit.h>
#import <iAd/iAd.h>

// 2
@interface MQMPurchaseOneTableViewController () {
    NSArray *_products;
    NSNumberFormatter *_priceFormatter;
}
@end

@implementation MQMPurchaseOneTableViewController

// 3

- (instancetype)init {
    self = [super init];
    if (self) {
        self.tabBarItem.title = @"Shop";
        self.navigationItem.title = @"Shop";
        
        // Create a UIImage from a file
        // use Podium@2x.png
        UIImage *image = [UIImage imageNamed:@"Shopping@2x.png"];
        self.tabBarItem.image = image; // Put the image as the tabbar icon
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Restore" style:UIBarButtonItemStyleBordered target:self action:@selector(restoreTapped:)];

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(reload) forControlEvents:UIControlEventValueChanged];
    [self reload];
    [self.refreshControl beginRefreshing];
    
    _priceFormatter = [[NSNumberFormatter alloc] init];
    [_priceFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [_priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
}

- (void)restoreTapped:(id)sender {
    [[MQMIAPHelper sharedInstance] restoreCompletedTransactions];
}

// 4
- (void)reload {
    _products = nil;
    [self.tableView reloadData];
    [[MQMIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (success) {
            _products = products;
            [self.tableView reloadData];
        }
        [self.refreshControl endRefreshing];
    }];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

// 5
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _products.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    SKProduct *product = (SKProduct *) _products[indexPath.row];
    
    cell.textLabel.text = product.localizedTitle;
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:16.0];
    cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:14.0];
    cell.detailTextLabel.textColor = [UIColor grayColor];
    
    [_priceFormatter setLocale:product.priceLocale];
    cell.detailTextLabel.text = [_priceFormatter stringFromNumber:product.price];
    
    if ([[MQMIAPHelper sharedInstance] productPurchased:product.productIdentifier]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.accessoryView = nil;
    } else {
        UIButton *buyButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        buyButton.frame = CGRectMake(0, 0, 72, 37);
        [buyButton setTitle:@"Buy" forState:UIControlStateNormal];
        buyButton.tag = indexPath.row;
        [buyButton addTarget:self action:@selector(buyButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.accessoryView = buyButton;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return cell;
}

- (void)buyButtonTapped:(id)sender {
    
    UIButton *buyButton = (UIButton *)sender;
    SKProduct *product = _products[buyButton.tag];
    
    //NSLog(@"Buying %@...", product.productIdentifier);
    [[MQMIAPHelper sharedInstance] buyProduct:product];
    
}

// Remember that when a purchase completes, it will send a notification. So register for that notification, and reload the appropriate cell when it occurs so you can display the checkmark if appropriate:
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
    if ([[MQMIAPHelper sharedInstance] productPurchased:@"com.myhkailmendoza.Improvyze.nonconsumable1"]) {
        self.canDisplayBannerAds = NO;
        //NSLog(@"Product purchased, wont show ads");
    } else {
        self.canDisplayBannerAds = YES;
        //NSLog(@"Product NOT purchased, will show ads");
    }
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)productPurchased:(NSNotification *)notification {
    
    NSString * productIdentifier = notification.object;
    [_products enumerateObjectsUsingBlock:^(SKProduct * product, NSUInteger idx, BOOL *stop) {
        if ([product.productIdentifier isEqualToString:productIdentifier]) {
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            *stop = YES;
        }
    }];
    
}

@end