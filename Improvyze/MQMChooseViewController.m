//
//  MQMChooseViewController.m
//  Impromptu Prep
//
//  Created by Myhkail Mendoza on 3/8/15.
//  Copyright (c) 2015 Myhkail Mendoza. All rights reserved.
//

#import "MQMChooseViewController.h"
#import "MQMQuotesStore.h"
#import "MQMPlayViewController.h"
#import "MQMIAPHelper.h"
#import "MQMButton.h"
#import "MQMPurchaseOneTableViewController.h"

@interface MQMChooseViewController ()
@property (nonatomic) NSMutableArray *threeDict; // The 3 final quotes
@property (nonatomic) NSArray *quotesInPlist1;
@property (nonatomic) NSArray *quotesInPlist2;
@property (nonatomic) NSArray *quotesInPlist3;
@property (nonatomic) NSArray *quotesSample;
@property (nonatomic) NSArray *products;


@property (nonatomic) int shuffleCounter;

@property (weak, nonatomic) IBOutlet UILabel *quote1;
@property (weak, nonatomic) IBOutlet UILabel *quote2;
@property (weak, nonatomic) IBOutlet UILabel *quote3;
@property (weak, nonatomic) IBOutlet UILabel *author1;
@property (weak, nonatomic) IBOutlet UILabel *author2;
@property (weak, nonatomic) IBOutlet UILabel *author3;
// Constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *button1Height;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *button2Height;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *button3Height;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *quote1TopSpace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *quote2TopSpace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *quote3TopSpace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shuffleButtonCenterY;

@end

@implementation MQMChooseViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tabBarItem.title = @"Practice";
        
        // Create a UIImage from a file
        // use Podium@2x.png
        UIImage *image = [UIImage imageNamed:@"Yoga@2x.png"];
        self.tabBarItem.image = image; // Put the image as the tabbar icon
        self.shuffleCounter = 0;
        
        [[MQMIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
            if (success) {
                _products = products;
            }
        }];
        
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self.firstButton makeRounded];
    [self.secondButton makeRounded];
    [self.thirdButton makeRounded];
    
    // Do any additional setup after loading the view from its nib.
    self.quotesInPlist1 =  [[MQMQuotesStore sharedStore] quotesInPlist]; // Get the quotes from quotesStore
    self.quotesInPlist2 =  [[MQMQuotesStore sharedStore] quotesInPlist2]; // Get the quotes from quotesStore
    self.quotesInPlist3 =  [[MQMQuotesStore sharedStore] quotesInPlist3]; // Get the quotes from quotesStore
    //NSLog(@"ChooseViewController - quotes count:%lu, %lu, %lu", (unsigned long)[self.quotesInPlist1 count], (unsigned long)[self.quotesInPlist2 count], (unsigned long)[self.quotesInPlist3 count]);
    
    [self threeRandomQuoteDict];
    [self setQuotesAndAuthors];
    [self adjustConstraints];
    [self makeShadows];
}

