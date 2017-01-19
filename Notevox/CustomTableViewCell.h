//
//  CustomTableViewCell.h
//  Notevox
//
//  Created by Глеб Линник on 19.01.17.
//  Copyright © 2017 ARobot. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UITextField *taskTextView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@property (weak, nonatomic) IBOutlet UIButton *playButton;
- (IBAction)playReminder:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end
