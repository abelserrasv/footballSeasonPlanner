//
//  SPSeason.m
//  aufgabeSpielplan
//
//  Created by Abel Serra on 15.09.16.
//  Copyright © 2016 Abel Serra. All rights reserved.
//

#import "SPMatch.h"
#import "SPSeason.h"
#import "SPTeam.h"

#import <UIKit/UIKit.h>

@interface SPSeason ()

@property NSString *leagueName;
@property NSString *seasonName;

/**
 The seasonPlan dictionary consists of a entries set which have the following structure:
 
 key: NSDate that represents the day where the matches take place.
 value: NSArray of matches which represents all matches that take place this date (key NSDate).
 
 This structure will be used by the Tableview datasource to calculate the sections and rows, as well as to access to the
 information. 
 
 Doing this way we can get with the indexpath the indexes of the key and values of the dictionary.
 */
@property NSMutableDictionary *seasonPlan;

@property NSMutableSet<SPTeam *> *teams;
@property NSDictionary *jsonSeasonFile;

@end

@implementation SPSeason

- (id)init
{
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    [self createDictionaryFromSeasonJson];
    [self setLeagueFromJsonFile];
    [self setSeasonFromJsonFile];
    [self getListMatches];
}

- (void)createDictionaryFromSeasonJson
{
    NSDataAsset *mannschaften =
        [[NSDataAsset alloc] initWithName:@"mannschaften"];

    self.seasonPlan = [[NSMutableDictionary alloc] init];

    NSError *error = nil;

    NSString *iso = [[NSString alloc] initWithData:mannschaften.data
                                          encoding:NSISOLatin1StringEncoding];
    NSData *dutf8 = [iso dataUsingEncoding:NSUTF8StringEncoding];

    self.jsonSeasonFile =
        [NSJSONSerialization JSONObjectWithData:dutf8
                                        options:NSJSONReadingMutableContainers
                                          error:&error];

    if (error) {
        NSLog(@"JSONObjectWithData error: %@", error);
    }
}

- (void)setLeagueFromJsonFile
{
    self.leagueName = [self.jsonSeasonFile objectForKey:@"league"];
}

- (void)setSeasonFromJsonFile
{
    self.seasonName = [self.jsonSeasonFile objectForKey:@"season"];
}

- (void)createTeams
{
    self.teams = [[NSMutableSet alloc] init];
    for (NSMutableDictionary *team in
         [self.jsonSeasonFile objectForKey:@"teams"]) {
        SPTeam *newTeam = [[SPTeam alloc] initWithName:[team objectForKey:@"name"]];
        [self.teams addObject:newTeam];
    }
}

- (void)getListMatches
{
    [self createTeams];
    [self getAllSundays];
    NSArray<NSDate *> *arrayOfMatchDates = [self getAllSundays];

    NSMutableArray<SPTeam *> *teamList = [[self.teams allObjects] mutableCopy];
    if ([teamList count] % 2 != 0) {
        SPTeam *newTeam = [[SPTeam alloc] initWithName:nil];
        [teamList addObject:newTeam];
    }

    // Check of there is enough days to play
    NSUInteger numDays = ([teamList count] - 1);
    NSUInteger halfSize = [teamList count] / 2;

    NSMutableArray<SPTeam *> *teams = [[NSMutableArray<SPTeam *> alloc] init];

    [teams addObjectsFromArray:teamList];
    [teams removeObjectAtIndex:0];

    NSUInteger teamsSize = [teams count];

    for (int day = 0; day < numDays; day++) {
        NSLog(@"-------- First Round ----------------");
        NSLog(@"Day %@", [arrayOfMatchDates objectAtIndex:(day)]);

        int teamIdx = day % teamsSize;

        NSMutableArray<SPMatch *> *arrayOfMatches = [[NSMutableArray alloc] init];

        NSLog(@"%@ vs %@", [teams[teamIdx] getTeamName], [teamList[0] getTeamName]);
        SPMatch *match = [[SPMatch alloc]
            initWithLocalTeam:teams[teamIdx]
                  visitorTeam:teamList[0]
            andDateOfTheMatch:[arrayOfMatchDates objectAtIndex:(day)]];
        [arrayOfMatches addObject:match];

        for (int idx = 1; idx < halfSize; idx++) {
            NSUInteger firstTeam = (day + idx) % teamsSize;
            NSUInteger secondTeam = (day + teamsSize - idx) % teamsSize;
            NSLog(@"%@ vs %@", [teams[firstTeam] getTeamName],
                  [teams[secondTeam] getTeamName]);
            SPMatch *match = [[SPMatch alloc]
                initWithLocalTeam:teams[firstTeam]
                      visitorTeam:teams[secondTeam]
                andDateOfTheMatch:[arrayOfMatchDates objectAtIndex:(day)]];
            [arrayOfMatches addObject:match];
        }
        [self.seasonPlan setObject:arrayOfMatches
                            forKey:[arrayOfMatchDates objectAtIndex:(day)]];

        NSLog(@"-------- Second Round ----------------");
        [arrayOfMatches removeAllObjects];
        NSLog(@"Day %@", [arrayOfMatchDates objectAtIndex:(day + numDays)]);

        NSLog(@"%@ vs %@", [teamList[0] getTeamName], [teams[teamIdx] getTeamName]);
        match = [[SPMatch alloc]
            initWithLocalTeam:teams[teamIdx]
                  visitorTeam:teamList[0]
            andDateOfTheMatch:[arrayOfMatchDates objectAtIndex:(day + numDays)]];
        [arrayOfMatches addObject:match];

        for (int idx = 1; idx < halfSize; idx++) {
            NSUInteger firstTeam = (day + idx) % teamsSize;
            NSUInteger secondTeam = (day + teamsSize - idx) % teamsSize;
            NSLog(@"%@ vs %@", [teams[secondTeam] getTeamName],
                  [teams[firstTeam] getTeamName]);
            SPMatch *match = [[SPMatch alloc]
                initWithLocalTeam:teams[firstTeam]
                      visitorTeam:teams[secondTeam]
                andDateOfTheMatch:[arrayOfMatchDates objectAtIndex:(day + numDays)]];
            [arrayOfMatches addObject:match];
        }
        [self.seasonPlan
            setObject:arrayOfMatches
               forKey:[arrayOfMatchDates objectAtIndex:(day + numDays)]];
    }
}

