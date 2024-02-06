//
//  AppDelegate.h
//  GameOfBrains
//
//  Created by Student on 10.11.15.
//  Copyright (c) 2015 Student. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KeychainItemWrapper, DetailViewController;


@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    
    KeychainItemWrapper *passwordItem;
    KeychainItemWrapper *accountNumberItem;
}


@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, retain) KeychainItemWrapper *passwordItem;
@property (nonatomic, retain) KeychainItemWrapper *accountNumberItem;

@property (nonatomic, assign) BOOL hasInet;


@end