- (void)makeShadows {
    // Give buttons shadows
    self.firstButton.layer.shadowColor = [UIColor blackColor].CGColor;
    self.firstButton.layer.shadowOffset = CGSizeMake(1.0f,2.0f);
    self.firstButton.layer.masksToBounds = NO;
    self.firstButton.layer.shadowRadius = 1.0f;
    self.firstButton.layer.shadowOpacity = 1.0;
    
    self.secondButton.layer.shadowColor = [UIColor blackColor].CGColor;
    self.secondButton.layer.shadowOffset = CGSizeMake(1.0f,2.0f);
    self.secondButton.layer.masksToBounds = NO;
    self.secondButton.layer.shadowRadius = 1.0f;
    self.secondButton.layer.shadowOpacity = 1.0;
    
    self.thirdButton.layer.shadowColor = [UIColor blackColor].CGColor;
    self.thirdButton.layer.shadowOffset = CGSizeMake(1.0f,2.0f);
    self.thirdButton.layer.masksToBounds = NO;
    self.thirdButton.layer.shadowRadius = 1.0f;
    self.thirdButton.layer.shadowOpacity = 1.0;
    
    self.shuffleButton.layer.shadowColor = [UIColor blackColor].CGColor;
    self.shuffleButton.layer.shadowOffset = CGSizeMake(0.0f,2.0f);
    self.shuffleButton.layer.masksToBounds = NO;
    self.shuffleButton.layer.shadowRadius = 1.0f;
    self.shuffleButton.layer.shadowOpacity = 0.2;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)adjustConstraints {
    // Here we handle different screen sizes
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        if ([[UIScreen mainScreen] scale] == 2.0) {
    
            if([UIScreen mainScreen].bounds.size.height == 667){
                // iPhone retina-4.7 inch(iPhone 6)
                self.quote1.font = [self.quote1.font fontWithSize:20];
                self.quote2.font = [self.quote2.font fontWithSize:20];
                self.quote3.font = [self.quote3.font fontWithSize:20];
                self.author1.font = [self.quote3.font fontWithSize:16];
                self.author2.font = [self.quote3.font fontWithSize:16];
                self.author3.font = [self.quote3.font fontWithSize:16];
            }
            else if([UIScreen mainScreen].bounds.size.height == 568){
                // iPhone retina-4 inch(iPhone 5 or 5s)
            }
            else{
                // iPhone retina-3.5 inch(iPhone 4s)
                self.button1Height.constant = 110;
                self.button2Height.constant = 110;
                self.button3Height.constant = 110;
                
                self.quote2TopSpace.constant = 160;
                self.quote3TopSpace.constant = 280;
                self.shuffleButtonCenterY.constant = -170;
                
            }
        }
        else if ([[UIScreen mainScreen] scale] == 3.0)
        {
            //if you want to detect the iPhone 6+ only
            if([UIScreen mainScreen].bounds.size.height == 736.0){
                //iPhone retina-5.5 inch screen(iPhone 6 plus)
                self.quote1.font = [self.quote1.font fontWithSize:21];
                self.quote2.font = [self.quote2.font fontWithSize:21];
                self.quote3.font = [self.quote3.font fontWithSize:21];
                self.author1.font = [self.quote3.font fontWithSize:16];
                self.author2.font = [self.quote3.font fontWithSize:16];
                self.author3.font = [self.quote3.font fontWithSize:16];
            }
            //iPhone retina-5.5 inch screen(iPhone 6 plus)
        }
    }
}

- (void)setQuotesAndAuthors {
    // Now add the quote text to the labels. I need to add the strings from the dictionaries inside of the array
    self.quote1.adjustsFontSizeToFitWidth = YES;
    self.quote2.adjustsFontSizeToFitWidth = YES;
    self.quote3.adjustsFontSizeToFitWidth = YES;
    self.quote1.lineBreakMode = NSLineBreakByWordWrapping; // wrap to two lines
    self.quote1.numberOfLines = 0;
    self.quote2.lineBreakMode = NSLineBreakByWordWrapping; // wrap to two lines
    self.quote2.numberOfLines = 0;
    self.quote3.lineBreakMode = NSLineBreakByWordWrapping; // wrap to two lines
    self.quote3.numberOfLines = 0;
    // Now do the same thing for the author text.
    self.author1.adjustsFontSizeToFitWidth = YES;
    self.author2.adjustsFontSizeToFitWidth = YES;
    self.author3.adjustsFontSizeToFitWidth = YES;
    self.author1.lineBreakMode = NSLineBreakByWordWrapping; // wrap to two lines
    self.author1.numberOfLines = 0;
    self.author2.lineBreakMode = NSLineBreakByWordWrapping; // wrap to two lines
    self.author2.numberOfLines = 0;
    self.author3.lineBreakMode = NSLineBreakByWordWrapping; // wrap to two lines
    self.author3.numberOfLines = 0;
    
    self.quote1.text = [self.threeDict[0] objectForKey:@"quote"]; // Access first dictionary in array, get value at key "quote"
    self.quote2.text = [self.threeDict[1] objectForKey:@"quote"]; // same as above
    self.quote3.text = [self.threeDict[2] objectForKey:@"quote"]; // same as above
    
    self.author1.text = [self.threeDict[0] objectForKey:@"author"]; // Access first dictionary in array, get value at key "quote"
    self.author2.text = [self.threeDict[1] objectForKey:@"author"]; // same as above
    self.author3.text = [self.threeDict[2] objectForKey:@"author"]; // same as above
}

