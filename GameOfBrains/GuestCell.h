//
//  GuestCell.h
//  GameOfBrains
//
//  Created by Student on 12.12.15.
//  Copyright © 2015 Student. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GuestCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *dictorNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *tounamentNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *numberOfQuestionsLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;

@end
