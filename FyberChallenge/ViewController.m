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
#import "MBProgressHUD.h"

static NSString *givenIPAddress     =   @"109.235.143.113";
static NSString *givenLocale        =   @"DE";
static NSString *givenOfferTypes    =   @"112";

static NSString *FCOfferCellIdentifier = @"cellIdentifier";

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *uidTextField;
@property (weak, nonatomic) IBOutlet UITextField *apiKeyTextField;
@property (weak, nonatomic) IBOutlet UITextField *appIDTextField;
@property (weak, nonatomic) IBOutlet UILabel *noOffersLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *offersData;
@property (weak, nonatomic) IBOutlet UILabel *recordsCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;

@end

@implementation ViewController

-(void)awakeFromNib
{
    _offersData = [NSArray array];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self updateRecordsCountWithCount:0];
}

-(IBAction)dismissKeyboardIfNeeded:(id)sender
{
    [self.apiKeyTextField resignFirstResponder];
    [self.uidTextField resignFirstResponder];
    [self.appIDTextField resignFirstResponder];
}

-(void)updateRecordsCountWithCount:(NSInteger)count
{
    [self dismissKeyboardIfNeeded:nil];
    if (count == 0)
    {
        self.recordsCountLabel.text = NSLocalizedString(@"No Offers", nil);
    }
    else
    {
        self.recordsCountLabel.text = [NSString stringWithFormat:@"%lu", count];
    }
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
    [alert show];
}

-(void)reEnableSearch
{
    self.searchButton.enabled = YES;
}

-(void)emptyResults
{
    [self updateRecordsCountWithCount:0];
    self.offersData = @[];
    [self.tableView reloadData];
}

- (IBAction)onSearchAction:(id)sender
{
    [self dismissKeyboardIfNeeded:nil];
    self.searchButton.enabled = NO;
    [self emptyResults];
    __block MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = NSLocalizedString(@"Getting offers", nil);
    
    __weak __typeof(self) weakSelf = self;
    [FCOffersAPIManager sharedInstance].uid = self.uidTextField.text;
    [FCOffersAPIManager sharedInstance].apiKey = self.apiKeyTextField.text;
    [FCOffersAPIManager sharedInstance].appID = self.appIDTextField.text;
    [FCOffersAPIManager sharedInstance].ipAddr = givenIPAddress;
    [FCOffersAPIManager sharedInstance].locale = givenLocale;
    [[FCOffersAPIManager sharedInstance] fetchOffersWithOfferType:givenOfferTypes
                                                   withCompletion:^(NSArray *offers, NSInteger remainingPageCount)
     {
         __strong ViewController *strongSelf = weakSelf;
         strongSelf.offersData = offers;
         [strongSelf.tableView reloadData];
         [strongSelf updateRecordsCountWithCount:offers.count];
         if (remainingPageCount == 0)
         {
             strongSelf.searchButton.enabled = YES;
             [hud hide:YES];
         }
     }
                                                      withFailure:^(NSError *error)
     {
         __strong ViewController *strongSelf = weakSelf;
         [strongSelf updateRecordsCountWithCount:0];
         strongSelf.offersData = @[];
         [strongSelf.tableView reloadData];
         [strongSelf displayErrorWithError:error];
         strongSelf.searchButton.enabled = YES;
         [hud hide:YES];
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

@end