#pragma mark - Date management

- (NSArray<NSDate *> *)getAllSundays
{
    NSMutableArray<NSDate *> *arrayOfMatchDates = [[NSMutableArray alloc] init];
    NSInteger sunday = 1;

    // Set the incremental interval for each interaction.
    NSDateComponents *oneDay = [[NSDateComponents alloc] init];
    [oneDay setDay:1];

    // Using a Gregorian calendar.
    NSCalendar *calendar = [[NSCalendar alloc]
        initWithCalendarIdentifier:NSCalendarIdentifierGregorian];

    NSDate *currentDate =
        [self dateToFormatedDate:[self.jsonSeasonFile objectForKey:@"start"]];

    // Iterate from fromDate until toDate
    while ([currentDate
               compare:[self dateToFormatedDate:[self.jsonSeasonFile
                                                    objectForKey:@"end"]]] ==
           NSOrderedAscending) {

        NSDateComponents *dateComponents =
            [calendar components:NSCalendarUnitWeekday fromDate:currentDate];
        if (dateComponents.weekday == sunday) {
            [arrayOfMatchDates addObject:currentDate];
        }

        // "Increment" currentDate by one day.
        currentDate =
            [calendar dateByAddingComponents:oneDay toDate:currentDate options:0];
    }
    return arrayOfMatchDates;
}

- (NSDate *)dateToFormatedDate:(NSString *)dateStr
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormatter dateFromString:dateStr];

    return date;
}

#pragma mark - Table Info Management

- (NSArray<NSDate *> *)sortMatchDatesArray
{
    NSArray<NSDate *> *allMatchDays = self.seasonPlan.allKeys;
    NSSortDescriptor *descriptor =
        [[NSSortDescriptor alloc] initWithKey:@"self" ascending:YES];
    NSArray *descriptors = [NSArray arrayWithObject:descriptor];

    return [allMatchDays sortedArrayUsingDescriptors:descriptors];
}

- (NSInteger)getNumberOfMatchDays
{
    return [[self.seasonPlan allKeys] count];
}

- (NSInteger)getNumberOfMatchesForADay:(NSInteger)indexOfDay
{
    return [[self.seasonPlan objectForKey:[self sortMatchDatesArray][indexOfDay]]
        count];
}

- (NSString *)getMatchStringForADay:(NSInteger)indexOfDay
                           andMatch:(NSInteger)indexOfTeam
{
    return [[[self.seasonPlan objectForKey:[self sortMatchDatesArray][indexOfDay]]
        objectAtIndex:indexOfTeam] getStringForMatch];
}

- (NSString *)getStringForMatchDate:(NSInteger)dateIndex
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterLongStyle;
    return [formatter stringFromDate:[self sortMatchDatesArray][dateIndex]];
}

@end
