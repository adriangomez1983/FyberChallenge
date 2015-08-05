//
//  FCOffer.h
//  FyberChallenge
//
//  Created by Néstor Adrián Gómez Elfi on 8/1/15.
//  Copyright (c) 2015 N&#233;stor Adri&#225;n G&#243;mez Elfi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FCTimeToPayOut.h"

@interface FCOffer : NSObject
@property (nonatomic, strong, readonly) NSString *title;
@property (nonatomic, strong, readonly) NSNumber *identifier;
@property (nonatomic, strong, readonly) NSString *teaser;
@property (nonatomic, strong, readonly) NSString *requiredActions;
@property (nonatomic, strong, readonly) NSString *link;
@property (nonatomic, strong, readonly) NSArray *types;
@property (nonatomic, strong, readonly) NSString *lowersThumbnailLink;
@property (nonatomic, strong, readonly) NSString *hiresThumbnailLink;
@property (nonatomic, strong, readonly) NSNumber *payout;
@property (nonatomic, strong, readonly) FCTimeToPayOut *timeToPayout;
@property (nonatomic, strong, readonly) NSString *storeID;

-(instancetype)initWithDictionary:(NSDictionary *)dictionary;
@end
