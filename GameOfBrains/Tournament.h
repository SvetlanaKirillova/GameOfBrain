//
//  Tournament.h
//  GameOfBrains
//
//  Created by Student on 13.11.15.
//  Copyright (c) 2015 Student. All rights reserved.
//

@class AppUser;
#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface Tournament : NSObject

@property NSString *title;
@property NSDate *dateOfUpdate;
@property NSMutableArray * questions;
@property NSMutableArray *teams;
@property NSString *dictroId;
@property NSString *tournamentId;
@property int numberOfMatches;
@property NSMutableArray* matches;
@property NSDate *goneAt;
@property int nextMatch;
@property int curMatch;
@property int curQuestion;
//@property AppUser *u;


+ (id)sharedInstance;
//-(AppUser *)getDictorById:(NSString*) userId;
-(NSMutableArray*) getListOfTeamsByTournamentId:(NSString*)ID;
-(void)getNumberOfMatchesForOneRound;


@end
