//
//  Team.m
//  GameOfBrains
//
//  Created by Student on 17.11.15.
//  Copyright (c) 2015 Student. All rights reserved.
//

#import "Team.h"

@implementation Team


+ (id)sharedInstance{
    static Team * sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(instancetype)init{
    if ([super init]) {
        self.login = @"";
        self.password = @"";
        self.teamID = @"";
        self.tournaments = [NSMutableArray new];
        self.curTournament = [Tournament new];
    }
    return self;
}



@end
