//
//  FCTimeToPayOut.m
//  FyberChallenge
//
//  Created by Néstor Adrián Gómez Elfi on 8/1/15.
//  Copyright (c) 2015 N&#233;stor Adri&#225;n G&#243;mez Elfi. All rights reserved.
//

//"time_to_payout" : {
//    "amount": 1800 ,
//    "readable": "30 minutes"
//}

#import "FCTimeToPayOut.h"

static NSString *amountKey  =   @"amount";
static NSString *readableKey  =   @"readable";

@implementation FCTimeToPayOut

-(instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super init])
    {
        _amount = dictionary[amountKey];
        _printableTime = dictionary[readableKey];
    }
    return self;
}

@end
