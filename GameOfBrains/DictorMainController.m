//
//  DictorMainController.m
//  GameOfBrains
//
//  Created by Student on 10.11.15.
//  Copyright (c) 2015 Student. All rights reserved.
//

#import "DictorMainController.h"
#import "listOfTournamentsCell.h"
#import "KeychainItemWrapper.h"
#import "Reachability.h"

@interface DictorMainController ()
{
    Reachability *internetReachableFoo;
}
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UINavigationItem *navigatorBar;
@property Tournament * currentTournament;
@property UIRefreshControl * refreshControl;

@end

@implementation DictorMainController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //[self.navigationItem.backBarButtonItem setTitle:@"njfjn"] ;
   //  self.navigationItem.hidesBackButton = YES;
    DictorMainController *sv = [[DictorMainController alloc] initWithNibName:@"SettingsView" bundle:nil];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:sv];
    [nc setDelegate:sv];
    
    KeychainItemWrapper *keyChainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"YourAppLogin" accessGroup:nil];
    
    NSString *password = [keyChainItem objectForKey:kSecValueData];
    NSString *username = [keyChainItem objectForKey:kSecAttrAccount];
    
    if (!([username isEqualToString:@""]) && username != nil) {
        PFQuery *userQuery = [PFQuery queryWithClassName:@"AppUser"];
        [userQuery whereKey:@"login" equalTo:username];
        
        [userQuery getFirstObjectInBackgroundWithBlock:^(PFObject *user, NSError *error){
            self.currentUser = [AppUser sharedInstance];
            self.currentUser.login = user[@"login"];
            
            self.currentUser.password = user[@"password"];
            self.currentUser.userID = [user objectId];
            
            if([user[@"isDictor"] isEqualToNumber:@1]){
                self.currentUser.isDictor = 1;
                //set to current user his/her tournaments
                self.currentUser.tournaments = [self.currentUser getTournamentsForDictorWithId:self.currentUser.userID];
            }else{
                self.currentUser.isDictor = 0;
                self.currentUser.tournaments = [self.currentUser getTournamentsForTeamById:self.currentUser.userID];
            }
            
            [self.tableView reloadData];
         //   [self performSegueWithIdentifier:@"toDictorMain" sender:self];
            
        }];
    }else{
    
            [self performSegueWithIdentifier:@"toStart" sender:self];
    }
    
    // refreshing
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    
    
   // self.currentUser = [AppUser sharedInstance];
    //self.currentUser.tournaments = [self getTournaments];

    
}

- (void)refresh:(UIRefreshControl *)refreshControl {
    // Do your job, when done:
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [NSThread sleepForTimeInterval:2];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"MMM d, h:mm a"];
            NSString *lastUpdate = [NSString stringWithFormat:@"Last updated on %@", [formatter stringFromDate:[NSDate date]]];
            
            //self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdate];
            
            [self.tableView reloadData];
            [self testInternetConnection];
            [self.tableView reloadData];
            
            [self.refreshControl endRefreshing];
            
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
            [self.refreshControl endRefreshing];
            
            
            NSLog(@"Someone broke the internet :(");
        });
    };
    
    [internetReachableFoo startNotifier];
}





- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    
     self.currentUser.tournaments = [self getTournaments];
}


- (IBAction)cteateNewTournament:(id)sender {
    if([self.currentUser isDictor])
        [self performSegueWithIdentifier:@"toCreateNewTournament" sender:self];
    else
        [self performSegueWithIdentifier:@"toAddNewTournamentForTeam" sender:self];

}

- (IBAction)logOut:(id)sender {
    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"YourAppLogin" accessGroup:nil];

    [keychainItem resetKeychainItem];
    //self.currentUser = nil;
       
    [self performSegueWithIdentifier:@"toStart" sender:self];

    
}

-(NSMutableArray*)getTournaments{
    __block NSMutableArray *newTours = [NSMutableArray new];
    
    PFQuery * teamQuery = [PFQuery queryWithClassName:@"AppUser"];
    [teamQuery whereKey:@"objectId" equalTo:self.currentUser.userID];
    PFObject *team = [teamQuery findObjects][0];
    
    PFQuery * objectsQuery = [PFQuery queryWithClassName:@"Tournament"];
    [objectsQuery whereKey:@"teams" equalTo:team];
    [objectsQuery findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError *error){
     for(int i=0; i<objects.count; i++){
         Tournament *tour = [Tournament new];
         tour.title = objects[i][@"title"];
         tour.dateOfUpdate = [objects[i] updatedAt];
         tour.dictroId = objects[i][@"dictorID"];
         tour.tournamentId = [objects[i] objectId];
         tour.curMatch = [objects[i][@"currentMatch"] intValue];
         

         [newTours addObject:tour];
     
     }
        [self.tableView reloadData];
     
     }];
        return newTours;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}

# pragma marks - tableViewv data
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.currentUser.tournaments.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 130;
}   

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //where indexPath.row is the selected cell
  
    self.currentUser.curTournament = [self.currentUser.tournaments objectAtIndex:indexPath.row];
     //NSLog(@"tour= %@", self.currentUser.curTournament.dateOfUpdate);
    
    [self performSegueWithIdentifier:@"fromMainToDictorTournament" sender:self];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

        PFQuery *questionsQuery = [PFQuery queryWithClassName:@"Question"];
        [questionsQuery whereKey:@"tournamentId" equalTo:[self.currentUser.tournaments[indexPath.row] tournamentId]];
        [questionsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
            if (!error) {
                [[self.currentUser.tournaments[indexPath.row] questions] setArray:(NSMutableArray *)objects];
                //[self.tableView reloadData];
                }
            else{
                NSLog(@"%@", error);
            }
        }];
    
    ListOfTournamentsCell *cell = (ListOfTournamentsCell*)[tableView dequeueReusableCellWithIdentifier:@"tournamentCell"];
    cell.numberOfQuestions.text = [NSString stringWithFormat:@" %i", (int)[[[self.currentUser.tournaments objectAtIndex:indexPath.row] questions] count] ];
    
      
   // if (indexPath.row < self.currentUser.tournaments.count) {
        
        cell.tournamentName.text =[[self.currentUser.tournaments objectAtIndex:indexPath.row] title] ;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy.MM.dd"];
    
        [cell.date setText:[NSString stringWithFormat:@"%@", [formatter stringFromDate:[[self.currentUser.tournaments objectAtIndex:indexPath.row] dateOfUpdate]]] ];
    //}
    return cell;
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
