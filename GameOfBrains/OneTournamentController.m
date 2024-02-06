//
//  OneTournamentController.m
//  GameOfBrains
//
//  Created by Student on 15.11.15.
//  Copyright (c) 2015 Student. All rights reserved.
//

#import "OneTournamentController.h" 
#import "MatchDictorController.h"
#import "PeerCell.h"
#import "Reachability.h"


@interface OneTournamentController ()
{
    Reachability *internetReachableFoo;
}


//@property (strong, nonatomic) IBOutlet UIPanGestureRecognizer *refreshControl;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *firstTeamLabel;
@property (strong, nonatomic) IBOutlet UILabel *secondTeamLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *listTeamsViewHeight;
@property (strong, nonatomic) IBOutlet UIButton *buttonGo;
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *imageHeight;
@property (strong, nonatomic) IBOutlet UIView *clientServerView;
@property (strong, nonatomic) IBOutlet UITextField *textFiledName;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UILabel *numberOfQuestions;

@property UIRefreshControl *refreshControl;

@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UIView *listOfTeamsView;
@property NSMutableArray *teams;
@property __block NSMutableArray * matches;

@property double teamListView_X;
@property double teamListView_Y;
@property double teamListView_width;
@property double teamListView_height;
@property double screenView_width;
@property double screenView_height;
@property UIColor * labelTextBlueColor;
@property UIColor * buttonTextGreenColor;


// The name of the GameKit session.
#define SESSION_ID @"GameOfBrain"


@end

@implementation OneTournamentController




- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.teamListView_X = self.listOfTeamsView.center.x;
    self.teamListView_Y = self.listOfTeamsView.center.y;
    self.teamListView_width = self.listOfTeamsView.frame.size.width;
    self.teamListView_height = self.listOfTeamsView.frame.size.height;
    self.screenView_width = self.view.frame.size.width;
    self.screenView_height = self.view.frame.size.height;
    
    self.labelTextBlueColor = [UIColor colorWithRed:5/255.0 green:49/255.0 blue:113/255.0 alpha:1.0];
    self.buttonTextGreenColor = [UIColor colorWithRed:186/255.0 green:220/255.0 blue:2/255.0 alpha:1.0];

    
    self.teams  = [NSMutableArray new];
    self.matches = [NSMutableArray new];
    
    self.currentUser = [AppUser sharedInstance];
    [self getListOfTeams];
    
    self.currentUser.curTournament.matches = self.matches;
    self.currentUser.curTournament.teams = self.teams;
    
    
#pragma FOR TEAM ACCOUNT
    if (self.currentUser.isDictor == 0) {
        self.buttonGo.hidden = YES;
        
    }
    PFQuery * tourQuery = [PFQuery queryWithClassName:@"Tournament"];
    [tourQuery getObjectInBackgroundWithId:self.currentUser.curTournament.tournamentId block:^(PFObject *tour, NSError *error){
        self.currentUser.curTournament.curMatch = [tour[@"currentMatch"] intValue];
        
    }];
    
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(testRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.scrollView addSubview:refreshControl];
    
    //[self.view addSubview:scrollView];

    
    [self showMainView];
    

    
}

- (void)testRefresh:(UIRefreshControl *)refreshControl
{
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing data..."];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [NSThread sleepForTimeInterval:3];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"MMM d, h:mm a"];
            NSString *lastUpdate = [NSString stringWithFormat:@"Last updated on %@", [formatter stringFromDate:[NSDate date]]];
            
            refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdate];
            
            [self getListOfTeams];
            [self showMainView];
            //[self testInternetConnection];
            [refreshControl endRefreshing];
            
            NSLog(@"refresh end");
        });
    });
}






#pragma Network connection
// Checks if we have an internet connection or not
- (void)testInternetConnection
{
    internetReachableFoo = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    // Internet is reachable
    internetReachableFoo.reachableBlock = ^(Reachability*reach)
    {
        // Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            //self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Соединение установлено"];
           

            NSLog(@"Yayyy, we have the interwebs!");
        });
    };
    
    // Internet is not reachable
    internetReachableFoo.unreachableBlock = ^(Reachability*reach)
    {
        // Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Соединение отсутствует"];
            
            NSLog(@"Someone broke the internet :(");
        });
    };
    
    [internetReachableFoo startNotifier];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self getListOfTeams];
}


