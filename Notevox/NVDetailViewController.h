//
//  NVDetailViewController.h
//  Notevox
//
//  Created by Глеб Линник on 19.01.17.
//  Copyright © 2017 ARobot. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NVDetailViewController : UITableViewController <UITextFieldDelegate>

@property (strong, nonatomic) NSDate *detailItem;
@property (weak, nonatomic) IBOutlet UITextField *taskDescription;
@property (weak, nonatomic) IBOutlet UIDatePicker *remindDatePicker;

@end

