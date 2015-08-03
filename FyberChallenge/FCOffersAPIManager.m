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

static NSString *responseSignatureKey   =   @"X-Sponsorpay-Response-Signature";

NSInteger FCWrongRequestErrorCode    =   1000;

static FCOffersAPIManager *_instance = nil;

@interface FCOffersAPIManager()

@end

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
    
    CC_SHA1(data.bytes, (CC_LONG)data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
    
}

-(void)queryWithUID:(NSString *)uid
         withAPIKey:(NSString *)apiKey
          withAppID:(NSString *)appID
      withIPAddress:(NSString *)ipAddr
         withLocale:(NSString *)locale
      withOfferType:(NSString *)offerType
     withCompletion:(FCOffersAPIManagerCompletion)completion
        withFailure:(FCOffersAPIManagerFailure)failure
{
    NSString *allParams = [self buildParamsWithAppID:appID
                                          withApiKey:apiKey
                                             withUID:uid
                                          withIPAddr:ipAddr
                                          withLocale:locale
                                       withOfferType:offerType];

    NSString *fullParams = [NSString stringWithFormat:@"%@&%@", allParams, apiKey];
    NSString *paramsHash = [self sha1:fullParams];
    NSString *allParamsWithHash = [NSString stringWithFormat:@"%@&hashkey=%@", allParams, paramsHash];
    NSString *queryStr = [NSString stringWithFormat:@"http://api.sponsorpay.com/feed/v1/offers.%@?%@", @"json", allParamsWithHash];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:queryStr
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        if ([self responseIsValidWithResponseSignature:operation.response.allHeaderFields[responseSignatureKey]
                                      withResponseData:responseObject
                                            withAPIKey:apiKey])
        {
            NSError *error = nil;
            NSDictionary *offersDataDict = [NSJSONSerialization JSONObjectWithData: responseObject
                                                                           options: NSJSONReadingMutableContainers
                                                                             error: &error];
            if (error)
            {
                if (failure)
                {
                    failure(error);
                }
            }
            else
            {
                NSArray *offers = [FCOffersParser parse:offersDataDict];
                if (completion)
                {
                    completion(offers, 0);
                }
            }
        }
        else if (failure)
        {
            NSError *error = [[NSError alloc] initWithDomain:@"FCOffersAPIManager"
                                                        code:FCWrongRequestErrorCode
                                                    userInfo:@{NSLocalizedDescriptionKey : @"Wrong request"}];
            failure(error);
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

-(NSString *)buildParamsWithAppID:(NSString *)appID
                       withApiKey:(NSString *)apiKey
                          withUID:(NSString *)uid
                       withIPAddr:(NSString *)ipAddr
                       withLocale:(NSString *)locale
                    withOfferType:(NSString *)offerTypes
{
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
    
    return [query componentsJoinedByString:@"&"];
}

-(BOOL)responseIsValidWithResponseSignature:(NSString *)responseSignature withResponseData:(NSData *)responseData withAPIKey:(NSString *)apiKey
{
    NSData *apiKeyData = [apiKey dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData *data = [NSMutableData dataWithData:responseData];
    [data appendData:apiKeyData];
    
    NSString *verificationString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString *generatedHash = [self sha1:verificationString];
    
    NSLog(@"GENERATED HASH:%@\n\nGIVEN HASH:%@", generatedHash, responseSignature);
    
    return [generatedHash isEqualToString:responseSignature];
}
@end
