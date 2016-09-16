//
//  SPTeam.m
//  aufgabeSpielplan
//
//  Created by Abel Serra on 25.08.16.
//  Copyright © 2016 Abel Serra. All rights reserved.
//

#import "SPMatch.h"
#import "SPTeam.h"

@interface SPTeam ()

@property NSString *name;

@end

@implementation SPTeam

- (id)initWithName:(NSString *)name
{
    self = [super init];
    if (self) {
        _name = name;
    }
    return self;
}

- (NSString *)getTeamName
{
    return self.name;
}

@end
