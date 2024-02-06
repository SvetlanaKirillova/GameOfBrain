//
//  Team.h
//  GameOfBrains
//
//  Created by Student on 17.11.15.
//  Copyright (c) 2015 Student. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Tournament.h" 
#import <Parse/Parse.h>

@interface Team : NSObject

@property NSString *login;
@property NSString * password;
@property NSString * teamID;
@property NSMutableArray * tournaments;
@property Tournament *curTournament;



+ (id)sharedInstance;

@end
