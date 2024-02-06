//
//  AppUser.h
//  GameOfBrains
//
//  Created by Student on 10.11.15.
//  Copyright (c) 2015 Student. All rights reserved.
//

@class Tournament;

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
//#import "Tournament.h"

@interface AppUser : NSObject

@property NSString *login;
@property NSString * password;
@property NSString * userID;
@property int isDictor;
@property NSMutableArray *tournaments;
@property Tournament *curTournament;


+ (id)sharedInstance;
- (NSMutableArray* )getTournamentsForDictorWithId:(NSString *) userId;
- (NSMutableArray* )getTournamentsForTeamById:(NSString *) userId;
- (NSMutableArray* )getNewTournamentsForTeamById:(NSString *) userId;

@end
