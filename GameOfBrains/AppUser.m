//
//  AppUser.m
//  GameOfBrains
//
//  Created by Student on 10.11.15.
//  Copyright (c) 2015 Student. All rights reserved.
//

#import "AppUser.h"
#import "Tournament.h" 

@implementation AppUser


-(NSMutableArray* )getTournamentsForDictorWithId:(NSString *)userId{
   __block  NSMutableArray *tournaments = [NSMutableArray new];
    
    
    PFQuery *queryForTournaments = [PFQuery queryWithClassName:@"Tournament"];
    [queryForTournaments whereKey:@"dictorID" equalTo:userId];
    
       NSArray *objects =[queryForTournaments findObjects];
            for (long i=objects.count-1; i>=0; i--) {
                Tournament *tour = [Tournament new];
                tour.title = objects[i][@"title"];
                tour.dateOfUpdate = [objects[i] updatedAt];
                tour.dictroId = objects[i][@"dictorID"];
                tour.tournamentId = [objects[i] objectId];
                tour.goneAt = objects[i][@"goneAt"];
                
                
                
                 PFQuery *questionsQuery = [PFQuery queryWithClassName:@"Question"];
                 [questionsQuery whereKey:@"tournamentId" equalTo:tour.tournamentId];
                 [questionsQuery findObjectsInBackgroundWithBlock:^(NSArray *questions, NSError *error){
                 if (!error) {
                 tour.questions  = (NSMutableArray *)questions;
                }
                 else{
                 NSLog(@"%@", error);
                 }
                 }];
                 
                 [tournaments addObject:tour];
                
            }
      
        
    return tournaments;
}

- (NSArray* )getTournamentsForTeamById:(NSString *) userId{
    __block NSMutableArray *tournaments1 = [NSMutableArray new];
    
    PFQuery * teamQuery = [PFQuery queryWithClassName:@"AppUser"];
    [teamQuery whereKey:@"objectId" equalTo:userId];
    PFObject *team = [teamQuery findObjects][0];
    
    PFQuery * objectsQuery = [PFQuery queryWithClassName:@"Tournament"];
    [objectsQuery whereKey:@"teams" equalTo:team];
   
    NSArray *objects = [objectsQuery findObjects];
        for(int i=0; i<objects.count; i++){
            Tournament *tour = [Tournament new];
            tour.title = objects[i][@"title"];
            tour.dateOfUpdate = [objects[i] updatedAt];
            tour.dictroId = objects[i][@"dictorID"];
            tour.tournamentId = [objects[i] objectId];
            tour.goneAt = objects[i][@"goneAt"];
            [tournaments1 addObject:tour];
            
        }
        
    
    
        return tournaments1;
}

- (NSMutableArray* )getNewTournamentsForTeamById:(NSString *) userId{
    NSMutableArray *tournaments1 = [NSMutableArray new];
    NSMutableArray *allTournaments = [NSMutableArray new];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Tournament"];
        NSArray * objects= [query findObjects];
                        
            for(int i=0; i<objects.count; i++){
                Tournament *tour = [Tournament new];
                tour.title = objects[i][@"title"];
                tour.dateOfUpdate = [objects[i] updatedAt];
                tour.dictroId = objects[i][@"dictorID"];
                tour.tournamentId = [objects[i] objectId];
                tour.goneAt = objects[i][@"goneAt"];
                [allTournaments addObject:tour];
                
            }
            
    
    
    NSMutableArray *myTournaments = [self getTournamentsForTeamById:userId];
    for(int i=0; i<allTournaments.count; i++){
    
        if(![myTournaments containsObject:allTournaments[i]]){
            [tournaments1 addObject:allTournaments[i]];
        }
        
    }
    
    return tournaments1;
}



-(NSMutableArray*)getAllTournaments{
    NSMutableArray * tours = [NSMutableArray new];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Tournament"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if (!error) {
            for (int i=0; i<objects.count; i++) {
                Tournament *t = [Tournament new];
                t.title = objects[i][@"title"];
                t.dateOfUpdate = [objects[i] updatedAt];
                t.dictroId = objects[i][@"dictorID"];
                t.goneAt = objects[i][@"goneAt"];
                [tours addObject:t];
            }
        }
    }];
    
    return tours;
}


+ (id)sharedInstance{
    static AppUser* sharedInstance;
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
        self.userID = @"";
        self.tournaments = [NSMutableArray new];
        self.curTournament = [Tournament new];
        self.isDictor = 0;
    }
    return self;
}

-(BOOL)isEqual:(id)object{
    if([object class] != [self class]){
        return FALSE;
    }
    if ([[object userID] isEqualToString:[self userID]]) {
        return TRUE;
    }
    return FALSE;
    
}


@end
