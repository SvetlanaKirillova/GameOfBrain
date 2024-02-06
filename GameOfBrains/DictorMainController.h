//
//  DictorMainController.h
//  GameOfBrains
//
//  Created by Student on 10.11.15.
//  Copyright (c) 2015 Student. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppUser.h"
#import "Tournament.h"

//@interface DictorMainController : UIViewController
@interface DictorMainController : UIViewController <UINavigationControllerDelegate>

@property AppUser *currentUser;
@end