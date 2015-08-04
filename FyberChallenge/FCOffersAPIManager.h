//
//  FCOffersAPIManager.h
//  FyberChallenge
//
//  Created by Néstor Adrián Gómez Elfi on 7/31/15.
//  Copyright (c) 2015 N&#233;stor Adri&#225;n G&#243;mez Elfi. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^FCOffersAPIManagerCompletion)(NSArray *offers);
typedef void(^FCOffersAPIManagerFailure)(NSError *error);

extern NSInteger FCWrongRequestErrorCode;
extern NSInteger FCMissingParametersErrorCode;

@interface FCOffersAPIManager : NSObject

@property (nonatomic, strong) NSString *appID;
@property (nonatomic, strong) NSString *apiKey;
@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) NSString *ipAddr;
@property (nonatomic, strong) NSString *locale;
@property (nonatomic, strong) NSString *offerType;

+(instancetype)sharedInstance;

-(void)fetchOffersWithOfferType:(NSString *)offerType
                 withCompletion:(FCOffersAPIManagerCompletion)completion
                    withFailure:(FCOffersAPIManagerFailure)failure;

@end
