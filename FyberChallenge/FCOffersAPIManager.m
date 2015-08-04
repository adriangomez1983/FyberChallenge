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

NSInteger FCWrongRequestErrorCode           =   1000;
NSInteger FCMissingParametersErrorCode      =   1001;

static FCOffersAPIManager *_instance = nil;

@interface FCOffersAPIManager()

@property (nonatomic, assign) NSInteger remainingPages;
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
        _remainingPages = 0;
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
    self.remainingPages = 0;
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
    NSString *allParams = [self buildParamsWithAppID:self.appID
                                          withApiKey:self.apiKey
                                             withUID:self.uid
                                          withIPAddr:self.ipAddr
                                          withLocale:self.locale
                                       withOfferType:self.offerType
                                      withPageNumber:@(self.currentPageNumber)];
    
    NSString *fullParams = [NSString stringWithFormat:@"%@&%@", allParams, self.apiKey];
    NSString *paramsHash = [self sha1:fullParams];
    NSString *allParamsWithHash = [NSString stringWithFormat:@"%@&hashkey=%@", allParams, paramsHash];
    NSString *queryStr = [NSString stringWithFormat:@"http://api.sponsorpay.com/feed/v1/offers.%@?%@", @"json", allParamsWithHash];
    
    __weak __typeof(self) weakSelf = self;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:queryStr
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         __strong FCOffersAPIManager *strongSelf = weakSelf;
         if ([strongSelf responseIsValidWithResponseSignature:operation.response.allHeaderFields[responseSignatureKey]
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
                 if (self.remainingPages <= 0)
                 {
                     self.remainingPages = [offersDataDict[@"pages"] integerValue];
                     self.currentPageNumber = 2;
                 }
                 else
                 {
                     self.currentPageNumber++;
                 }
                 NSArray *offers = [FCOffersParser parse:offersDataDict];
                 [strongSelf.currentOffers addObjectsFromArray:offers];
                 strongSelf.completion(strongSelf.currentOffers);
                 if (self.currentPageNumber < self.remainingPages)
                 {
                     [strongSelf processNextPage];
                 }
                 
             }
         }
         else if (self.currentPageNumber < self.remainingPages)
         {
             [strongSelf processNextPage];
         }
         else
         {
             NSError *error = [[NSError alloc] initWithDomain:@"FCOffersAPIManager"
                                                         code:FCWrongRequestErrorCode
                                                     userInfo:@{NSLocalizedDescriptionKey : @"Wrong request"}];
             strongSelf.failure(error);
         }
         
     }
         failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
              __strong FCOffersAPIManager *strongSelf = weakSelf;
             strongSelf.failure(error);
     }];
}

-(NSString *)buildParamsWithAppID:(NSString *)appID
                       withApiKey:(NSString *)apiKey
                          withUID:(NSString *)uid
                       withIPAddr:(NSString *)ipAddr
                       withLocale:(NSString *)locale
                    withOfferType:(NSString *)offerTypes
                   withPageNumber:(NSNumber *)pageNumber
{
    NSString *appleIDFA = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    NSString *IDFATrackingEnabled = [[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled] ? @"true" : @"false";
    NSString *osVersion = [[UIDevice currentDevice] systemVersion];
    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{
                             @"appid"   :   appID,
                             @"uid"     :   uid,
                             @"ip"      :   ipAddr,
                             @"locale"  :   locale,
                             @"os_version"  :   osVersion,
                             @"timestamp"   :  [NSString stringWithFormat:@"%lu", [[NSNumber numberWithDouble:timeStamp] integerValue] ],
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
    
    return [query componentsJoinedByString:@"&"];
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
    
    NSLog(@"GENERATED HASH:%@\n\nGIVEN HASH:%@", generatedHash, responseSignature);
    
    return [generatedHash isEqualToString:responseSignature];
}
@end
