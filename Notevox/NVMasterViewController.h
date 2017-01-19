//
//  NVMasterViewController.h
//  Notevox
//
//  Created by Глеб Линник on 19.01.17.
//  Copyright © 2017 ARobot. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NVDetailViewController;

@interface NVMasterViewController : UITableViewController

@property (strong, nonatomic) NVDetailViewController *detailViewController;


@end

