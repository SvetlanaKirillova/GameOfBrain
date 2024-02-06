//
//  Timer.h
//  GameOfBrains
//
//  Created by Student on 23.11.15.
//  Copyright (c) 2015 Student. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Timer : NSObject
@property NSDate *start;
@property double leftTime;

-(void) startCountdown;

@end
