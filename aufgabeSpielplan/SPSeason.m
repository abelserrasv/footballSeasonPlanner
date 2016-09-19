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
@property NSDictionary *seasonPlan;

@property NSMutableSet<SPTeam *> *teams;
@property NSDictionary *jsonSeasonFile;
@property NSArray<NSDate *> *sortedMatchDays;
@property NSError *errorDuringCreation;

@end

@implementation SPSeason

- (id)initWithJsonFileName:(NSString *)jsonFileName
{
    self = [super init];
    if (self) {
        _teams = [[NSMutableSet alloc] init];
        _seasonPlan = [[NSMutableDictionary alloc] init];
        _sortedMatchDays = [[NSArray alloc] init];
        _errorDuringCreation = nil;
        [self initialize:jsonFileName];
    }
    return self;
}

- (void)initialize:(NSString *)jsonFileName
{
    NSDataAsset *mannschaften = [[NSDataAsset alloc] initWithName:jsonFileName];
    
    [self createDictionaryFromSeasonJson:mannschaften];
    
    // If no error with the json file occur.
    if (!self.errorDuringCreation) {
        [self setLeagueFromJsonFile];
        [self setSeasonFromJsonFile];
        self.teams = [self createTeams];
        self.seasonPlan = [self getListMatches];
        self.sortedMatchDays = [self sortMatchDatesArray];
    }
}

