//
//  MatchDictorController.m
//  GameOfBrains
//
//  Created by Student on 21.11.15.
//  Copyright (c) 2015 Student. All rights reserved.
//

#import "MatchDictorController.h"

@interface MatchDictorController ()
@property (strong, nonatomic) IBOutlet UILabel *firstTeamLabel;
@property (strong, nonatomic) IBOutlet UILabel *secondTeamLabel;
@property (strong, nonatomic) IBOutlet UILabel *questionLabel;
@property (strong, nonatomic) IBOutlet UILabel *answerLabel;
@property (strong, nonatomic) IBOutlet UILabel *commentsLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *questionHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *commentsHeight;
@property (strong, nonatomic) IBOutlet UIButton *timerButton;
@property (strong, nonatomic) IBOutlet UIImageView *attachedFileView;
@property (strong, nonatomic) IBOutlet UILabel *firstTeamScoreLabel;
@property (strong, nonatomic) IBOutlet UILabel *secondTeamScoreLabel;


@property int timerState;


@property __block int curMatch;
@property NSMutableArray *questions;

@property int timeTick;
@property NSTimer *timer;
@property NSDate * start_date;

@end

@implementation MatchDictorController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.timerState = 0;
    self.timeTick = 60;
    
    self.navigationItem.hidesBackButton = YES;
    
    self.questions = [NSMutableArray new];
    self.currecntUser = [AppUser sharedInstance];
    self.curMatch = self.currecntUser.curTournament.curMatch;
    self.firstTeamLabel.text = self.currecntUser.curTournament.matches[self.curMatch][@"firstTeamName"];
    self.secondTeamLabel.text = self.currecntUser.curTournament.matches[self.curMatch][@"secondTeamName"];
    
    [self uploadQuestions];
    
}
- (IBAction)letTeamsToAnswer:(id)sender {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Match"];
    [query getObjectInBackgroundWithId:[self.currecntUser.curTournament.matches[self.currecntUser.curTournament.curMatch] objectId] block:^(PFObject *match, NSError *error){
    
        UIAlertView *alert1 = [[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"Отвечает %@", match[@"firstTeamName"]]
                                                       delegate:self cancelButtonTitle:@"Зачет" otherButtonTitles:@"Незачет", nil];
        
        UIAlertView *alert2 = [[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"Отвечает %@", match[@"secondTeamName"]]
                                                       delegate:self cancelButtonTitle:@"Зачет" otherButtonTitles:@"Незачет", nil];
        
        UIAlertView *alert_fs1 = [[UIAlertView alloc] initWithTitle:@"" message: [NSString stringWithFormat:@"FalseStart - %@", match[@"firstTeamName"]]
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        UIAlertView *alert_fs2 = [[UIAlertView alloc] initWithTitle:@"" message: [NSString stringWithFormat:@"FalseStart - %@", match[@"secondTeamName"]]
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles: nil];
        
        NSTimeInterval isFalseStart1;
        NSTimeInterval isFalseStart2;
        
        if (match[@"firstTeamTime"] != nil) {
             isFalseStart1 = [ match[@"firstTeamTime"] timeIntervalSinceDate:self.start_date];
        }else{
            isFalseStart1 = 1;
        }
    
        if (match[@"secondTeamTime"] != nil) {
            isFalseStart2 = [ match[@"secondTeamTime"] timeIntervalSinceDate:self.start_date];
            NSLog(@"%@", match[@"secondTeamTime"]);
           
        }else{
            isFalseStart2 = 1;
        }
        
        
        
        if (match[@"firstTeamTime"]==nil && match[@"secondTeamTime"]==nil ) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message: @"Команды не отвечают"
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles: nil];
            [alert show];
        }
        else if (match[@"firstTeamTime"]==nil && match[@"secondTeamTime"]!= nil) {
            self.teamToAnswer = 2;
            //NSTimeInterval isFalseStart = [ match[@"secondTeamTime"] timeIntervalSinceDate:self.start_date];
            
            if (isFalseStart2 >=0) {
                    [alert2 show];
            
            }
            else{
                [alert_fs2 show];
            }
      
            
        }
        else if (match[@"secondTeamTime"]==nil && match[@"firstTeamTime"]!=nil) {
            self.teamToAnswer = 1;
            
            //NSTimeInterval isFalseStart = [ match[@"firstTeamTime"] timeIntervalSinceDate:self.start_date];
            if (isFalseStart1 >= 0) {
                [alert1 show];
            }
            else{
                
                [alert_fs1 show];
                
            }
            
        }
        
        else {                // two teams should answer
          
            NSTimeInterval distanceBetweenDates = [ match[@"firstTeamTime"] timeIntervalSinceDate:match[@"secondTeamTime"]];
          //  NSTimeInterval isFalseStart1 = [ match[@"firstTeamTime"] timeIntervalSinceDate:self.start_date];
          //  NSTimeInterval isFalseStart2 = [ match[@"secondTeamTime"] timeIntervalSinceDate:self.start_date];

            // both team falsestart
            if (isFalseStart1 < 0 && isFalseStart2 <0){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message: [NSString stringWithFormat:@"FalseStart - %@ и %@", match[@"secondTeamName"], match[@"firstTeamName"]]
                                                                   delegate:self
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles: nil];
                [alert show];
            }
            
            // only first team false start
            else if (isFalseStart1 < 0 && isFalseStart2 >=0){
                self.teamToAnswer = 2;
                [alert2 show];
            }
            // only second team false start
            else if (isFalseStart1 >= 0 && isFalseStart2 < 0){
                self.teamToAnswer = 1;
                [alert1 show];
            }
            else{ // no false starts
                if (  distanceBetweenDates < 0) {
                   
                        self.teamToAnswer = 1;
                        [alert2 show];
                        [alert1 show];
                    
                    
                    
                }else if ( distanceBetweenDates > 0){
                    
                        self.teamToAnswer = 2;
                        [alert1 show];
                        [alert2 show];
                    
                    
                } else{
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message: @"Равное время! Переигровка."
                                                                   delegate:self
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles: nil];
                    
                    [alert show];
                    
                    
                }
            
            }
            
            
        }
    }];
    
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0){
        //зачет
        if (self.teamToAnswer == 1) {
            self.firstTeamScore ++;
            
        }else if (self.teamToAnswer == 2){
        
            self.secondTeamScore ++;
        }
        
        self.firstTeamScoreLabel.text = [NSString stringWithFormat:@" %i", self.firstTeamScore];
        self.secondTeamScoreLabel.text = [NSString stringWithFormat:@" %i", self.secondTeamScore];
        
        self.teamToAnswer = 0;
    }
    
    else if (buttonIndex == 1){
        
            [self.timer invalidate];
            self.timeTick = 20;
            self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(startTicker) userInfo:nil repeats:YES];
            self.timerState = 1;
        
        if (self.teamToAnswer == 1) {
            self.teamToAnswer = 2;
        } else if (self.teamToAnswer == 2){
            self.teamToAnswer = 1;
        }
        
        
    }
 
    self.start_date = nil;
    PFQuery * query = [PFQuery queryWithClassName:@"Match"];
    [query getObjectInBackgroundWithId:[self.currecntUser.curTournament.matches[self.currecntUser.curTournament.curMatch] objectId] block:^(PFObject *match, NSError *error){
        
        [match removeObjectForKey:@"firstTeamTime"];
        [match removeObjectForKey:@"secondTeamTime"];
        
        
        [match saveInBackgroundWithBlock:^(BOOL success, NSError *error){
            if (success) {
                
            } else{
                NSLog(@"%@",error);
            }
        }];
        
    }];
}

