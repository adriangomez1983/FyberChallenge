//
//  FCTimeToPayOut.h
//  FyberChallenge
//
//  Created by Néstor Adrián Gómez Elfi on 8/1/15.
//  Copyright (c) 2015 N&#233;stor Adri&#225;n G&#243;mez Elfi. All rights reserved.
//

#import <Foundation/Foundation.h>

//"time_to_payout" : {
//    "amount": 1800 ,
//    "readable": "30 minutes"
//}

@interface FCTimeToPayOut : NSObject
@property (nonatomic, strong, readonly) NSNumber *amount;
@property (nonatomic, strong, readonly) NSString *printableTime;

-(instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
