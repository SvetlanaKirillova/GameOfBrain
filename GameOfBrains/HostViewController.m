//
//  HostViewController.m
//  GameOfBrains
//
//  Created by Student on 16.02.16.
//  Copyright © 2016 Student. All rights reserved.
//

#import "HostViewController.h"

@interface HostViewController ()
@property (strong, nonatomic) IBOutlet UILabel *yourNameLabel;
@property (strong, nonatomic) IBOutlet UITableView *teamsTableView;
@property (strong, nonatomic) IBOutlet UIButton *startButton;


@end


@implementation HostViewController

@synthesize delegate = _delegate;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
-(void) viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        // Navigation button was pressed. Do some stuff
        [self.delegate hostViewControllerDidCancel:self];
        
        [self.navigationController popViewControllerAnimated:NO];
    }
    [super viewWillDisappear:animated];
}


- (IBAction)startAction:(id)sender
{
}

- (IBAction)exitAction:(id)sender
{
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
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