- (IBAction)timerButton:(id)sender {
    if (self.timerState == 0) { // start
        self.timeTick = 60;
        [self.timer invalidate];
        
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(startTicker) userInfo:nil repeats:YES];
        self.timerState = 1;
        
        // for catch falsestart
        self.start_date = [NSDate date];
        
    }else if (self.timerState == 1) { //pause
        [self.timer invalidate];
        //self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(startTicker) userInfo:nil repeats:YES];
        self.timerState = 0;
    }
    
}

-(void)startTicker{
    
    self.timeTick--;
    //self.timerButton.titleLabel.text = [NSString stringWithFormat:@"%d", self.timeTick];
    [self.timerButton setTitle:[NSString stringWithFormat:@"%d", self.timeTick] forState:UIControlStateNormal];
    
    if (self.timeTick == 0) {
        [self.timer invalidate];
        
    }
}


- (IBAction)goToAnotherQuestion:(id)sender {
    if ([sender tag] == 0) {
        
        --self.currecntUser.curTournament.curQuestion;
        if (self.currecntUser.curTournament.curQuestion < 0) {
            self.currecntUser.curTournament.curQuestion = (int)self.currecntUser.curTournament.questions.count - 1;
        }
        [self showQuestions];
        
    }else if([sender tag] == 1){
        ++self.currecntUser.curTournament.curQuestion;
        if (self.currecntUser.curTournament.curQuestion > self.currecntUser.curTournament.questions.count-1) {
            self.currecntUser.curTournament.curQuestion = 0;
        }
        [self showQuestions];
    }
    
}