# pragma marks - only for dictor method
- (IBAction)startGame:(id)sender {
    
    // if tournament is not started
    if (self.currentUser.curTournament.goneAt == nil) {
        
        PFQuery * curTour = [PFQuery queryWithClassName:@"Tournament"];
        
        [curTour getObjectInBackgroundWithId:self.currentUser.curTournament.tournamentId block:^(PFObject *tour, NSError *error){
            tour[@"goneAt"] = [NSDate date];
            [tour saveInBackgroundWithBlock:^(BOOL succeded, NSError *error){
                self.currentUser.curTournament.goneAt = [NSDate date];
                
                [self generateMatchesSchedule];
                
                
                NSLog(@"%@", [[NSDate date] descriptionWithLocale:[NSLocale currentLocale]]);
            }];
            
        }];
    
    }
    else {
        NSLog(@"%@", self.currentUser.curTournament.goneAt);
        
       
        //NSLog(@"%@", [self.currentUser.curTournament.matches[0] objectId]);
        
                
        PFQuery *startQuery = [PFQuery queryWithClassName:@"Match"];
        [startQuery getObjectInBackgroundWithId:[self.currentUser.curTournament.matches[self.currentUser.curTournament.curMatch] objectId] block:^(PFObject *match, NSError *error){
            if (!error) {
                
                //??? where i should set this???
              /*  match[@"inProcess"] = @YES;
                
                [match saveInBackgroundWithBlock:^(BOOL success, NSError *error){
                    if (success) {
                        [self performSegueWithIdentifier:@"goToTeamsList" sender:self];

                    }
                }];*/
                
               /* HostViewController *controller = [[HostViewController alloc] initWithNibName:@"HostViewController" bundle:nil];
                
                [self presentViewController:controller animated:NO completion:nil];*/
                HostViewController *controller = [[HostViewController alloc] initWithNibName:@"HostViewController" bundle:nil];
                controller.delegate = self;
                
                [self performSegueWithIdentifier:@"goToTeamsList" sender:self];
                
            }else{
                NSLog(@"%@", error);
            }
            
        }];
        
        
    }
    
    PFQuery *currentTourQuery = [PFQuery queryWithClassName:@"Tournament"];
   
   /* [currentTourQuery getObjectInBackgroundWithId:self.currentUser.curTournament.tournamentId block:^(PFObject *tour, NSError *error){
        tour[@"currentMatch"] = [NSNumber numberWithInt:self.currentUser.curTournament.curMatch]    ;
        [tour saveInBackgroundWithBlock:^(BOOL successed, NSError *error){
            if (successed) {
                NSLog(@"match saved");
            }else{
                NSLog(@"%@", error);
            }
        }];
    }];*/
    
}

//...................
#pragma mark - HostViewControllerDelegate

- (void)hostViewControllerDidCancel:(HostViewController *)controller
{
    [self dismissViewControllerAnimated:NO completion:nil];
}


-(void)generateMatchesSchedule{  // deleting old schedule and add new one
    [self.currentUser.curTournament getNumberOfMatchesForOneRound];
    
    __block NSMutableArray * result = [NSMutableArray new];
    
  //  NSLog(@"%i", (int)self.teams.count);
    
    PFQuery *deleteQuery = [PFQuery queryWithClassName:@"Match"];
    [deleteQuery whereKey:@"tournamentId" equalTo:self.currentUser.curTournament.tournamentId];
    
    [deleteQuery findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError *error){
        if (!error) {
            for (int i=0; i<objects.count; i++) {
                PFObject *tour = objects[i];
                [tour deleteInBackground];
            }
            
            for (int i =0; i<self.teams.count; i++) {
                for (int j=(int)self.teams.count-1; j>i; --j) {
                    PFObject *match = [PFObject objectWithClassName:@"Match"];
                    match[@"tournamentId"] = self.currentUser.curTournament.tournamentId;
                    match[@"firstTeamId"] = [self.teams[i] userID];
                    match[@"secondTeamId"] = [self.teams[j] userID];
                    match[@"firstTeamName"] = [self.teams[i] login];
                    match[@"secondTeamName"] = [self.teams[j] login];
                    [match saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                        if(succeeded){
                            [result addObject:match];
                            self.matches = result;
                            self.currentUser.curTournament.matches = self.matches;
                            
                            [self showSchedule];
                            [self showMainView];
                        }else{
                            [[[UIAlertView alloc] initWithTitle:@"Fail"
                                                        message:@"Somethinf was wrong!"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil] show];
                        }
                    }];
                }
                
                
            }
            
            
            
        }
    }];
    


}

