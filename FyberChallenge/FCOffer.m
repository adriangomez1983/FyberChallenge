//
//  FCOffer.m
//  FyberChallenge
//
//  Created by Néstor Adrián Gómez Elfi on 8/1/15.
//  Copyright (c) 2015 N&#233;stor Adri&#225;n G&#243;mez Elfi. All rights reserved.
//

#import "FCOffer.h"
#import "FCOfferType.h"
//{
//    "title": "Tap  Fish",
//    "offer_id": 13554,
//    "teaser": "Download and START" ,
//    "required_actions": "Download and START",
//    "link": "http://iframe.sponsorpay.com/mbrowser?appid=157&lpid=11387&uid=player1",
//    "offer_types" : [
//                     {
//                         "offer_type_id": 101,
//                         "readable": "Download"
//                     },
//                     {
//                         "offer_type_id": 112,
//                         "readable": "Free"
//                     }
//                     ] ,
//    "thumbnail" : {
//        "lowres": "http://cdn.sponsorpay.com/assets/1808/icon175x175-2_square_60.png",
//        "hires": "http://cdn.sponsorpay.com/assets/1808/icon175x175-2_square_175.png"
//    },
//    "payout": 90,
//    "time_to_payout" : {
//        "amount": 1800 ,
//        "readable": "30 minutes"
//    }
//}
static NSString *titleKey               =   @"title";
static NSString *idKey                  =   @"offer_id";
static NSString *teaserKey              =   @"teaser";
static NSString *requiredActionsKey     =   @"required_actions";
static NSString *linkKey                =   @"link";
static NSString *offerTypesKey          =   @"offer_types";
static NSString *thumbnailKey           =   @"thumbnail";
static NSString *lowresthumbnailKey     =   @"lowres";
static NSString *hiresthumbnailKey      =   @"hires";
static NSString *payoutKey              =   @"payout";
static NSString *timeToPayOutKey        =   @"time_to_payout";

@implementation FCOffer

-(instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super init])
    {
        _title      = dictionary[titleKey] ? : @"";
        _identifier = [NSNumber numberWithInteger:[dictionary[idKey] integerValue]];
        _teaser     = dictionary[teaserKey] ? : @"";
        _requiredActions     = dictionary[requiredActionsKey] ? : @"";
        _link = dictionary[linkKey] ? : @"";
        _types = [self processOfferTypesWithDictionary:dictionary];
        NSDictionary *thumbnails = dictionary[thumbnailKey];
        _lowersThumbnailLink = thumbnails[lowresthumbnailKey] ? : @"";
        _hiresThumbnailLink = thumbnails[hiresthumbnailKey] ? : @"";
        _payout = [NSNumber numberWithInteger:[dictionary[payoutKey] integerValue]];
        _timeToPayout = [[FCTimeToPayOut alloc] initWithDictionary:dictionary[timeToPayOutKey]];
    }
    return self;
}

-(NSArray *)processOfferTypesWithDictionary:(NSDictionary *)dictionary
{
    NSMutableArray *result = [NSMutableArray array];
    NSArray *data = dictionary[offerTypesKey];
    for (NSDictionary *offerData in data)
    {
        FCOfferType *offerType = [[FCOfferType alloc] initWithDictionary:offerData];
        [result addObject:offerType];
    }
    
    return result;
}

@end
