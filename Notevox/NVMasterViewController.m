//
//  NVNVMasterViewController.m
//  Notevox
//
//  Created by Глеб Линник on 19.01.17.
//  Copyright © 2017 ARobot. All rights reserved.
//

#import "NVMasterViewController.h"
#import "NVDetailViewController.h"
#import "NVCustomTableViewCell.h"
#include "NVAppDelegate.h"

@interface NVMasterViewController ()

@end

@implementation NVMasterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
    self.detailViewController = (NVDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
}


- (void)viewWillAppear:(BOOL)animated {
    self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;

    [self initializeFetchedResultsController];
    [super viewWillAppear:animated];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self textFieldDidEndEditing:textField];
    return [textField resignFirstResponder];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NVCustomTableViewCell *sellectedCell = (NVCustomTableViewCell *)textField.superview.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sellectedCell];
    NVReminder *reminder = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if (textField.text.length > 0) {
        reminder.reminderTitle = textField.text;
    } else {
        [textField setText:reminder.reminderTitle];
    }

}

- (NSString *)formateDateStringfromDate:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [NSLocale currentLocale];
    dateFormatter.timeZone = [NSTimeZone systemTimeZone];
    dateFormatter.dateFormat = @"dd.MM.yy, HH:mm";
    return [dateFormatter stringFromDate:date];
}

- (void)insertNewObject:(id)sender {
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    
    NVReminder *newReminder = [NSEntityDescription insertNewObjectForEntityForName:@"Reminder" inManagedObjectContext:context];
    
    static int count = 0;
    newReminder.reminderTitle = [NSString stringWithFormat:@"%i cell", count];
    newReminder.dateToRemind = [NSDate date];
    newReminder.audioFileURL = @"/dev/null";
    count++;
    
    NSError *error = nil;
    if (![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}


- (void)initializeFetchedResultsController {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Reminder"];
    
    NSSortDescriptor *lastNameSort = [NSSortDescriptor sortDescriptorWithKey:@"dateToRemind" ascending:YES];
    
    [request setSortDescriptors:@[lastNameSort]];
    
    NVAppDelegate *appDelegate = (NVAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = [[appDelegate dataController] managedObjectContext]; //Retrieve the main queue NSManagedObjectContext
    
    [self setFetchedResultsController:[[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:moc sectionNameKeyPath:nil cacheName:nil]];
    [[self fetchedResultsController] setDelegate:self];
    
    NSError *error = nil;
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Failed to initialize FetchedResultsController: %@\n%@", [error localizedDescription], [error userInfo]);
        abort();
    }
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        NVReminder *reminder = [self.fetchedResultsController objectAtIndexPath:indexPath];
        NVDetailViewController *controller = (NVDetailViewController *)[[segue destinationViewController] topViewController];
        [controller setReminder:reminder];
    }
}
/*
-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    self.accessoryIndexPath = indexPath;
}
*/
#pragma mark - Table View

- (void)configureCell:(NVCustomTableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath {
    NVReminder *reminder = (NVReminder*)[[self fetchedResultsController] objectAtIndexPath:indexPath];
    
    cell.taskTextView.text = reminder.reminderTitle;
    cell.dateLabel.text = [self formateDateStringfromDate:reminder.dateToRemind];
    cell.timeLabel.text = @"0:00";
    
    if ([reminder.dateToRemind compare:[NSDate date]] == NSOrderedAscending) {
        cell.dateLabel.textColor = [UIColor redColor];
    } else {
        cell.dateLabel.textColor = [UIColor blackColor];;
    }

    
    [cell.taskTextView setDelegate:self];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[[self fetchedResultsController] sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id< NSFetchedResultsSectionInfo> sectionInfo = [[self fetchedResultsController] sections][section];
    return [sectionInfo numberOfObjects];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NVCustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReminderCell"];
    // Set up the cell
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        NSError *error = nil;
        if (![context save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, error.userInfo);
            abort();
        }
    }
}

#pragma mark - NSFetchedResultsControllerDelegate
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [[self tableView] beginUpdates];
}
- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [[self tableView] insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [[self tableView] deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeMove:
        case NSFetchedResultsChangeUpdate:
            break;
    }
}
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [[self tableView] insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [[self tableView] deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[[self tableView] cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
        case NSFetchedResultsChangeMove:
            [[self tableView] deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [[self tableView] insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [[self tableView] endUpdates];
}

@end
