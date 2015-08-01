//
//  FCOffer.h
//  FyberChallenge
//
//  Created by Néstor Adrián Gómez Elfi on 8/1/15.
//  Copyright (c) 2015 N&#233;stor Adri&#225;n G&#243;mez Elfi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FCTimeToPayOut.h"


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



@interface FCOffer : NSObject
@property (nonatomic, strong, readonly) NSString *title;
@property (nonatomic, strong, readonly) NSNumber *identifier;
@property (nonatomic, strong, readonly) NSString *teaser;
@property (nonatomic, strong, readonly) NSString *requiredActions;
@property (nonatomic, strong, readonly) NSString *link;
@property (nonatomic, strong, readonly) NSArray *types;
@property (nonatomic, strong, readonly) NSString *lowersThumbnailLink;
@property (nonatomic, strong, readonly) NSString *hiresThumbnailLink;
@property (nonatomic, strong, readonly) NSNumber *payout;
@property (nonatomic, strong, readonly) FCTimeToPayOut *timeToPayout;

-(instancetype)initWithDictionary:(NSDictionary *)dictionary;
@end
