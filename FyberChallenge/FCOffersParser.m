//
//  FCOffersParser.m
//  FyberChallenge
//
//  Created by Néstor Adrián Gómez Elfi on 8/1/15.
//  Copyright (c) 2015 N&#233;stor Adri&#225;n G&#243;mez Elfi. All rights reserved.
//

#import "FCOffersParser.h"
#import "FCOffer.h"

static NSString *offersKey  =   @"offers";

@implementation FCOffersParser

+(NSArray *)parse:(NSDictionary *)data
{
    NSMutableArray *result = [NSMutableArray array];
    NSArray *offers = data[offersKey];
    for (NSDictionary *offerData in offers)
    {
        FCOffer *offer = [[FCOffer alloc] initWithDictionary:offerData];
        [result addObject: offer];
    }
    return result;
}

@end
