//
//  MatchTeamController.m
//  GameOfBrains
//
//  Created by Student on 23.11.15.
//  Copyright (c) 2015 Student. All rights reserved.
//

#import "MatchTeamController.h"

@interface MatchTeamController ()
@property (strong, nonatomic) IBOutlet UILabel *firstTeamLabel;
@property (strong, nonatomic) IBOutlet UILabel *secondTeamLabel;

@end

@implementation MatchTeamController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.hidesBackButton = YES;

    
    self.currentUser = [AppUser sharedInstance];
    
    self.firstTeamLabel.text = self.currentUser.curTournament.matches[self.currentUser.curTournament.curMatch][@"firstTeamName"];
    self.secondTeamLabel.text = self.currentUser.curTournament.matches[self.currentUser.curTournament.curMatch][@"secondTeamName"];

    
}

- (IBAction)clickToAnswer:(id)sender {
    NSDate *stopDate = [NSDate date];
    
    NSLog(@"%@", stopDate);
    
    PFQuery *query = [PFQuery queryWithClassName:@"Match"];
    [query getObjectInBackgroundWithId:[self.currentUser.curTournament.matches[self.currentUser.curTournament.curMatch] objectId] block:^(PFObject *match, NSError *error){
        
        
        
        if ([self.currentUser.userID isEqualToString:match[@"firstTeamId"]] ) {
            if (match[@"firstTeamTime"]==nil || [match[@"firstTeamTime"] isEqualToString:@""] ) {
                 match[@"firstTeamTime"] = stopDate;
            }
           
            
        } else {
            if (match[@"secondTeamTime"]==nil || [match[@"secondTeamTime"] isEqualToString:@""] ) {
                match[@"secondTeamTime"] = stopDate;
            }
        }
        
        [match saveInBackground];
    }];
    
    
}

- (IBAction)updatePage:(id)sender {
    
    PFQuery * query = [PFQuery queryWithClassName:@"Tournament"];
    [query getObjectInBackgroundWithId:self.currentUser.curTournament.tournamentId block:^(PFObject *tour, NSError *error){
        if ([tour[@"currentMatch"] intValue] != self.currentUser.curTournament.curMatch) {
            
            self.currentUser.curTournament.curMatch = [tour[@"currentMatch"] intValue];
            [self.navigationController popViewControllerAnimated:TRUE];
           // [self performSegueWithIdentifier:@"backToTeamTour" sender:self];
        }
        
    }];
    
 
    
  /*  if (([self.currentUser.userID isEqualToString:self.matches[self.currentUser.curTournament.curMatch][@"firstTeamId"] ] ||
         [self.currentUser.userID isEqualToString:self.matches[self.currentUser.curTournament.curMatch][@"secondTeamId"]]) &&
        [self.matches[self.currentUser.curTournament.curMatch][@"inProcess"] boolValue] == YES  )
    */
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
