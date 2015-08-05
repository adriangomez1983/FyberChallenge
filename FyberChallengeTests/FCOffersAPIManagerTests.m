//
//  FCOffersAPIManagerTests.m
//  FyberChallenge
//
//  Created by Néstor Adrián Gómez Elfi on 8/5/15.
//  Copyright (c) 2015 N&#233;stor Adri&#225;n G&#243;mez Elfi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "FCOffersAPIManager.h"
#import "AFNetworking.h"
#import "FCOffer.h"

static NSString *initialQuery = @"http://api.sponsorpay.com/feed/v1/offers.json?appid=2070&apple_idfa=A04B2D49-1004-4792-8729-9981364A4E14&apple_idfa_tracking_enabled=true&ip=109.235.143.113&locale=DE&offer_types=112&os_version=8.4&page=5&timestamp=1438777258&uid=spiderman&hashkey=6e9c7c1837e5650718b18d8013f19811bb7a24a9";

static NSString *defaultAPIKey = @"1c915e3b5d42d05136185030892fbb846c278927";
static NSString *defaultUID = @"spiderman";
static NSString *defaultAppID = @"2070";
static NSString *defaultIPAddr = @"109.235.143.113";
static NSString *defaultOfferType = @"112";
static NSString *defaultLocale = @"DE";

@interface FCOffersAPIManager (test)
//Exposing some methods for testing purposes
-(NSString *)buildQueryWithAppID:(NSString *)appID
                      withApiKey:(NSString *)apiKey
                         withUID:(NSString *)uid
                      withIPAddr:(NSString *)ipAddr
                      withLocale:(NSString *)locale
                   withOfferType:(NSString *)offerTypes
                  withPageNumber:(NSNumber *)pageNumber
                   withTimestamp:(NSTimeInterval)timestamp;

-(BOOL)responseIsValidWithResponseSignature:(NSString *)responseSignature
                           withResponseData:(NSData *)responseData
                                 withAPIKey:(NSString *)apiKey;

-(NSString*) sha1:(NSString*)input;

@end

@interface FCOffersAPIManagerTests : XCTestCase

@end

@implementation FCOffersAPIManagerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(NSString *)defaultResponseSignature
{
    NSData *jsonData = [[NSData alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"offers" ofType:@"json"]];
    NSData *apiKeyData = [defaultAPIKey dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData *data = [NSMutableData dataWithData:jsonData];
    [data appendData:apiKeyData];
    NSString *verificationString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return [[FCOffersAPIManager sharedInstance] sha1:verificationString];
}

-(NSDictionary *)pageJSONData
{
    NSData *data = [[NSData alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"offers" ofType:@"json"]];
    NSError *error = nil;
    NSDictionary *offersDict = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    return offersDict;
}

-(void)testMissingPatams
{
    [[FCOffersAPIManager sharedInstance] fetchOffersWithOfferType:nil
                                                   withCompletion:nil
                                                      withFailure:^(NSError *error)
    {
        XCTAssert(error.code == FCMissingParametersErrorCode, @"Should be Missing parameters error code");
    }];
}

-(void)testbuildQueryString
{
    NSString *queryString = [[FCOffersAPIManager sharedInstance] buildQueryWithAppID:defaultAppID
                                                                          withApiKey:defaultAPIKey
                                                                             withUID:defaultUID
                                                                          withIPAddr:defaultIPAddr
                                                                          withLocale:defaultLocale
                                                                       withOfferType:defaultOfferType
                                                                      withPageNumber:@(5)
                                                                       withTimestamp:1438777258];
    XCTAssert([queryString isEqualToString:initialQuery], @"Should be equal to initial query string");
}

-(void)testValidResponseSignature
{
    NSData *jsonData = [[NSData alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"offers" ofType:@"json"]];
    BOOL result = [[FCOffersAPIManager sharedInstance] responseIsValidWithResponseSignature:[self defaultResponseSignature]
                                                                           withResponseData:jsonData
                                                                                 withAPIKey:defaultAPIKey];
    
    XCTAssertTrue(result, @"Should be YES");
}

-(AFHTTPRequestOperation *)mockRequestOperation
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"www.dummyURL.com"]];
    AFHTTPRequestOperation *requestoperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:@"www.dummyURL.com"] statusCode:200 HTTPVersion:@"2.0" headerFields:@{@"X-Sponsorpay-Response-Signature" : [self defaultResponseSignature]}];
    
    id mockRequestOperation = [OCMockObject partialMockForObject:requestoperation];
    [[[mockRequestOperation stub] andReturn:response] response];
    
    return mockRequestOperation;
}

-(void)mockRequestOperationManager
{
    id mockRequestOperationManager  = [OCMockObject partialMockForObject:[AFHTTPRequestOperationManager manager]];
    
    [[[mockRequestOperationManager stub] andDo:^(NSInvocation *invocation) {
        void (^success)(AFHTTPRequestOperation *operation, id responseObject);
        [invocation getArgument:&success atIndex:4];
        
        AFHTTPRequestOperation *requestoperation = [self mockRequestOperation];
        NSData *jsonData = [[NSData alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"offers" ofType:@"json"]];

        success(requestoperation, jsonData);
        
    }] GET:[OCMArg any] parameters:[OCMArg any] success:[OCMArg any] failure:[OCMArg any]];
    
    id mockManagerClass = [OCMockObject mockForClass:[AFHTTPRequestOperationManager class]];
    [[[mockManagerClass stub] andReturn:mockRequestOperationManager] manager];
}

-(void)testFetchOffersSuccess
{
    [self mockRequestOperationManager];
    
    [FCOffersAPIManager sharedInstance].uid = defaultUID;
    [FCOffersAPIManager sharedInstance].apiKey = defaultAPIKey;
    [FCOffersAPIManager sharedInstance].appID = defaultAppID;
    [FCOffersAPIManager sharedInstance].ipAddr = defaultIPAddr;
    [FCOffersAPIManager sharedInstance].locale = defaultLocale;
    [[FCOffersAPIManager sharedInstance] fetchOffersWithOfferType:defaultOfferType
                                                   withCompletion:^(NSArray *offers, NSInteger remainingPagesCount)
    {
        XCTAssert(offers.count == 30, @"Should be 30 offers");
        XCTAssert(remainingPagesCount == 0, @"Should be 0 remaining pages");
        for (NSObject *obj in offers)
        {
            XCTAssert([obj isKindOfClass:[FCOffer class]], @"Should be an FCOffer class instance");
        }
    }
                                                      withFailure:^(NSError *error) {
                                                          
                                                     }];
}
@end
