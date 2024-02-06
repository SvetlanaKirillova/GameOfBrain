//
//  RegistrationController.m
//  GameOfBrains
//
//  Created by Student on 17.12.15.
//  Copyright © 2015 Student. All rights reserved.
//

#import "RegistrationController.h"

@interface RegistrationController ()
@property (strong, nonatomic) IBOutlet UITextField *loginText;
@property (strong, nonatomic) IBOutlet UITextField *passwordText;
@property (strong, nonatomic) IBOutlet UITextField *confirmPasswordText;
@property (strong, nonatomic) IBOutlet UISwitch *isDictor;

@end

@implementation RegistrationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];

    
}
-(void)dismissKeyboard {
    [self.loginText resignFirstResponder];
    [self.passwordText resignFirstResponder];
    [self.confirmPasswordText resignFirstResponder];
}

- (IBAction)signUp:(id)sender {
    
    if ([self.loginText.text isEqualToString:@""]) {
        [[[UIAlertView alloc] initWithTitle:@"Fail"
                                    message:@"Введите логин."
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];

    }
    else if ([self.passwordText.text isEqualToString:@""]){
        [[[UIAlertView alloc] initWithTitle:@"Fail"
                                    message:@"Введите пароль."
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    } else if (![self.passwordText.text isEqualToString:self.confirmPasswordText.text]){
        [[[UIAlertView alloc] initWithTitle:@"Fail"
                                    message:@"Пароли не совпадают."
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
    else{
        
        PFQuery * query = [PFQuery queryWithClassName:@"AppUser"];
        [query whereKey:@"login" equalTo:self.loginText.text];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError* error){
            
            if ((int)objects.count == 0) {
                PFObject *user = [PFObject objectWithClassName:@"AppUser"];
                user[@"login"] = self.loginText.text;
                user[@"password"] = self.passwordText.text;
                if (self.isDictor.isOn) {
                    user[@"isDictor"] = @1;
                }
                else{
                    user[@"isDictor"] = @0;
                }
                
                [user saveInBackgroundWithBlock:^(BOOL success, NSError *error){
                    
                    if (success) {
                        /*[[[UIAlertView alloc] initWithTitle:@""
                                                    message:@"Вы успешно зарегистрированы."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil] show];
                        [self.navigationController popToRootViewControllerAnimated:YES];*/
                        
                            [self performSegueWithIdentifier:@"back" sender:self];

                    }
                }];
            }
            else{ // user with such login already exist
                
                [[[UIAlertView alloc] initWithTitle:@"Fail"
                                            message:@"Пользователь с таким логином уже существует."
                                           delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil] show];
            }
            
        }];

    }
    
    
}
- (IBAction)cancel:(id)sender {
    [self performSegueWithIdentifier:@"back" sender:self];

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
