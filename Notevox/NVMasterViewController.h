//
//  NVMasterViewController.h
//  Notevox
//
//  Created by Linnik Gleb on 19.01.17.
//  Copyright © 2017 A&K. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "NVReminder+Add.h"
#import <AVFoundation/AVFoundation.h>
#import <MGSwipeTableCell.h>

@class NVDetailViewController;

@interface NVMasterViewController : UITableViewController <UITextFieldDelegate, NSFetchedResultsControllerDelegate, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating, AVAudioRecorderDelegate, AVAudioPlayerDelegate, MGSwipeTableCellDelegate>

@property (strong, nonatomic) NVDetailViewController *detailViewController;

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) UISearchController *searchController;

@end