- (IBAction)matchCompleted:(id)sender {
    PFQuery * query = [PFQuery queryWithClassName:@"Match"];
    [query getObjectInBackgroundWithId:[self.currecntUser.curTournament.matches[self.currecntUser.curTournament.curMatch] objectId] block:^(PFObject *match, NSError *error){
        
        match[@"firstTeamScore"] = [NSNumber numberWithInt:self.firstTeamScore];
        match[@"secondTeamScore"] = [NSNumber numberWithInt:self.secondTeamScore];
        
        match[@"inProcess"] = @NO;
        
        [match removeObjectForKey:@"firstTeamTime"];
        [match removeObjectForKey:@"secondTeamTime"];
        
        
        
        PFQuery *query2 = [PFQuery queryWithClassName:@"Tournament"];
        
        
        
        [match saveInBackgroundWithBlock:^(BOOL success, NSError *error){
            if (success) {
                
                self.currecntUser.curTournament.curMatch++;
                if (self.currecntUser.curTournament.curMatch == (int)self.currecntUser.curTournament.matches.count) {
                    self.currecntUser.curTournament.curMatch = 0;
                }
                [query2 getObjectInBackgroundWithId:self.currecntUser.curTournament.tournamentId block:^(PFObject *tour, NSError *error){
                    tour[@"currentMatch"] = [NSNumber numberWithInt:self.currecntUser.curTournament.curMatch];
                    [tour saveInBackgroundWithBlock:^(BOOL success, NSError *error){
                        
                        [self.navigationController popViewControllerAnimated:TRUE];
                        
                        // [self performSegueWithIdentifier:@"backToDictorTour" sender:self];
                    }];
                    
                    
                    
                    
                    //[self.navigationController popViewControllerAnimated:TRUE];
                    
                }];
                
            } else{
                NSLog(@"%@",error);
            }
        }];
        
    }];
    
}


-(void)uploadQuestions{
    PFQuery *questionsQuery = [PFQuery queryWithClassName:@"Question"];
    [questionsQuery whereKey:@"tournamentId" equalTo:self.currecntUser.curTournament.tournamentId];
    [questionsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if (!error) {
            self.questions  = (NSMutableArray *)objects;
            self.currecntUser.curTournament.questions = self.questions;
            [self showQuestions];
        }else{
            NSLog(@"%@", error);
        }
    }];
}

-(void)showQuestions{
  
    
    //self.questionHeight = ;
    self.questionHeight.constant = [Utils getHeightForString:self.questions[self.currecntUser.curTournament.curQuestion][@"questionBody"] forWidth:self.questionLabel.frame.size.width];
    self.questionLabel.text = self.questions[self.currecntUser.curTournament.curQuestion][@"questionBody"];
    
    self.answerLabel.text = self.questions[self.currecntUser.curTournament.curQuestion][@"answer"];
    
    NSLog(@"%@", self.questions[self.currecntUser.curTournament.curQuestion][@"Comments"]);
    if(self.questions[self.currecntUser.curTournament.curQuestion][@"Comments"] ==nil){
        self.questions[self.currecntUser.curTournament.curQuestion][@"Comments"]= @"";
    }
    
    self.commentsLabel.text = self.questions[self.currecntUser.curTournament.curQuestion][@"Comments"];
    self.commentsHeight.constant =  [Utils getHeightForString:self.questions[self.currecntUser.curTournament.curQuestion][@"Comments"] forWidth: self.commentsLabel.frame.size.width];
    
    PFFile *attachedPhoto = self.questions[self.currecntUser.curTournament.curQuestion][@"attachedFile"];
    if (attachedPhoto == nil || [attachedPhoto isKindOfClass:[NSNull class]]) {
        self.attachedFileView.hidden =YES;

    }else{
        [attachedPhoto getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error){
            if (!error) {
                self.attachedFileView.hidden =NO; 
                __block UIImage * image = [UIImage imageWithData:imageData];
                [self.attachedFileView setImage:image];
                
                PFQuery *uploadFileQuery = [PFQuery queryWithClassName:@"Match"];
               // uploadFileQuery whereKey: containedIn:<#(NSArray *)#>
               
                [uploadFileQuery getObjectInBackgroundWithId:[self.currecntUser.curTournament.matches[self.curMatch] objectId] block:^(PFObject *object, NSError *error){
                    if (!error) {
                        NSLog(@"%@", (PFFile*)image  );
                        object[@"attachedFile"] = [PFFile fileWithName:@"attachedImage" data:imageData];
                        
                        NSLog(@"%@", object[@"attachedFile"] );
                        [object saveInBackgroundWithBlock:^(BOOL success, NSError *error ){
                            if (success) {
                                NSLog(@"attached");
                            } else {
                                NSLog(@"%@",error);
 
                            }
                        }];
                      
                    }else{
                        NSLog(@"%@",error);
                    }
                
                }];
            
            }
            else{
                NSLog(@"ERROR: %@", error);
            }
        }];
    }
    
    //
    
}

/*-(double)getHeightForString:(NSString *) text forWidth:(double)width{
    CGSize constrainedSize = CGSizeMake( width , 9999);
    
    NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [UIFont fontWithName:@"HelveticaNeue" size:13.0], NSFontAttributeName,
                                          nil];
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:text attributes:attributesDictionary];
    
    CGRect requiredHeight = [string boundingRectWithSize:constrainedSize options:NSStringDrawingUsesLineFragmentOrigin context:nil];
 
    if (requiredHeight.size.width > self.questionLabel.frame.size.width) {
        requiredHeight = CGRectMake(0,0, self.questionLabel.frame.size.width, requiredHeight.size.height);
    }
    
    return requiredHeight.size.height;
    
}
*/
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
