//
//  FCOfferTableViewCell.m
//  FyberChallenge
//
//  Created by Néstor Adrián Gómez Elfi on 8/2/15.
//  Copyright (c) 2015 N&#233;stor Adri&#225;n G&#243;mez Elfi. All rights reserved.
//

#import "FCOfferTableViewCell.h"

@interface FCOfferTableViewCell()
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@end

@implementation FCOfferTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)loadThumbnailWithURL:(NSURL *)thumbnailURL
{
    if (!thumbnailURL)
    {
        return;
    }

    self.spinner.hidden = NO;
    [self.spinner startAnimating];
    __weak __typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void)
    {
        NSData *imgData = [NSData dataWithContentsOfURL:thumbnailURL];
        dispatch_async(dispatch_get_main_queue(), ^(void)
        {
            weakSelf.thumbnail.image = [UIImage imageWithData:imgData];
            [weakSelf.spinner stopAnimating];
            weakSelf.spinner.hidden = YES;
        });
    });
}

@end
