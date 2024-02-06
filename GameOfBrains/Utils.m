//
//  Utils.m
//  GameOfBrains
//
//  Created by Student on 22.11.15.
//  Copyright (c) 2015 Student. All rights reserved.
//

#import "Utils.h"

@implementation Utils


+(double)getHeightForString:(NSString *) text forWidth:(double)width{
    CGSize constrainedSize = CGSizeMake( width , 9999);
    
    NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [UIFont fontWithName:@"HelveticaNeue" size:13.0], NSFontAttributeName,
                                          nil];
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:text attributes:attributesDictionary];
    
    CGRect requiredHeight = [string boundingRectWithSize:constrainedSize options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    /*
     if (requiredHeight.size.width > self.questionLabel.frame.size.width) {
     requiredHeight = CGRectMake(0,0, self.questionLabel.frame.size.width, requiredHeight.size.height);
     }*/
    
    return requiredHeight.size.height+25;
    
}

@end
