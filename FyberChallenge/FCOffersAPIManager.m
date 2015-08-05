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

static NSString *kOffersURL = @"http://api.sponsorpay.com/feed/v1/offers";

static NSString *responseSignatureKey   =   @"X-Sponsorpay-Response-Signature";

NSInteger FCMissingParametersErrorCode      =   1000;

static FCOffersAPIManager *_instance = nil;

@interface FCOffersAPIManager()

@property (nonatomic, assign) NSInteger totalPagesCount;
@property (nonatomic, assign) NSInteger currentPageNumber;
@property (nonatomic, copy) FCOffersAPIManagerCompletion completion;
@property (nonatomic, copy) FCOffersAPIManagerFailure failure;
@property (nonatomic, strong) NSMutableArray *currentOffers;

@end

@implementation FCOffersAPIManager

-(instancetype)init
{
    if (self = [super init])
    {
        _totalPagesCount = 0;
        _currentPageNumber = 1;
        
        _appID = @"";
        _apiKey = @"";
        _uid = @"";
        _ipAddr = @"";
        _locale = @"";
        _offerType = @"";
        _currentOffers = [NSMutableArray array];
    }
    return self;
}

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

-(void)fetchOffersWithOfferType:(NSString *)offerType
           withCompletion:(FCOffersAPIManagerCompletion)completion
              withFailure:(FCOffersAPIManagerFailure)failure;
{
    self.totalPagesCount = 0;
    self.currentPageNumber = 1;
    [self.currentOffers removeAllObjects];
    
    self.completion = completion;
    self.failure = failure;
    self.offerType = offerType;
    
    if ([self validParameters])
    {
        [self processNextPage];
    }
    else
    {
        NSError *error = [[NSError alloc] initWithDomain:@"FCOffersAPIManager"
                                                    code:FCMissingParametersErrorCode
                                                userInfo:@{
                                                            NSLocalizedDescriptionKey : @"Missing or invalid parameters"
                                                          }];
        if (failure)
        {
            failure(error);
        }
    }
}

-(BOOL)validParameters
{
    return  self.appID.length > 0       &&
            self.apiKey.length > 0      &&
            self.uid.length > 0         &&
            self.ipAddr.length > 0      &&
            self.locale.length > 0      &&
            self.offerType.length > 0   &&
            self.completion             &&
            self.failure;
    
    
}

-(void)processNextPage
{
    NSString *queryStr = [self buildQueryWithAppID:self.appID
                                        withApiKey:self.apiKey
                                           withUID:self.uid
                                        withIPAddr:self.ipAddr
                                        withLocale:self.locale
                                     withOfferType:self.offerType
                                    withPageNumber:@(self.currentPageNumber)
                                     withTimestamp:[[NSDate date] timeIntervalSince1970]];
    

    
    __weak __typeof(self) weakSelf = self;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:queryStr
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         __strong FCOffersAPIManager *strongSelf = weakSelf;
         NSString *responseSignature = operation.response.allHeaderFields[responseSignatureKey];
         if ([strongSelf responseIsValidWithResponseSignature:responseSignature
                                             withResponseData:responseObject
                                                   withAPIKey:strongSelf.apiKey])
         {
             NSError *error = nil;
             NSDictionary *offersDataDict = [NSJSONSerialization JSONObjectWithData: responseObject
                                                                            options: NSJSONReadingMutableContainers
                                                                              error: &error];
             if (error)
             {
                 strongSelf.failure(error);
             }
             else
             {
                 if (strongSelf.totalPagesCount <= 0)
                 {
                     strongSelf.totalPagesCount = [offersDataDict[@"pages"] integerValue];
                     strongSelf.currentPageNumber = 2;
                 }
                 else
                 {
                     strongSelf.currentPageNumber++;
                 }
                 NSArray *offers = [FCOffersParser parse:offersDataDict];
                 [strongSelf.currentOffers addObjectsFromArray:offers];
                 NSInteger remainingPages = 0;
                 if (strongSelf.totalPagesCount != 0)
                 {
                     remainingPages = strongSelf.totalPagesCount - strongSelf.currentPageNumber + 1;
                 }
                 strongSelf.completion(strongSelf.currentOffers, remainingPages);
                 if (strongSelf.currentPageNumber <= strongSelf.totalPagesCount)
                 {
                     [strongSelf processNextPage];
                 }
                 
             }
         }
         else if (self.currentPageNumber <= strongSelf.totalPagesCount || strongSelf.totalPagesCount == 0)
         {
             [strongSelf processNextPage];
         }
         else
         {
             strongSelf.completion(strongSelf.currentOffers, 0);
         }
         
     }
         failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
              __strong FCOffersAPIManager *strongSelf = weakSelf;
             strongSelf.failure(error);
     }];
}

-(NSString *)buildQueryWithAppID:(NSString *)appID
                      withApiKey:(NSString *)apiKey
                         withUID:(NSString *)uid
                      withIPAddr:(NSString *)ipAddr
                      withLocale:(NSString *)locale
                   withOfferType:(NSString *)offerTypes
                  withPageNumber:(NSNumber *)pageNumber
                   withTimestamp:(NSTimeInterval)timestamp
{
    NSString *appleIDFA = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    NSString *IDFATrackingEnabled = [[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled] ? @"true" : @"false";
    NSString *osVersion = [[UIDevice currentDevice] systemVersion];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{
                             @"appid"   :   appID,
                             @"uid"     :   uid,
                             @"ip"      :   ipAddr,
                             @"locale"  :   locale,
                             @"os_version"  :   osVersion,
                             @"timestamp"   :  [NSString stringWithFormat:@"%lu", [[NSNumber numberWithDouble:timestamp] integerValue] ],
                             @"apple_idfa"  :   appleIDFA,
                             @"apple_idfa_tracking_enabled" :   IDFATrackingEnabled,
                             @"offer_types" :   offerTypes
                             }];
    
    if (pageNumber.integerValue > 1)
    {
        [params setObject:pageNumber.stringValue forKey:@"page"];
    }
    
    
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
    NSString *fullParams = [NSString stringWithFormat:@"%@&%@", allParams, apiKey];
    NSString *paramsHash = [self sha1:fullParams];
    NSString *allParamsWithHash = [NSString stringWithFormat:@"%@&hashkey=%@", allParams, paramsHash];
    return [NSString stringWithFormat:@"%@.%@?%@", kOffersURL, @"json", allParamsWithHash];
}

-(BOOL)responseIsValidWithResponseSignature:(NSString *)responseSignature
                           withResponseData:(NSData *)responseData
                                 withAPIKey:(NSString *)apiKey
{
    NSData *apiKeyData = [apiKey dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData *data = [NSMutableData dataWithData:responseData];
    [data appendData:apiKeyData];
    
    NSString *verificationString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString *generatedHash = [self sha1:verificationString];
    
    NSLog(@"\nGENERATED HASH:%@\n\nGIVEN     HASH:%@", generatedHash, responseSignature);
    
    return [generatedHash isEqualToString:responseSignature];
}
@end
