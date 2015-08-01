//
//  FCOffersAPIManager.m
//  FyberChallenge
//
//  Created by Néstor Adrián Gómez Elfi on 7/31/15.
//  Copyright (c) 2015 N&#233;stor Adri&#225;n G&#243;mez Elfi. All rights reserved.
//

#import "FCOffersAPIManager.h"
#import "AFNetworking.h"
#import <AdSupport/ASIdentifierManager.h>
#include <CommonCrypto/CommonDigest.h>
#import "FCOffersParser.h"

static FCOffersAPIManager *_instance = nil;

@implementation FCOffersAPIManager

+(instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[FCOffersAPIManager alloc] init];
    });
    return _instance;
}

-(NSString*) sha1:(NSString*)input
{
    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:input.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
    
}

-(void)queryWithUID:(NSString *)uid
         withAPIKey:(NSString *)apiKey
          withAppID:(NSString *)appID
     withCompletion:(FCOffersAPIManagerCompletion)completion
        withFailure:(FCOffersAPIManagerFailure)failure
{
    NSString *ipAddr =  @"109.235.143.113";
    NSString *locale = @"DE";
    NSString *offerTypes = @"112";
    NSString *appleIDFA = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    NSString *IDFATrackingEnabled = [[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled] ? @"true" : @"false";
    NSString *osVersion = [[UIDevice currentDevice] systemVersion];
    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    
    NSDictionary *params = @{
                             @"appid"   :   appID,
                             @"uid"     :   uid,
                             @"ip"      :   ipAddr,
                             @"locale"  :   locale,
                             @"os_version"  :   osVersion,
                             @"timestamp"   :  [NSString stringWithFormat:@"%lu", [[NSNumber numberWithDouble:timeStamp] integerValue] ],
                             @"apple_idfa"  :   appleIDFA,
                             @"apple_idfa_tracking_enabled" :   IDFATrackingEnabled,
                             @"offer_types" :   offerTypes
                             };
    
    
    NSArray *sortedParamNames = [params.allKeys sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2)
    {
        return [obj1 caseInsensitiveCompare:obj2];
    }];
    
    NSMutableArray *query = [NSMutableArray array];
    for (NSString *paramName in sortedParamNames)
    {
        NSString *paramValue = [NSString stringWithFormat:@"%@=%@", paramName, params[paramName]];
        [query addObject:paramValue];
    }
    
    NSString *allParams = [query componentsJoinedByString:@"&"];
    NSString *hashKey = [self sha1:[NSString stringWithFormat:@"%@&%@", allParams, apiKey]];
    NSString *allParamsWithHash = [NSString stringWithFormat:@"%@&hashkey=%@", allParams, hashKey];
    
    NSString *queryStr = [NSString stringWithFormat:@"http://api.sponsorpay.com/feed/v1/offers.%@?%@", @"json", allParamsWithHash];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:queryStr
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        if ([responseObject isKindOfClass:[NSDictionary class]])
        {
            NSDictionary *offersDataDict = (NSDictionary *)responseObject;
            NSArray *offers = [FCOffersParser parse:offersDataDict];
            if (completion)
            {
                completion(offers);
            }
        }
    }
         failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        if (failure)
        {
            failure(error);
        }
    }];
}
@end
