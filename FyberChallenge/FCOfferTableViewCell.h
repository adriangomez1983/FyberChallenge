//
//  FCOfferTableViewCell.h
//  FyberChallenge
//
//  Created by Néstor Adrián Gómez Elfi on 8/2/15.
//  Copyright (c) 2015 N&#233;stor Adri&#225;n G&#243;mez Elfi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FCOfferTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *thumbnail;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *teaser;
@property (weak, nonatomic) IBOutlet UILabel *payout;

-(void)loadThumbnailWithURL:(NSURL *)thumbnailURL;

@end
