//
//  FCOffersAPIManager.h
//  FyberChallenge
//
//  Created by Néstor Adrián Gómez Elfi on 7/31/15.
//  Copyright (c) 2015 N&#233;stor Adri&#225;n G&#243;mez Elfi. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^FCOffersAPIManagerCompletion)(NSArray *offers, NSUInteger remainingPages);
typedef void(^FCOffersAPIManagerFailure)(NSError *error);

extern NSInteger FCWrongRequestErrorCode;

@interface FCOffersAPIManager : NSObject

+(instancetype)sharedInstance;

-(void)queryWithUID:(NSString *)uid
         withAPIKey:(NSString *)apiKey
          withAppID:(NSString *)appID
      withIPAddress:(NSString *)ipAddr
         withLocale:(NSString *)locale
      withOfferType:(NSString *)offerType
     withCompletion:(FCOffersAPIManagerCompletion)completion
        withFailure:(FCOffersAPIManagerFailure)failure;

@end