- (void)createDictionaryFromSeasonJson:(NSDataAsset *)jsonFile
{
    if (!jsonFile) {
        NSDictionary *userInfo = @{
                                   NSLocalizedDescriptionKey: NSLocalizedString(@"The file operation failed because the file does not exist.", nil)
                                   };
        self.errorDuringCreation = [NSError errorWithDomain:NSFilePathErrorKey
                                             code:-1100
                                         userInfo:userInfo];
        return;
    }
    
    NSError *error = nil;
    NSString *iso = [[NSString alloc] initWithData:jsonFile.data
                                          encoding:NSISOLatin1StringEncoding];
    NSData *dutf8 = [iso dataUsingEncoding:NSUTF8StringEncoding];
    
    self.jsonSeasonFile =
    [NSJSONSerialization JSONObjectWithData:dutf8
                                    options:NSJSONReadingMutableContainers
                                      error:&error];
    if (error) {
        NSLog(@"JSONObjectWithData error: %@", error);
        self.errorDuringCreation = error;
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

- (NSMutableSet<SPTeam *> *)createTeams
{
    NSMutableSet<SPTeam *> *localSetOfteams = [[NSMutableSet alloc] init];
    // Check of there is enough days to play
    if (self.jsonSeasonFile)
    {
        for (NSMutableDictionary *team in
             [self.jsonSeasonFile objectForKey:@"teams"]) {
            SPTeam *newTeam = [[SPTeam alloc] initWithName:[team objectForKey:@"name"]];
            [localSetOfteams addObject:newTeam];
        }
    }
    if (localSetOfteams.count < 2){
        NSDictionary *userInfo = @{
                                   NSLocalizedDescriptionKey: NSLocalizedString(@"The file operation failed because there is not enough teams to organize the season.", nil)
                                   };
        self.errorDuringCreation = [NSError errorWithDomain:@"Teams error."
                                                       code:-1
                                                   userInfo:userInfo];
        return nil;
    } else {
        return localSetOfteams;
    }
}

- (NSDictionary *)getListMatches
{
    // There was an error with the teams array creation.
    if (self.errorDuringCreation) {
        return nil;
    }
    
    NSMutableDictionary *seasonLocalDictionary = [[NSMutableDictionary alloc] init];
    
    NSMutableArray<SPTeam *> *teamList = [[self.teams allObjects] mutableCopy];
    if ([teamList count] % 2 != 0) {
        SPTeam *newTeam = [[SPTeam alloc] initWithName:nil];
        [teamList addObject:newTeam];
    }
    
    NSArray<NSDate *> *arrayOfMatchDates = [self getAllSundays];
    
    NSUInteger numDaysPerRound = ([teamList count] - 1);
    
    // Check of there is enough days to play
    // (numDaysPerRound * 2) --> numDaysPerRound: number of matches per round
    //                           2: 2 rounds per season.
    if ((numDaysPerRound * 2) > arrayOfMatchDates.count)
    {
        NSDictionary *userInfo = @{
                                   NSLocalizedDescriptionKey: NSLocalizedString(@"The file operation failed because there is not enough days to place the matches.", nil)
                                   };
        self.errorDuringCreation = [NSError errorWithDomain:@"Matches error."
                                                       code:-2
                                                   userInfo:userInfo];
        return nil;
    }
    
    NSUInteger halfSize = [teamList count] / 2;
    
    NSMutableArray<SPTeam *> *teams = [[NSMutableArray<SPTeam *> alloc] init];
    
    [teams addObjectsFromArray:teamList];
    [teams removeObjectAtIndex:0];
    
    NSUInteger teamsSize = [teams count];
    
    for (int day = 0; day < numDaysPerRound; day++) {
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
        [seasonLocalDictionary setObject:arrayOfMatches
                            forKey:[arrayOfMatchDates objectAtIndex:(day)]];
        
        NSLog(@"-------- Second Round ----------------");
        [arrayOfMatches removeAllObjects];
        NSLog(@"Day %@", [arrayOfMatchDates objectAtIndex:(day + numDaysPerRound)]);
        
        NSLog(@"%@ vs %@", [teamList[0] getTeamName], [teams[teamIdx] getTeamName]);
        match = [[SPMatch alloc]
                 initWithLocalTeam:teams[teamIdx]
                 visitorTeam:teamList[0]
                 andDateOfTheMatch:[arrayOfMatchDates objectAtIndex:(day + numDaysPerRound)]];
        [arrayOfMatches addObject:match];
        
        for (int idx = 1; idx < halfSize; idx++) {
            NSUInteger firstTeam = (day + idx) % teamsSize;
            NSUInteger secondTeam = (day + teamsSize - idx) % teamsSize;
            NSLog(@"%@ vs %@", [teams[secondTeam] getTeamName],
                  [teams[firstTeam] getTeamName]);
            SPMatch *match = [[SPMatch alloc]
                              initWithLocalTeam:teams[firstTeam]
                              visitorTeam:teams[secondTeam]
                              andDateOfTheMatch:[arrayOfMatchDates objectAtIndex:(day + numDaysPerRound)]];
            [arrayOfMatches addObject:match];
        }
        [seasonLocalDictionary
         setObject:arrayOfMatches
         forKey:[arrayOfMatchDates objectAtIndex:(day + numDaysPerRound)]];
    }
    return seasonLocalDictionary;
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
    if (self.seasonPlan) {
        NSArray<NSDate *> *allMatchDays = self.seasonPlan.allKeys;
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"self" ascending:YES];
        NSArray *descriptors = [NSArray arrayWithObject:descriptor];
        
        return [NSArray arrayWithArray:[allMatchDays sortedArrayUsingDescriptors:descriptors]];
    }
    return nil;
}

- (NSInteger)getNumberOfMatchDays
{
    if (self.seasonPlan) {
        return [[self.seasonPlan allKeys] count];
    } else {
        return 0;
    }
}

- (NSInteger)getNumberOfMatchesForADay:(NSInteger)indexOfDay
{
    if (self.sortedMatchDays && (indexOfDay < self.sortedMatchDays.count) && ([self.seasonPlan objectForKey:self.sortedMatchDays[indexOfDay]])) {
        return [[self.seasonPlan objectForKey:self.sortedMatchDays[indexOfDay]] count];
    } else {
        return 0;
    }
}

- (NSString *)getMatchStringForADay:(NSInteger)indexOfDay andMatch:(NSInteger)indexOfTeam
{
    if (self.sortedMatchDays &&
        (indexOfDay < self.sortedMatchDays.count) &&
        ([self.seasonPlan objectForKey:self.sortedMatchDays[indexOfTeam]])) {
        return [[[self.seasonPlan objectForKey:self.sortedMatchDays[indexOfDay]] objectAtIndex:indexOfTeam] getStringForMatch];
    } else {
        return @"";
    }
}

- (NSString *)getStringForMatchDate:(NSInteger)dateIndex
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterLongStyle;
    if (dateIndex < self.sortedMatchDays.count) {
        return [formatter stringFromDate:self.sortedMatchDays[dateIndex]];
    } else {
        return @"";
    }
}

@end
