//
//  NVDetailViewController.h
//  Notevox
//
//  Created by Linnik Gleb on 19.01.17.
//  Copyright © 2017 A&K. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NVReminder+Add.h"
#import <CoreData/CoreData.h>

@interface NVDetailViewController : UITableViewController <UITextFieldDelegate>

@property (weak) NVReminder *reminder;

@end

