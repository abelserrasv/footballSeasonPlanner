//
//  matchesTests.m
//  aufgabeSpielplan
//
//  Created by Abel Serra on 17.09.16.
//  Copyright © 2016 Abel Serra. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SPMatch.h"

@interface matchesTests : XCTestCase

@end

@implementation matchesTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testGetStringForMatchWithNilBalues {
    SPMatch *testMatch = [[SPMatch alloc] initWithLocalTeam:nil visitorTeam:nil andDateOfTheMatch:nil];
    NSString *matchString = [testMatch getStringForMatch];
    XCTAssertEqualObjects(matchString, @"");
}

@end
