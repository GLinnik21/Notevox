//
//  NVMasterViewController.h
//  Notevox
//
//  Created by Глеб Линник on 19.01.17.
//  Copyright © 2017 ARobot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "NVReminder+Add.h"
#import <AVFoundation/AVFoundation.h>

@class NVDetailViewController;

@interface NVMasterViewController : UITableViewController <UITextFieldDelegate, NSFetchedResultsControllerDelegate, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating, AVAudioRecorderDelegate, AVAudioPlayerDelegate>

@property (strong, nonatomic) NVDetailViewController *detailViewController;

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) UISearchController *searchController;

@end

