//
//  Tournament.m
//  GameOfBrains
//
//  Created by Student on 13.11.15.
//  Copyright (c) 2015 Student. All rights reserved.
//
//@class AppUser;
#import "Tournament.h"
#import "AppUser.h" 

@implementation Tournament


+ (id)sharedInstance{
    static Tournament * sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}
-(instancetype)init{
    if ([super init]) {
        self.title = @"new";
        self.dateOfUpdate = [NSDate new];
        self.questions = [NSMutableArray new];
        self.teams = [NSMutableArray new];
        self.dictroId = @"";
        self.tournamentId = @"";
        self.numberOfMatches = 0;
        self.matches = [NSMutableArray new];
        //self.goneAt = [NSDate new];
        self.nextMatch = 0;
        self.curQuestion = 0;
    }
    return self;
}

-(NSMutableArray*) getListOfTeamsByTournamentId:(NSString*)ID{
    __block NSMutableArray * teams = [NSMutableArray new];
    PFQuery *queryTournament = [PFQuery queryWithClassName:@"Tournament"];
    [queryTournament whereKey:@"objectId" equalTo:ID];
    
    [queryTournament getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error){
        if (!error) {
            PFRelation *relation = [object relationForKey:@"teams"];
            PFQuery *query = [relation query];
            NSArray * objects = [query findObjects];
            for (int i=0; i<objects.count; i++) {
                AppUser *user = [AppUser new];
                user.login = objects[i][@"login"];
                user.userID = [objects[i] objectId];
                [teams addObject:user];
            }
        }
    }];
    
    return teams;
    
}

-(void)getNumberOfMatchesForOneRound{
    int count = 0;
    
    for (int i=1; i<self.teams.count; i++) {
        count += i;
    }
    
    self.numberOfMatches = count;
}


-(AppUser *)getDictorsById:(NSString*) userId{
    AppUser *user = [AppUser new];
    PFQuery *query = [PFQuery queryWithClassName:@"AppUser"];
    [query whereKey:@"objectId" equalTo:userId];
    user = [query findObjects][0];
    
    return user;
}

@end
