//
//  ViewController.m
//  GameOfBrains
//
//  Created by Student on 10.11.15.
//  Copyright (c) 2015 Student. All rights reserved.
//

#import "ViewController.h"
#import "Tournament.h"
#import "KeychainItemWrapper.h"

@interface ViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *logoImage;
@property (strong, nonatomic) IBOutlet UITextField *loginInput;
@property (strong, nonatomic) IBOutlet UITextField *passwordInput;
@property AppUser *currentUser;
//@property Team * currentTeam;

@end

@implementation ViewController
- (IBAction)signInAction:(id)sender {
    
    [self canUserLogIn:self.loginInput.text withPass:self.passwordInput.text];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.hidesBackButton = YES;
   /* PFObject *testObject = [PFObject objectWithClassName:@"TestObject"];
    testObject[@"foo"] = @"bar";
    [testObject saveInBackground];*/
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
   
  
}



# pragma marks - Keyboard dismissing
-(void)dismissKeyboard {
    [self.loginInput resignFirstResponder];
    [self.passwordInput resignFirstResponder];
}
/*-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}*/

- (IBAction)loginAsGuest:(id)sender {
    self.currentUser = [AppUser sharedInstance];
    PFQuery *query = [PFQuery queryWithClassName:@"AppUser"];
    [query getObjectInBackgroundWithId:@"GR7WNSjPSH" block:^(PFObject *user, NSError *error){
        self.currentUser.login = user[@"login"];
        self.currentUser.password = user[@"password"];
        self.currentUser.userID = [user objectId];
        self.currentUser.isDictor = 0;
        self.currentUser.curTournament = [Tournament new];
        self.currentUser.tournaments = [NSMutableArray new];
        [self performSegueWithIdentifier:@"loginAsGuest" sender:self];
    }];
    
    
}

- (IBAction)register:(id)sender {
    
     [self performSegueWithIdentifier:@"toRegister" sender:self];
    
}


-(BOOL)canUserLogIn:(NSString*)login withPass:(NSString*)password{
  
        PFQuery * query = [PFQuery queryWithClassName:@"AppUser"];
        [query whereKey:@"login" equalTo:login];

        [query findObjectsInBackgroundWithBlock:^(NSArray * objects ,NSError *error){
            if(!error){
                if(objects.count == 1){
                    if([[objects[0] objectForKey:@"password"] isEqualToString:password]){
                     
                        self.currentUser = [AppUser sharedInstance];
                        self.currentUser.login = objects[0][@"login"];
                        
                        self.currentUser.password = objects[0][@"password"];
                        self.currentUser.userID = [objects[0] objectId];

                        if([objects[0][@"isDictor"] isEqualToNumber:@1]){
                            self.currentUser.isDictor = 1;
                            //set to current user his/her tournaments
                            self.currentUser.tournaments = [self.currentUser getTournamentsForDictorWithId:self.currentUser.userID];
                        }else{
                             self.currentUser.isDictor = 0;
                             self.currentUser.tournaments = [self.currentUser getTournamentsForTeamById:self.currentUser.userID];
                        }
                        
                            KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"YourAppLogin" accessGroup:nil];
                        [keychainItem setObject:self.currentUser.password forKey:kSecValueData];
                        [keychainItem setObject:self.currentUser.login forKey:kSecAttrAccount];

                            [self performSegueWithIdentifier:@"toDictorMain" sender:self];
                      
                        
                        
                    } else{
                        
                        [[[UIAlertView alloc] initWithTitle:@"Fail"
                                                    message:@"Password is incorrect! Try again."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil] show];
                    }
                }else{
                    [[[UIAlertView alloc] initWithTitle:@"Fail"
                                                message:@"Incorrect login!"
                                               delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil] show];
                }
            }
        }];
    
    
    return TRUE;
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
