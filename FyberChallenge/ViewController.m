//
//  ViewController.m
//  FyberChallenge
//
//  Created by Néstor Adrián Gómez Elfi on 7/31/15.
//  Copyright (c) 2015 Néstor Adrián Gómez Elfi. All rights reserved.
//

#import "ViewController.h"
#import "FCOffersAPIManager.h"
#import "FCOfferTableViewCell.h"
#import "FCOffer.h"

static NSString *givenIPAddress     =   @"109.235.143.113";
static NSString *givenLocale        =   @"DE";
static NSString *givenOfferTypes    =   @"112";

static NSString *FCOfferCellIdentifier = @"cellIdentifier";
static NSUInteger kRetryIndex = 1;

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *uidTextField;
@property (weak, nonatomic) IBOutlet UITextField *apiKeyTextField;
@property (weak, nonatomic) IBOutlet UITextField *appIDTextField;
@property (weak, nonatomic) IBOutlet UILabel *noOffersLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *offersData;

@end

@implementation ViewController

-(void)awakeFromNib
{
    _offersData = [NSArray array];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.noOffersLabel.hidden = YES;
    self.tableView.hidden = NO;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)displayErrorWithError:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR", nil)
                                                    message:error.localizedDescription
                                                   delegate:nil
                                          cancelButtonTitle: NSLocalizedString(@"OK", nil)
                                          otherButtonTitles: nil];
    if (error.code == FCWrongRequestErrorCode)
    {
        
        alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR", nil)
                                           message:NSLocalizedString(@"Wrong request. Retry please.", nil)
                                          delegate:self
                                 cancelButtonTitle: NSLocalizedString(@"Cancel", nil)
                                 otherButtonTitles: NSLocalizedString(@"Retry", nil), nil];
    }
    
    [alert show];
}

- (IBAction)onSearchAction:(id)sender
{
    NSLog(@"Search action");
    
    [[FCOffersAPIManager sharedInstance] queryWithUID:self.uidTextField.text
                                           withAPIKey:self.apiKeyTextField.text
                                            withAppID:self.appIDTextField.text
                                        withIPAddress:givenIPAddress
                                           withLocale:givenLocale
                                        withOfferType:givenOfferTypes
                                       withCompletion:^(NSArray *offers, NSUInteger remainingPages)
    {
        self.offersData = offers;
        [self.tableView reloadData];
    }
                                          withFailure:^(NSError *error)
    {
        [self displayErrorWithError:error];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.offersData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FCOfferTableViewCell *cell = (FCOfferTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:FCOfferCellIdentifier forIndexPath:indexPath];
    
    FCOffer *offer = (FCOffer *)[self.offersData objectAtIndex:indexPath.row];
    cell.title.text = offer.title;
    cell.teaser.text = offer.teaser;
    cell.payout.text = [offer.payout stringValue];
    [cell loadThumbnailWithURL:[NSURL URLWithString:offer.hiresThumbnailLink]];
    
    if (!cell)
    {
        return [[UITableViewCell alloc] init];
    }
    return cell;
}

#pragma mark UITableViewDelegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Row %lu seleced", indexPath.row);
}


#pragma mark - UIAlertViewDelegate methods
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == kRetryIndex)
    {
        [[FCOffersAPIManager sharedInstance] queryWithUID:self.uidTextField.text
                                               withAPIKey:self.apiKeyTextField.text
                                                withAppID:self.appIDTextField.text
                                            withIPAddress:givenIPAddress
                                               withLocale:givenLocale
                                            withOfferType:givenOfferTypes
                                           withCompletion:^(NSArray *offers, NSUInteger remainingPages)
         {
             self.offersData = offers;
             [self.tableView reloadData];
         }
                                              withFailure:^(NSError *error)
         {
             [self displayErrorWithError:error];
         }];
    }
}

@end
