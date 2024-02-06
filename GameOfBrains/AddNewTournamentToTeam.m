//
//  AddNewTournamentToTeam.m
//  GameOfBrains
//
//  Created by Student on 17.11.15.
//  Copyright (c) 2015 Student. All rights reserved.
//

#import "AddNewTournamentToTeam.h"
#import "Tournament.h"
#import "DictorMainController.h"

@interface AddNewTournamentToTeam ()

//@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property __block NSMutableArray *tours;
@property __block NSMutableDictionary *dictors;


@end

@implementation AddNewTournamentToTeam

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.tours = [NSMutableArray new];
    self.dictors = [NSMutableDictionary new];
    self.currentUser = [AppUser sharedInstance];
    //self.tours = [self.currentUser getNewTournamentsForTeamById:self.currentUser.userID];
    [self uploadTournaments];
    [self uploadDictorsWithIDs];
    

    
}

#pragma marks - Parse calling
-(void)uploadDictorsWithIDs{
    
    PFQuery *query = [PFQuery queryWithClassName:@"AppUser"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        for (int i=0; i<objects.count; i++) {
            [self.dictors setObject:objects[i][@"login"] forKey:[objects[i] objectId]];
        }
        [self.tableView reloadData];
    
    }];
    
    
}

-(void) uploadTournaments{
    //__block NSMutableArray *tournaments1 = [NSMutableArray new];
    
    PFQuery * teamQuery = [PFQuery queryWithClassName:@"AppUser"];
    [teamQuery whereKey:@"objectId" equalTo:self.currentUser.userID];
    
    PFQuery * objectsQuery = [PFQuery queryWithClassName:@"Tournament"];
    [objectsQuery whereKey:@"teams" doesNotMatchQuery:teamQuery];
     [objectsQuery findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError *error){
     
         for(int i=0; i<objects.count; i++){
             Tournament *tour = [Tournament new];
             tour.title = objects[i][@"title"];
             tour.dateOfUpdate = [objects[i] updatedAt];
             tour.dictroId = objects[i][@"dictorID"];
             tour.tournamentId = [objects[i] objectId];
             
             [self.tours addObject:tour];
         }
         [self.tableView reloadData];
     }];

}

-(NSMutableArray*)getTournaments{
    __block NSMutableArray *newTours = [NSMutableArray new];
    
    PFQuery * teamQuery = [PFQuery queryWithClassName:@"AppUser"];
    [teamQuery whereKey:@"objectId" equalTo:self.currentUser.userID];
    //PFObject *team = [teamQuery findObjects][0];
    
    PFQuery * objectsQuery = [PFQuery queryWithClassName:@"Tournament"];
    [objectsQuery whereKey:@"teams" matchesQuery:teamQuery];
    [objectsQuery findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError *error){
        for(int i=0; i<objects.count; i++){
            Tournament *tour = [Tournament new];
            tour.title = objects[i][@"title"];
            tour.dateOfUpdate = [objects[i] updatedAt];
            tour.dictroId = objects[i][@"dictorID"];
            tour.tournamentId = [objects[i] objectId];
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

#pragma mark - Table view data source

/*- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}*/
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //where indexPath.row is the selected cell
    __block PFObject *team = [PFObject objectWithClassName:@"AppUser"];

    PFQuery *query = [PFQuery queryWithClassName:@"AppUser"];
    [query whereKey:@"objectId" equalTo:self.currentUser.userID];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error){
        team = object;
       
        // NSLog(@" %@", [team objectId]);
        
        PFQuery *query2 = [PFQuery queryWithClassName:@"Tournament"];
        [query2 whereKey:@"objectId" equalTo:[self.tours[indexPath.row] tournamentId]];
        
        NSLog(@" %@" ,[self.tours[indexPath.row] tournamentId]);
        
        [query2 getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error){
            PFRelation *relation = [object relationForKey:@"teams"];
            [relation addObject:team];
            [object saveInBackground];
           
            self.currentUser.tournaments = [self.currentUser getTournamentsForTeamById:self.currentUser.userID];
        }];
        [self.tableView reloadData];
       
    }];

    self.currentUser.tournaments = [self.currentUser getTournamentsForTeamById:self.currentUser.userID];
    [self.navigationController popViewControllerAnimated:TRUE];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return self.tours.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 130;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ToAddNewTournamentCell *cell = (ToAddNewTournamentCell*)[tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (indexPath.row < self.tours.count) {
        
        cell.tounamentNameLabel.text =[[self.tours objectAtIndex:indexPath.row] title] ;
        [cell.dateLabel setText:[NSString stringWithFormat:@"%@", [[self.tours objectAtIndex:indexPath.row] dateOfUpdate]]];
        cell.numberOfQuestionsLabel.text= [NSString stringWithFormat:@"%lu", [self.tours[indexPath.row] questions].count];
        cell.dictorNameLabel.text = [self.dictors objectForKey:[self.tours[indexPath.row] dictroId]];
    }
   
    return cell;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

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
