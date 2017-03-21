//
//  NVDetailViewController.h
//  Notevox
//
//  Created by Глеб Линник on 19.01.17.
//  Copyright © 2017 ARobot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NVReminder+Add.h"
#import <CoreData/CoreData.h>

@interface NVDetailViewController : UITableViewController <UITextFieldDelegate>

@property (weak) NVReminder *reminder;

@end

