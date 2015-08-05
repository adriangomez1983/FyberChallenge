//
//  FCOfferType.m
//  FyberChallenge
//
//  Created by Néstor Adrián Gómez Elfi on 8/1/15.
//  Copyright (c) 2015 N&#233;stor Adri&#225;n G&#243;mez Elfi. All rights reserved.
//

#import "FCOfferType.h"

static NSString *offerTypeIDKey     =   @"offer_type_id";
static NSString *readableKey        =   @"readable";

@implementation FCOfferType

-(instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super init])
    {
        NSNumber *numberID = [NSNumber numberWithInteger:[dictionary[offerTypeIDKey] integerValue]];
        _identifier = [self extractOfferTypeIdentifierWithData:numberID];
        _printableName = dictionary[readableKey];
    }
    return self;
}

-(FCOfferIdentifier)extractOfferTypeIdentifierWithData:(NSNumber *)number
{
    FCOfferIdentifier result = FCUnknownOfferType;
    switch (number.intValue) {
        case FCMobileOfferType:
            result = FCMobileOfferType;
            break;
        case FCDownloadOfferType:
            result = FCDownloadOfferType;
            break;
        case FCTrialOfferType:
            result = FCTrialOfferType;
            break;
        case FCSaleOfferType:
            result = FCSaleOfferType;
            break;
        case FCRegistrationForInfoRequestOfferType:
            result = FCRegistrationForInfoRequestOfferType;
            break;
        case FCRegistrationOfferType:
            result = FCRegistrationOfferType;
            break;
        case FCNonGamblingGamingOfferType:
            result = FCNonGamblingGamingOfferType;
            break;
        case FCGamblingGamingOfferType:
            result = FCGamblingGamingOfferType;
            break;
        case FCRegistrationForDataGenerationOfferType:
            result = FCRegistrationForDataGenerationOfferType;
            break;
        case FCGamesOfferType:
            result = FCGamesOfferType;
            break;
        case FCSurveysOfferType:
            result = FCSurveysOfferType;
            break;
        case FCRegistrationForDatingOfferType:
            result = FCRegistrationForDatingOfferType;
            break;
        case FCFreeOfferType:
            result = FCFreeOfferType;
            break;
        case FCVideoOfferType:
            result = FCVideoOfferType;
            break;
        default:
            break;
    }
    return result;
}

@end
