//
//  ViewController.m
//  FyberChallenge
//
//  Created by Néstor Adrián Gómez Elfi on 7/31/15.
//  Copyright (c) 2015 Néstor Adrián Gómez Elfi. All rights reserved.
//

#import "ViewController.h"
#import "FCOffersAPIManager.h"

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate>
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
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onSearchAction:(id)sender
{
    NSLog(@"Search action");
    
    [[FCOffersAPIManager sharedInstance] queryWithUID:self.uidTextField.text
                                           withAPIKey:self.apiKeyTextField.text
                                            withAppID:self.appIDTextField.text
                                       withCompletion:^(NSArray *offers)
    {
        self.offersData = offers;
        [self.tableView reloadData];
    }
                                          withFailure:^(NSError *error)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR", nil)
                                                        message:error.localizedDescription
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.offersData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] init];
    }
    return cell;
}

#pragma mark UITableViewDelegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Row %lu seleced", indexPath.row);
}



@end
