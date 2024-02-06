//
//  GuestViewController.m
//  GameOfBrains
//
//  Created by Student on 11.12.15.
//  Copyright © 2015 Student. All rights reserved.
//

#import "GuestViewController.h"
#import "GuestCell.h"
#import "Tournament.h"
#import "Reachability.h"


@interface GuestViewController ()
{
    Reachability *internetReachableFoo;
}
// @property (strong, nonatomic) IBOutlet UITableView *tableView;
@property __block NSMutableDictionary *dictors;
@property UIRefreshControl * refreshControl;



@end

@implementation GuestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.currentUser = [AppUser sharedInstance];
    //AppUser *user = [AppUser new];
   // self.currentUser  = nil;
    
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    // [self testInternetConnection];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Tournament"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        self.currentUser.tournaments = (NSMutableArray*)objects;
        [self uploadDictorsWithIDs];
        [self.tableView reloadData];
        
    }];
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
           [self.refreshControl endRefreshing];
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




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma marks - Parse calling
-(void)uploadDictorsWithIDs{
    self.dictors = [NSMutableDictionary new];
    PFQuery *query = [PFQuery queryWithClassName:@"AppUser"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        for (int i=0; i<objects.count; i++) {
            [self.dictors setObject:objects[i][@"login"] forKey:[objects[i] objectId]];
        }
        [self.tableView reloadData];
        
    }];
    
    
}


- (IBAction)logOut:(id)sender {
    self.currentUser = nil;

    
    [self performSegueWithIdentifier:@"toGuestStart" sender:self];
}


#pragma mark - Table view data source

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 130;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (int)self.currentUser.tournaments.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GuestCell *cell = (GuestCell *)[tableView dequeueReusableCellWithIdentifier:@"guestCell" forIndexPath:indexPath];
    
    if (indexPath.row < self.currentUser.tournaments.count) {
        
        cell.tounamentNameLabel.text =[self.currentUser.tournaments objectAtIndex:indexPath.row][@"title"] ;
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy.MM.dd"];
        
        [cell.dateLabel setText:[NSString stringWithFormat:@"%@", [formatter stringFromDate:[[self.currentUser.tournaments objectAtIndex:indexPath.row] updatedAt]]]];
       
        cell.dictorNameLabel.text = [self.dictors objectForKey:self.currentUser.tournaments[indexPath.row][@"dictorID"]];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //where indexPath.row is the selected cell
    
    Tournament *tour = [Tournament new];
    tour.title = self.currentUser.tournaments[indexPath.row][@"title"];
    tour.dateOfUpdate = [self.currentUser.tournaments[indexPath.row] updatedAt];
    tour.dictroId = self.currentUser.tournaments[indexPath.row][@"dictorID"];
    tour.goneAt = self.currentUser.tournaments[indexPath.row][@"goneAt"];
    tour.tournamentId = [self.currentUser.tournaments[indexPath.row] objectId];
    
    self.currentUser.curTournament = tour;
    
    PFQuery *questionsQuery = [PFQuery queryWithClassName:@"Question"];
    [questionsQuery whereKey:@"tournamentId" equalTo:[tour tournamentId]];
    [questionsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if (!error) {
            [[self.currentUser.curTournament questions] setArray:(NSMutableArray *)objects];
            //[self.tableView reloadData];
        }
        else{
            NSLog(@"%@", error);
        }
    }];
    
    
    
    //NSLog(@"tour= %@", self.currentUser.curTournament.dateOfUpdate);
    
    [self performSegueWithIdentifier:@"toGuestTour" sender:self];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
