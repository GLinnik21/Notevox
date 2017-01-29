//
//  NVCustomTableViewCell.h
//  Notevox
//
//  Created by Глеб Линник on 19.01.17.
//  Copyright © 2017 ARobot. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NVCustomTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UITextField *taskTextView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *creationLabel;

@property (weak, nonatomic) IBOutlet UIButton *playButton;
- (IBAction)playReminder:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *playingProgress;

@end
