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
#import "NVAppDelegate.h"

//#define LIBRARY_SOUND_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Sounds"]

@interface NVMasterViewController () {
    AVAudioRecorder *recorder;
    AVAudioPlayer *player;
    NSMutableDictionary *recordSetting;
}

@end

@implementation NVMasterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    self.detailViewController = (NVDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadTableView)
                                                 name:@"reloadData"
                                               object:nil];
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = false;
    self.definesPresentationContext = true;
    self.tableView.tableHeaderView = self.searchController.searchBar;
}

- (void)viewWillAppear:(BOOL)animated {
    self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;

    [self initializeFetchedResultsController];
    [self reloadTableView];
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

- (void)rescheduleAllLocalNotifications{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    NSArray *fetchedData = [_fetchedResultsController fetchedObjects];
    
    for (int i = 0; i < fetchedData.count; i++) {
        NVReminder *tempReminder = [fetchedData objectAtIndex:i];
        //Schedule reminders with only valid date
        if (tempReminder.dateToRemind && [tempReminder.dateToRemind compare:[NSDate date]] == NSOrderedDescending) {
            UILocalNotification *localNotification = [[UILocalNotification alloc] init];
            localNotification.fireDate = tempReminder.dateToRemind;
            localNotification.alertBody = tempReminder.reminderTitle;
            localNotification.timeZone = [NSTimeZone defaultTimeZone];
            if (tempReminder.isCustomSound) {
                localNotification.soundName = tempReminder.audioFileURL;
            } else {
                localNotification.soundName = UILocalNotificationDefaultSoundName;
            }
            localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
            [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        }
    }
}

- (NSString *)formateDateStringfromDate:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [NSLocale currentLocale];
    dateFormatter.timeZone = [NSTimeZone systemTimeZone];
    dateFormatter.dateFormat = @"dd.MM.yy, HH:mm";
    return [dateFormatter stringFromDate:date];
}

- (IBAction)startRecording:(id)sender {
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *err = nil;
    [audioSession setCategory :AVAudioSessionCategoryPlayAndRecord error:&err];
    if(err){
        NSLog(@"audioSession: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
        return;
    }
    [audioSession setActive:YES error:&err];
    err = nil;
    if(err){
        NSLog(@"audioSession: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
        return;
    }
    
    recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    
    [recordSetting setValue :[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    [recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
    [recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
    
    
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get Library folder
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"/Sounds"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
    
    // Create a new dated file
    NSString *recorderFilePath = [NSString stringWithFormat:@"%@/%@.caf", dataPath, [NSDate date].description];
    
    NSURL *url = [NSURL fileURLWithPath:recorderFilePath];
    err = nil;
    recorder = [[ AVAudioRecorder alloc] initWithURL:url settings:recordSetting error:&err];
    if(!recorder){
        NSLog(@"recorder: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle: @"Warning"
                                   message: [err localizedDescription]
                                  delegate: nil
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    //prepare to record
    [recorder setDelegate:self];
    [recorder prepareToRecord];
    recorder.meteringEnabled = YES;
    
    /*
    BOOL audioHWAvailable = audioSession.inputIsAvailable;
    if (! audioHWAvailable) {
        UIAlertView *cantRecordAlert =
        [[UIAlertView alloc] initWithTitle: @"Warning"
                                   message: @"Audio input hardware not available"
                                  delegate: nil
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil];
        [cantRecordAlert show];
        return;
    }
    */
    // start recording
    [recorder recordForDuration:(NSTimeInterval) 30];
}

- (IBAction)stopRecording:(id)sender {
    [recorder stop];
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
}



- (void)insertNewObject:(id)sender {
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    
    NVReminder *newReminder = [NSEntityDescription insertNewObjectForEntityForName:@"Reminder" inManagedObjectContext:context];
    
    static int count = 0;
    newReminder.reminderTitle = [NSString stringWithFormat:@"Reminder %i", count];
    newReminder.dateToRemind = nil;
    newReminder.creationDate = [NSDate date];
    newReminder.audioFileURL = sender;
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
    
    //For UISearhController
    if (self.searchController.searchBar.text.length != 0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"reminderTitle contains[c] %@", self.searchController.searchBar.text];
        request.predicate = predicate;
    }
    
    [self setFetchedResultsController:[[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:moc sectionNameKeyPath:nil cacheName:nil]];
    [[self fetchedResultsController] setDelegate:self];
    
    NSError *error = nil;
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Failed to initialize FetchedResultsController: %@\n%@", [error localizedDescription], [error userInfo]);
        abort();
    }
}

#pragma mark - AVAudioRecorderDelegate

- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag{
    NSLog(@"Stoped recording, %i", flag);
    [self insertNewObject: avrecorder.url.lastPathComponent];
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


#pragma mark - Table View

- (void)reloadTableView {
    [self.tableView reloadData];
}

- (void)configureCell:(NVCustomTableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath {
    NVReminder *reminder = (NVReminder*)[[self fetchedResultsController] objectAtIndexPath:indexPath];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [NSLocale currentLocale];
    dateFormatter.timeZone = [NSTimeZone defaultTimeZone];
    dateFormatter.dateFormat = @"dd.MM.yy";
    
    cell.taskTextView.text = reminder.reminderTitle;
    cell.dateLabel.text = [self formateDateStringfromDate:reminder.dateToRemind];
    cell.creationLabel.text = [dateFormatter stringFromDate:reminder.creationDate];
    cell.timeLabel.text = @"0:00";
    
    if ([reminder.dateToRemind compare:[NSDate date]] == NSOrderedAscending) {
        cell.dateLabel.textColor = [UIColor redColor];
    } else {
        cell.dateLabel.textColor = [UIColor greenColor];;
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
        
        NSError *err = nil;
        NSString *fileToDeletePath = [[self.fetchedResultsController objectAtIndexPath:indexPath] audioFileURL];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:fileToDeletePath error:&err];
        if(err)
            NSLog(@"File Manager: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
        
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
    [self rescheduleAllLocalNotifications];
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

#pragma mark - UISearchController

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    [self initializeFetchedResultsController];
    [self reloadTableView];
}

@end
