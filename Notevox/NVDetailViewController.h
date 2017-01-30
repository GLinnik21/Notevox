//
//  NVDetailViewController.h
//  Notevox
//
//  Created by Глеб Линник on 19.01.17.
//  Copyright © 2017 ARobot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NVReminder.h"
#import <CoreData/CoreData.h>

@interface NVDetailViewController : UITableViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *taskDescription;
@property (weak, nonatomic) IBOutlet UILabel *remindDateLabel;
@property (weak, nonatomic) IBOutlet UIDatePicker *remindDatePicker;
@property (weak) NVReminder *reminder;
@property (weak, nonatomic) IBOutlet UISwitch *dateToRemindSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *remindWithVoiceSwitch;

@property (weak, nonatomic) IBOutlet UITableViewCell *labelsCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *datePickerCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *remindWithVoiceCell;


@end

