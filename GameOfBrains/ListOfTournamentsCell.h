//
//  listOfTournamentsCell.h
//  GameOfBrains
//
//  Created by Student on 10.11.15.
//  Copyright (c) 2015 Student. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListOfTournamentsCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *tournamentName;
@property (strong, nonatomic) IBOutlet UILabel *numberOfQuestions;
@property (strong, nonatomic) IBOutlet UILabel *date;

@end
