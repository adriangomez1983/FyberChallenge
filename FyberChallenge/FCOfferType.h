//
//  FCOfferType.h
//  FyberChallenge
//
//  Created by Néstor Adrián Gómez Elfi on 8/1/15.
//  Copyright (c) 2015 N&#233;stor Adri&#225;n G&#243;mez Elfi. All rights reserved.
//

#import <Foundation/Foundation.h>

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
