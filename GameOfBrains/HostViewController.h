//
//  HostViewController.h
//  GameOfBrains
//
//  Created by Student on 16.02.16.
//  Copyright © 2016 Student. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HostViewController;

@protocol HostViewControllerDelegate <NSObject>

- (void)hostViewControllerDidCancel:(HostViewController *)controller;

@end


@interface HostViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
@property (nonatomic, weak) id <HostViewControllerDelegate> delegate;


@end
