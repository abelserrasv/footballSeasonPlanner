//
//  SPMatch.m
//  aufgabeSpielplan
//
//  Created by Abel Serra on 25.08.16.
//  Copyright © 2016 Abel Serra. All rights reserved.
//

#import "SPMatch.h"
#import "SPTeam.h"

@interface SPMatch ()

@property NSDate *matchDate;
@property SPTeam *localTeam;
@property SPTeam *visitorTeam;

@end

@implementation SPMatch

- (id)initWithLocalTeam:(SPTeam *)localTeam
            visitorTeam:(SPTeam *)visitorTeam
      andDateOfTheMatch:(NSDate *)dateOfMatch
{
    self = [super init];
    if (self) {
        _localTeam = localTeam;
        _visitorTeam = visitorTeam;
        _matchDate = dateOfMatch;
    }
    return self;
}

- (NSString *)getStringForMatch
{
    if (!self.localTeam.getTeamName || !self.visitorTeam.getTeamName) {
        NSString *team;
        if (self.localTeam.getTeamName) {
            team = [self.localTeam getTeamName];
        }
        else {
            team = [self.visitorTeam getTeamName];
        }

        return [NSString stringWithFormat:@"%@ rest", team];
    }
    else {
        return [NSString stringWithFormat:@"%@ - %@", [self.localTeam getTeamName],
                                          [self.visitorTeam getTeamName]];
    }
}

@end