-(void) getListOfTeams{
    __block NSMutableArray * teams = [NSMutableArray new];
    PFQuery *queryTournament = [PFQuery queryWithClassName:@"Tournament"];
    [queryTournament whereKey:@"objectId" equalTo:self.currentUser.curTournament.tournamentId];
    
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
            
            self.teams = teams;
            self.currentUser.curTournament.teams  = self.teams;
            [self showListTeams];

            if (self.currentUser.isDictor == 1 && self.currentUser.curTournament.goneAt == nil) {
                [self generateMatchesSchedule];
                
            } else {
                PFQuery *queryMatches = [PFQuery queryWithClassName:@"Match"];
                [queryMatches whereKey:@"tournamentId" equalTo:self.currentUser.curTournament.tournamentId];
                
                [queryMatches findObjectsInBackgroundWithBlock:^(NSArray *matches, NSError *error){
                    if (!error) {
                        self.matches = (NSMutableArray*)matches;
                        self.currentUser.curTournament.matches = self.matches;
                        
                        if (([self.currentUser.userID isEqualToString:self.matches[self.currentUser.curTournament.curMatch][@"firstTeamId"] ] ||
                            [self.currentUser.userID isEqualToString:self.matches[self.currentUser.curTournament.curMatch][@"secondTeamId"]]) &&
                            [self.matches[self.currentUser.curTournament.curMatch][@"inProcess"] boolValue] == YES  ) {
                            
                             [self performSegueWithIdentifier:@"goToTeamMatch" sender:self];
                        }
                        
                        
                        
                        
                        PFFile *attachedPhoto = matches[self.currentUser.curTournament.curMatch][@"attachedFile"];
                        if (attachedPhoto == nil || [attachedPhoto isKindOfClass:[NSNull class]]) {
                            self.imageView.hidden =YES;
                            self.imageHeight.constant = 0;
                        }else{
                            
                            [attachedPhoto getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error){
                                if (!error) {
                                    self.imageView.hidden =NO;
                                    UIImage * image = [UIImage imageWithData:imageData];
                                    [self.imageView setImage:image];
                                }
                            }];
                        }

                        
                        [self showSchedule];
                        [self showMainView];
                    }
                
                }];
            }
            
            
            
        
        }
    }];
    
    
}


#pragma marks - what to show
-(void) showMainView{
    self.titleLabel.text = self.currentUser.curTournament.title;
    self.numberOfQuestions.text = [NSString stringWithFormat:@"%i", (int)self.currentUser.curTournament.questions.count ];
    
    NSLog(@"%@", self.currentUser.curTournament.goneAt);
    NSLog(@"%d", self.currentUser.curTournament.goneAt==nil);
    if (self.currentUser.curTournament.goneAt==nil) {
        
        [self.firstTeamLabel setHidden:YES];
        [self.secondTeamLabel setHidden:YES];
    }
    
    if (self.currentUser.curTournament.matches.count>0) {
        self.firstTeamLabel.text = self.currentUser.curTournament.matches[self.currentUser.curTournament.curMatch][@"firstTeamName"];
        self.secondTeamLabel.text = self.currentUser.curTournament.matches[self.currentUser.curTournament.curMatch][@"secondTeamName"];
    }
    
    if(self.currentUser.isDictor == 1){
        self.imageHeight.constant = 0;
    }
   
}



-(void)showListTeams{
    for (int i=0; i<self.teams.count; i++) {
        UILabel *teamLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.teamListView_X - self.teamListView_width/2 + 10 ,
                                                                       self.teamListView_Y +10 - self.teamListView_height/2 + i*20, 100, 20)];
        [teamLabel setText:[self.currentUser.curTournament.teams[i] login]];
        [teamLabel setTextColor:self.labelTextBlueColor];
        
        UIButton * button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button setTitle:@"Удалить" forState:UIControlStateNormal];
        [button sizeToFit];
        button.center = CGPointMake(self.teamListView_X + 20,
                                    self.teamListView_Y +20 - self.teamListView_height/2 + i*20);
        [button setTag:i];
        [button addTarget:self action:@selector(deleteTeamByTeamId:) forControlEvents: UIControlEventTouchUpInside   ];
        [button setTitleColor:self.buttonTextGreenColor forState:UIControlStateNormal];
        
        self.listTeamsViewHeight.constant = self.teams.count*30;
        if(self.currentUser.isDictor == 1){
            [self.mainView addSubview:button];
        }
        [self.mainView addSubview:teamLabel];
    }
    
}


