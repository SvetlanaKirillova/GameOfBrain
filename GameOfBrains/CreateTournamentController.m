//
//  CreateTournamentController.m
//  GameOfBrains
//
//  Created by Student on 12.11.15.
//  Copyright (c) 2015 Student. All rights reserved.
//

#import "CreateTournamentController.h"

@interface CreateTournamentController ()
@property (strong, nonatomic) IBOutlet UITextField *nameInput;

@end

@implementation CreateTournamentController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.currentUser = [AppUser sharedInstance];
}

- (IBAction)createTournament:(id)sender {
    PFObject *newTournament = [PFObject objectWithClassName:@"Tournament"];
    newTournament[@"title"] = self.nameInput.text;
    NSLog(@" dictor ID= %@", self.currentUser.userID);
    newTournament[@"dictorID"] = self.currentUser.userID;
    [newTournament saveInBackgroundWithBlock:^(BOOL success, NSError *error){
        if (success) {
            self.nameInput.text= @"";
            
            self.currentUser.tournaments = [self.currentUser getTournamentsForDictorWithId:self.currentUser.userID];
            [self.navigationController popViewControllerAnimated:TRUE];
        } else {
            NSLog(@"%@", error); 
        }
    
    }];
    
    
    
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
