//
//  SPSeason.h
//  aufgabeSpielplan
//
//  Created by Abel Serra on 15.09.16.
//  Copyright © 2016 Abel Serra. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SPSeason : NSObject

/**
 The name of the League.
 */
@property (readonly) NSString *leagueName;

/**
 The name of the season.
 */
@property (readonly) NSString *seasonName;

/**
 This method calculates the number of match days the season has. This method is used to calculate the
 number of sections of the table.
 
 @return the number of match days.
 */
- (NSInteger)getNumberOfMatchDays;

/**
 This method calculates the number of matches that are planned for a day.
 
 @param indexOfDay the index of the day in the array of match days. The array of the days is calculated from the
                   season dictionary.
 
 @return the number of matches planned for a day.
 */
- (NSInteger)getNumberOfMatchesForADay:(NSInteger)indexOfDay;

/**
 This method build a string that contains the two teams that will play the match. This method is used from the Tableview
 source in order to fill the information of the cell.
 
 @param indexOfDay  index of the day in the match days array, this index is the indexPath.section that comes from the Tableview source.
 @param indexOfTeam index of the match in the matches array, this index is the indexPath.row that comes from the Tableview source.
 
 @return the string with contains: "<Local team> - <Visitor team>" or "<Team> rest" to indicate that this team is not playing this day.
 */
- (NSString *)getMatchStringForADay:(NSInteger)indexOfDay andMatch:(NSInteger)indexOfTeam;

/**
 This method returns the date passed as parameter formatted for the section title string.
 
 @param dateIndex the index of the day in the array of match days. The array of the days is calculated from the
 season dictionary.
 
 @return returns the NSDate formatted string.
 */
- (NSString *)getStringForMatchDate:(NSInteger)dateIndex;

@end
