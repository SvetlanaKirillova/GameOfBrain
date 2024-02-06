//
//  MatchDictorController.h
//  GameOfBrains
//
//  Created by Student on 21.11.15.
//  Copyright (c) 2015 Student. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppUser.h" 
#import <Parse/Parse.h>
#import "Tournament.h" 
#import "Utils.h"

@interface MatchDictorController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIAlertViewDelegate>

@property AppUser * currecntUser;
@property NSString *currentMatch;
@property int firstTeamScore;
@property int secondTeamScore;
@property int teamToAnswer;

@end
