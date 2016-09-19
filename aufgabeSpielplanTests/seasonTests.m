//
//  aufgabeSpielplanTests.m
//  aufgabeSpielplanTests
//
//  Created by Abel Serra on 16.09.16.
//  Copyright © 2016 Abel Serra. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SPSeason.h"

@interface seasonTests : XCTestCase

@property SPSeason *testSeason;

@end

@implementation seasonTests

- (void)setUp {
    [super setUp];
    self.testSeason = [[SPSeason alloc] initWithJsonFileName:@"mannschaften"];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void)testInitializerWithUnexistingFile {
    self.testSeason = [[SPSeason alloc] initWithJsonFileName:@""];
    XCTAssertNotNil(self.testSeason.errorDuringCreation);
}

-(void)testInitializerWithExistingFile {
    self.testSeason = [[SPSeason alloc] initWithJsonFileName:@"mannschaften"];
    XCTAssertNil(self.testSeason.errorDuringCreation);
}

-(void)testGetNumberOfMatchDaysWithNoSeason {
    self.testSeason = nil;
    NSInteger matchesForDay = [self.testSeason getNumberOfMatchesForADay:-1];
    XCTAssertEqual(matchesForDay, 0);
}

- (void)testGetNumberOfMatchesForADayWithNegativeValues {
    NSInteger matchesForDay = [self.testSeason getNumberOfMatchesForADay:-1];
    XCTAssertEqual(matchesForDay, 0);
}

- (void)testGetNumberOfMatchesForADayWithOutOfBoundsValue {
    NSInteger matchesForDay = [self.testSeason getNumberOfMatchesForADay:100];
    XCTAssertEqual(matchesForDay, 0);
}

-(void)testGetMatchStringForADayWithOutNegativeValues {
    NSString *matchString = [self.testSeason getMatchStringForADay:-100 andMatch:-100];
    XCTAssertEqualObjects(matchString, @"");
}

-(void)testGetMatchStringForADayWithOutOfBoundsValues {
    NSString *matchString = [self.testSeason getMatchStringForADay:100 andMatch:100];
    XCTAssertEqualObjects(matchString, @"");
}

-(void)testGetStringForMatchDateWithNegativeValue {
    NSString *matchString = [self.testSeason getStringForMatchDate:-100];
    XCTAssertEqualObjects(matchString, @"");
}

-(void)testGetStringForMatchDateWithOutOfBoundsValues {
    NSString *matchString = [self.testSeason getStringForMatchDate:100];
    XCTAssertEqualObjects(matchString, @"");
}

@end
