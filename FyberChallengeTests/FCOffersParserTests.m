//
//  FCOffersParserTests.m
//  FyberChallenge
//
//  Created by Néstor Adrián Gómez Elfi on 8/5/15.
//  Copyright (c) 2015 N&#233;stor Adri&#225;n G&#243;mez Elfi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "FCOffersParser.h"
#import "FCOffer.h"
@interface FCOffersParserTests : XCTestCase

@end

@implementation FCOffersParserTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(NSDictionary *)pageJSONData
{
    NSData *data = [[NSData alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"offers" ofType:@"json"]];
    NSError *error = nil;
    NSDictionary *offersDict = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    return offersDict;
}

-(void)testParseSuccessCount
{
    NSArray *offers = [FCOffersParser parse:[self pageJSONData]];
    XCTAssert(offers.count == 30, @"Should be 30 offers");
}

-(void)testParseSuccessType
{
    NSArray *offers = [FCOffersParser parse:[self pageJSONData]];
    for (NSObject *obj in offers)
    {
        XCTAssertEqual([obj class], [FCOffer class], @"Should be of FCOffer class");
    }
}

-(void)testParseFailedWrongInput
{
    NSArray *offers = [FCOffersParser parse:@{@"wrong_offerKey" : @"wrong_offerValue"}];
    XCTAssert(offers.count == 0, @"Should be 0 offers");
}

-(void)testParseFailedEmptyInput
{
    NSArray *offers = [FCOffersParser parse:@{}];
    XCTAssert(offers.count == 0, @"Should be 0 offers");
}

-(void)testParseFailedNoInput
{
    NSArray *offers = [FCOffersParser parse:nil];
    XCTAssert(offers.count == 0, @"Should be 0 offers");
}
@end
