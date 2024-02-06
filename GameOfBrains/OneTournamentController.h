//
//  OneTournamentController.h
//  GameOfBrains
//
//  Created by Student on 15.11.15.
//  Copyright (c) 2015 Student. All rights reserved.
//

/*@class Tournament;
@class MatchmakingClient;
@class MatchmakingServer;
*/
 
#import <UIKit/UIKit.h>
#import "Tournament.h" 
#import "AppUser.h"
#import "MatchmakingClient.h"
#import "MatchmakingServer.h"
#import "HostViewController.h"

@class OneTournamentController;

@protocol OneTournamentControllerDelegate <NSObject>

- (void)oneTournamentControllerDidCancel:(OneTournamentController *)controller;
//- (void)oneTournamentControllerDidCancel:(OneTournamentController *)controller didEndSessionWithReason:(QuitReason)reason;


@end


@interface OneTournamentController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, MatchmakingClientDelegate, MatchmakingServerDelegate, HostViewControllerDelegate>
@property (nonatomic, weak) id <OneTournamentControllerDelegate> delegate;

@property AppUser *currentUser;


@end
