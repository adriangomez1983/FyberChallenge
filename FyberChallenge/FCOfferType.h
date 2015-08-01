//
//  FCOfferType.h
//  FyberChallenge
//
//  Created by Néstor Adrián Gómez Elfi on 8/1/15.
//  Copyright (c) 2015 N&#233;stor Adri&#225;n G&#243;mez Elfi. All rights reserved.
//

#import <Foundation/Foundation.h>

//{
//    "offer_type_id": 101,
//    "readable": "Download"
//}

//100	Mobile	Mobile subscription offers
//101	Download	Download offers
//102	Trial	Trial offers
//103	Sale	Shopping offers
//104	Registration	Information request offers
//105	Registration	Registration offers
//106	Games	Gaming offers
//107	Games	Gambling offers
//108	Registration	Data generation offers
//109	Games	Games offers
//110	Surveys	Survey offers
//111	Registration	Dating offers
//112	Free	Free offers
//113 Video

typedef enum : NSUInteger {
    FCMobileOfferType                           = 100,
    FCDownloadOfferType,
    FCTrialOfferType,
    FCSaleOfferType,
    FCRegistrationForInfoRequestOfferType,
    FCRegistrationOfferType,
    FCNonGamblingGamingOfferType,
    FCGamblingGamingOfferType,
    FCRegistrationForDataGenerationOfferType,
    FCGamesOfferType,
    FCSurveysOfferType,
    FCRegistrationForDatingOfferType,
    FCFreeOfferType,
    FCVideoOfferType,
    FCUnknownOfferType,
} FCOfferIdentifier;

@interface FCOfferType : NSObject
@property (nonatomic, assign, readonly) FCOfferIdentifier identifier;
@property (nonatomic, strong, readonly) NSNumber *printableName;

-(instancetype)initWithDictionary:(NSDictionary *)dictionary;
@end
