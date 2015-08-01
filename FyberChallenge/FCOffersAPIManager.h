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

@interface FCOffersAPIManager : NSObject

+(instancetype)sharedInstance;

-(void)queryWithUID:(NSString *)uid
         withAPIKey:(NSString *)apiKey
          withAppID:(NSString *)appID
     withCompletion:(FCOffersAPIManagerCompletion)completion
        withFailure:(FCOffersAPIManagerFailure)failure;

@end
