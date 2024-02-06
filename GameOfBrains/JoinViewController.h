//
//  JoinViewController.h
//  GameOfBrains
//
//  Created by Student on 16.02.16.
//  Copyright © 2016 Student. All rights reserved.
//

#import <UIKit/UIKit.h>
@class JoinViewController;

@protocol JoinViewControllerDelegate <NSObject>

- (void)joinViewControllerDidCancel:(JoinViewController *)controller;

@end

@interface JoinViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, weak) id <JoinViewControllerDelegate> delegate;

@end