- (void)threeRandomQuoteDict {
    // NOTE: In our quotes database, the last dictionary entry in thearray is a filler.
    // Without it, the quotes wont shuffle right as a quote will get stuck on the bottom.
    
    if ([[MQMIAPHelper sharedInstance] productPurchased:@"com.myhkailmendoza.Improvyze.nonconsumable1"]) {
        self.threeDict = nil;
        self.threeDict = [[NSMutableArray alloc] init];
        
        // We want to make an array with quotes consisting from all three plist files...
        
        float quoteCount = [self.quotesInPlist1 count]; // Total number of quotes in quote database
        NSUInteger r = arc4random_uniform(quoteCount - 1); // Get random number between 0 and quoteCount-1
        NSDictionary *temp1 = self.quotesInPlist1[r]; // Assign the value associated with the r number to a temp dictionary
        
        quoteCount = [self.quotesInPlist2 count]; // Total number of quotes in quote database
        r = arc4random_uniform(quoteCount - 1); // Get random number between 0 and quoteCount-1
        NSDictionary *temp2 = self.quotesInPlist2[r]; // Assign the value associated with the r number to a temp dictionary
        
        quoteCount = [self.quotesInPlist3 count]; // Total number of quotes in quote database
        r = arc4random_uniform(quoteCount - 1); // Get random number between 0 and quoteCount-1
        NSDictionary *temp3 = self.quotesInPlist3[r]; // Assign the value associated with the r number to a temp dictionary
        
        [self.threeDict addObject:temp1]; // Add that dictionary to the seld.threeDict array used for labels
        [self.threeDict addObject:temp2]; // Add that dictionary to the seld.threeDict array used for labels
        [self.threeDict addObject:temp3]; // Add that dictionary to the seld.threeDict array used for labels
    } else {
        self.quotesSample = [[MQMQuotesStore sharedStore] quotesSample]; // Get the quotes from quotesStore
        NSMutableArray *quotesSampleCopy = [NSMutableArray arrayWithArray:self.quotesSample];
        self.threeDict = nil;
        self.threeDict = [[NSMutableArray alloc] init];
        
        // We want to make an array with quotes consisting from all three plist files...
        for (int i = 0; i < 3; i++) {
            float quoteCount = [quotesSampleCopy count]; // Total number of quotes in quote database
            NSUInteger r = arc4random_uniform(quoteCount - 1); // Get random number between 0 and quoteCount-1
            NSDictionary *temp = quotesSampleCopy[r]; // Assign the value associated with the r number to a temp dictionary
            [self.threeDict addObject:temp];
            [quotesSampleCopy removeObject:temp];
        }
    }
}
- (IBAction)shuffleQuotes:(id)sender {
    [self threeRandomQuoteDict];
    [self setQuotesAndAuthors];
    
    if (![[MQMIAPHelper sharedInstance] productPurchased:@"com.myhkailmendoza.Improvyze.nonconsumable1"]) {
        self.shuffleCounter++;
        
        if (self.shuffleCounter == 6) {
            self.shuffleCounter = 0;
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Want more quotes and no ads?"
                                                                message:@"Add 280+ handpicked quotations to the database and remove ads!"
                                                               delegate:self
                                                      cancelButtonTitle:@"Not right now"
                                                      otherButtonTitles:@"Yes!", nil];
            [alertView show];
        }
    }
}
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    // the user clicked Not Right Now
    if (buttonIndex == 1) {
        // do something here...
        SKProduct *product = _products[0];
        
        //NSLog(@"Buying %@...", product.productIdentifier);
        [[MQMIAPHelper sharedInstance] buyProduct:product];
        
    }
}

- (IBAction)firstQuotePressed:(id)sender {
    // Set the playViewControllers NSString quote to quote1.text and NSString author to author1.text,
    // then in viewWillAppear in pvc, set the quotation and author labels to the NSString quote and NSString author
    self.pvc = [[MQMPlayViewController alloc] init];
    self.pvc.quote = self.quote1.text;
    self.pvc.author = self.author1.text;
    
    [self.navigationController pushViewController:self.pvc animated:YES];

}

- (IBAction)secondQuotePresssed:(id)sender {
    // Set the playViewControllers NSString quote to quote1.text and NSString author to author1.text,
    // then in viewWillAppear in pvc, set the quotation and author labels to the NSString quote and NSString author

    self.pvc = [[MQMPlayViewController alloc] init];
    self.pvc.quote = self.quote2.text;
    self.pvc.author = self.author2.text;
    
    [self.navigationController pushViewController:self.pvc animated:YES];
    
}

- (IBAction)thirdQuotePressed:(id)sender {
    // Set the playViewControllers NSString quote to quote1.text and NSString author to author1.text,
    // then in viewWillAppear in pvc, set the quotation and author labels to the NSString quote and NSString author

    self.pvc = [[MQMPlayViewController alloc] init];
    self.pvc.quote = self.quote3.text;
    self.pvc.author = self.author3.text;
    
    [self.navigationController pushViewController:self.pvc animated:YES];
}

@end