-(NSMutableArray*)getTeamResults{
    
    NSMutableArray * team_match = [NSMutableArray new];
    
    for (int i=0; i<self.teams.count; i++) {
        NSMutableDictionary *dict = [NSMutableDictionary new];
        
        for (int j=0; j<self.matches.count; j++) {
            if ([[self.teams[i] userID] isEqualToString:self.matches[j][@"firstTeamId"]] ) {
                
                [dict setObject:[NSString stringWithFormat:@"%@:%@", self.matches[j][@"firstTeamScore"], self.matches[j][@"secondTeamScore"]] forKey:self.matches[j][@"secondTeamName"] ];
                
                if ( self.matches[j][@"firstTeamScore"] == nil) {
                    [dict setObject:@"?:?" forKey:self.matches[j][@"secondTeamName"] ];
                }
            }
            
            else if ([[self.teams[i] userID] isEqualToString:self.matches[j][@"secondTeamId"]]){
            
                [dict setObject:[NSString stringWithFormat:@"%@:%@", self.matches[j][@"secondTeamScore"], self.matches[j][@"firstTeamScore"]] forKey:self.matches[j][@"firstTeamName"] ];
                if ( self.matches[j][@"secondTeamScore"] == nil) {
                    [dict setObject:@"?:?" forKey:self.matches[j][@"firstTeamName"] ];
                }

            }
            
            if ( self.matches[j][@"firstTeamScore"] == nil) {
                
            }
        }
        
        [team_match addObject:dict];
    }
    
    return team_match;
}

-(void)showSchedule{
    
    NSMutableArray *results = [self getTeamResults];
    
        for (int i=0; i<self.teams.count+1; i++) {
           
        for(int j=0; j<self.teams.count+1; j++){
            
        UIButton * button = [UIButton buttonWithType:UIButtonTypeSystem];
        
         if (i == 0 && j>0) {
                [button setTitle:[self.teams[j-1] login] forState:UIControlStateNormal];
             
         }else if (j == 0 && i>0) {
             [button setTitle:[self.teams[i-1] login] forState:UIControlStateNormal];
             
         }
         else if( i == j){
             [button setTitle:@"" forState:UIControlStateNormal];

         }
         
         else {
             
             [button setTitle:[results[j-1] objectForKey:[self.teams[i-1] login]] forState:UIControlStateNormal];
             if (button.titleLabel.text == nil) {
                 [button setTitle:@"?:?" forState:UIControlStateNormal];
             }
         
         }
        
            
        [button sizeToFit];
         
        button.frame = CGRectMake(self.teamListView_X- self.teamListView_width/2 + i*(self.screenView_width-60)/(self.teams.count+1),
                                  self.teamListView_Y+ self.teamListView_height*0.5 + 20*j,
                                  (self.screenView_width -60)/(self.teams.count+1), 25);
           // NSLog(@" %f", self.screenView_width);
        
            button.titleLabel.font = [UIFont systemFontOfSize:15];
            if (self.teams.count > 4) {
                button.titleLabel.font = [UIFont systemFontOfSize:11];
            }
            
        [button setBackgroundColor:[UIColor grayColor]];
        [button setTitleColor:self.buttonTextGreenColor forState:UIControlStateNormal];
        if(i==j){
               [button setBackgroundColor:self.labelTextBlueColor];
        }
            
        [self.mainView addSubview:button];
        }
        
    }
    

}

-(void)deleteTeamByTeamId:(UIButton *) sender{

    NSLog(@"%@", [self.teams[[sender tag]] userID]);
    __block NSString* teamId = [self.teams[[sender tag]] userID];
    
    PFQuery *queryTournament = [PFQuery queryWithClassName:@"Tournament" ];
    [queryTournament whereKey:@"objectId" equalTo:self.currentUser.curTournament.tournamentId];
    [queryTournament getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error){
     
        PFQuery * queryForTeam = [PFQuery queryWithClassName:@"AppUser"];
        [queryForTeam whereKey:@"objectId" equalTo:teamId];
        
        [queryForTeam getFirstObjectInBackgroundWithBlock:^(PFObject *teamToDelete, NSError *error){
        
            
            PFRelation *relation = [object relationForKey:@"teams"];
            [relation removeObject:teamToDelete];
            [object saveInBackground];

           // [self viewDidLoad];
            NSLog(@" %lu", sender.state);
            [sender setTitleColor:[UIColor grayColor] forState:0];
            [sender setTitleColor:[UIColor grayColor] forState:1];
          //  sender.hidden= TRUE;
            sender.userInteractionEnabled= FALSE;
            sender.enabled = FALSE;
            sender.exclusiveTouch = FALSE;
            
            [self generateMatchesSchedule];
            

            [self getListOfTeams];
        }];
        
    }];
    
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"goToMatch"])
    {
        // Get reference to the destination view controller
       
        MatchDictorController *vc = (MatchDictorController *)[segue destinationViewController];
        vc.currentMatch = [self.currentUser.curTournament.matches[self.currentUser.curTournament.curMatch] objectId];
        // Pass any objects to the view controller here, like...
        
    }
}

/*-(void)refreshView:(UIRefreshControl *)refresh {
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing data..."];
    // custom refresh logic would be placed here...
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM d, h:mm a"];
    NSString *lastUpdated = [NSString stringWithFormat:@"Last updated on %@",
    [formatter stringFromDate:[NSDate date]]];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdated];
    [refresh endRefreshing];
}*/


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
