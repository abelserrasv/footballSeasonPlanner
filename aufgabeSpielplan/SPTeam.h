//
//  SPTeam.h
//  aufgabeSpielplan
//
//  Created by Abel Serra on 25.08.16.
//  Copyright © 2016 Abel Serra. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SPTeam : NSObject

/**
 Initializer that creates a new instance of the Team with the name of it.
 
 @param name Name of the Team
 
 @return the SPTeam instance.
 */
- (id)initWithName:(NSString *)name;

/**
 This method returns the name of the team.
 
 @return a string with name of the team.
 */
- (NSString *)getTeamName;

@end
