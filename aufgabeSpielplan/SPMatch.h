//
//  SPMatch.h
//  aufgabeSpielplan
//
//  Created by Abel Serra on 25.08.16.
//  Copyright © 2016 Abel Serra. All rights reserved.
//

#import "SPTeam.h"
#import <Foundation/Foundation.h>

@interface SPMatch : NSObject

/**
 Initializer that creates a new instance of the Match with the teams (local and visitor) and the date of the match.
 
 @param localTeam   the local team.
 @param visitorTeam the visitor team.
 @param dateOfMatch the NSDate that represents the date of the match.
 
 @return an instance of SPTeam.
 */
- (id)initWithLocalTeam:(SPTeam *)localTeam visitorTeam:(SPTeam *)visitorTeam andDateOfTheMatch:(NSDate *)dateOfMatch;

/**
 This method build a string that contains the name of the two teams that will play the match.
 
 @return the string with contains: "<Local team> - <Visitor team>" or "<Team> rest" to indicate that this team is not playing this day.
 */
- (NSString *)getStringForMatch;

@end
