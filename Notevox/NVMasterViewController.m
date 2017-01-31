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
    NVCustomTableViewCell *previouslyPlayedCell;
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

- (NVCustomTableViewCell *)getCustomCellViewObject:(id)sender {
    NVCustomTableViewCell *tempCell = (NVCustomTableViewCell *)sender;
    while (![tempCell isKindOfClass:[NVCustomTableViewCell class]]) {
        tempCell = (NVCustomTableViewCell *)tempCell.superview;
    }
    return tempCell;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self textFieldDidEndEditing:textField];
    return [textField resignFirstResponder];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NVCustomTableViewCell *sellectedCell = [self getCustomCellViewObject:textField];
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
    NSInteger badgeNumber = 1;
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
            localNotification.applicationIconBadgeNumber = UIApplication.sharedApplication. applicationIconBadgeNumber + badgeNumber++;
            NSLog(@"%ld badges", (long)[[UIApplication sharedApplication] applicationIconBadgeNumber]);
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


- (void)updateTime:(NSTimer *)timer {
    NVCustomTableViewCell *tempCell = timer.userInfo;
    NSInteger seconds = player.currentTime;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [NSLocale currentLocale];
    dateFormatter.timeZone = [NSTimeZone defaultTimeZone];
    dateFormatter.dateFormat = @"mm:ss";
    tempCell.playingProgress.progress = player.currentTime/player.duration;
    tempCell.timeLabel.text = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:seconds]];
    if (!player.isPlaying && !previouslyPlayedCell) {
        [timer invalidate];
    }
}

-(void)playButtonClicked:(UIButton*)sender {
    static NSTimer *timer = nil;
    
    NVCustomTableViewCell *tempCell = [self getCustomCellViewObject:sender];
    
    if (player.isPlaying && [previouslyPlayedCell.playButton isEqual:sender]) {
        //Pause the same cell
        [sender setImage:[UIImage imageNamed:@"playButton"] forState:UIControlStateNormal];
        [player pause];
    } else if (!player.isPlaying && [previouslyPlayedCell.playButton isEqual:sender]) {
        //Play the same cell
        [sender setImage:[UIImage imageNamed:@"pauseButton"] forState:UIControlStateNormal];
        tempCell.taskTextView.hidden = YES;
        tempCell.playingProgress.hidden = NO;
        [player play];
    } else {
        //Play new cell
        [player stop];
        [timer invalidate];
        timer = nil;
        
        tempCell.taskTextView.hidden = YES;
        tempCell.playingProgress.hidden = NO;
        timer = [NSTimer scheduledTimerWithTimeInterval:1.0/60.0 target:self selector:@selector(updateTime:) userInfo:tempCell repeats:YES];
        
        if (previouslyPlayedCell) {
            [self.tableView reloadRowsAtIndexPaths:@[[self.tableView indexPathForCell:previouslyPlayedCell]] withRowAnimation:UITableViewRowAnimationNone];
        }
        previouslyPlayedCell = tempCell;
        
        NVReminder *reminder = (NVReminder*)[[self fetchedResultsController] objectAtIndexPath:[NSIndexPath indexPathForRow:sender.tag inSection:0]];
        
        NSString *fileURLString = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        fileURLString = [fileURLString stringByAppendingPathComponent:[NSString stringWithFormat:@"Sounds/%@", reminder.audioFileURL]];
        NSURL *fileURL = [NSURL fileURLWithPath:fileURLString];
        
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
        
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
        [player setDelegate:self];
        [player play];
        
        [sender setImage:[UIImage imageNamed:@"pauseButton"] forState:UIControlStateNormal];
    }
}

- (IBAction)startRecording:(id)sender {
    if (player.isPlaying) {
        [player stop];
        [self.tableView reloadRowsAtIndexPaths:@[[self.tableView indexPathForCell:previouslyPlayedCell]] withRowAnimation:UITableViewRowAnimationNone];
    }
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
    
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
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
 
    // start recording
    self.navigationController.navigationBar.topItem.title = NSLocalizedString(@"recording", @"");
    [recorder recordForDuration:(NSTimeInterval) 30];
}

- (IBAction)stopRecording:(id)sender {
    [recorder stop];
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
    
    [self insertNewObject: recorder.url.lastPathComponent];
}

- (IBAction)cancelRecording:(id)sender {
    [recorder stop];
    [recorder deleteRecording];
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
}


- (void)insertNewObject:(id)sender {
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    
    NVReminder *newReminder = [NSEntityDescription insertNewObjectForEntityForName:@"Reminder" inManagedObjectContext:context];

    newReminder.reminderTitle = [NSString stringWithFormat:NSLocalizedString(@"untitled", @"")];
    newReminder.dateToRemind = nil;
    newReminder.creationDate = [NSDate date];
    newReminder.audioFileURL = sender;
    
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
    
    NSSortDescriptor *creationDateSort = [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO];
    
    [request setSortDescriptors:@[creationDateSort]];
    
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
    self.navigationController.navigationBar.topItem.title = NSLocalizedString(@"reminders", @"");
}

#pragma mark - AVAudioPlayerDelegate

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    [self.tableView reloadRowsAtIndexPaths:@[[self.tableView indexPathForCell:previouslyPlayedCell]] withRowAnimation:UITableViewRowAnimationNone];
    previouslyPlayedCell = nil;
}

#pragma mark - Segues

//- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
//    [self performSegueWithIdentifier: @"EditUser" sender: [tableView cellForRowAtIndexPath: indexPath]];
//}

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
    
    NSString *fileURLString = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    fileURLString = [fileURLString stringByAppendingPathComponent:[NSString stringWithFormat:@"Sounds/%@", reminder.audioFileURL]];
    NSURL *fileURL = [NSURL fileURLWithPath:fileURLString];

    AVURLAsset *audioAsset = [AVURLAsset URLAssetWithURL:fileURL options:nil];
    CMTime audioDuration = audioAsset.duration;
    NSInteger audioDurationSeconds = CMTimeGetSeconds(audioDuration);
    
    cell.taskTextView.text = reminder.reminderTitle;
    cell.dateLabel.text = [self formateDateStringfromDate:reminder.dateToRemind];
    cell.creationLabel.text = [dateFormatter stringFromDate:reminder.creationDate];
    dateFormatter.dateFormat = @"mm:ss";
    cell.timeLabel.text = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:audioDurationSeconds]];
    cell.playButton.tag = indexPath.row;
    [cell.playButton addTarget:self action:@selector(playButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cell.playButton setImage:[UIImage imageNamed:@"playButton"] forState:UIControlStateNormal];
    cell.taskTextView.hidden = NO;
    cell.playingProgress.hidden = YES;
    
    if ([reminder.dateToRemind compare:[NSDate date]] == NSOrderedAscending) {
        cell.dateLabel.textColor = [UIColor redColor];
    } else {
        cell.dateLabel.textColor = [UIColor blueColor];
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
    NVCustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReminderCell" forIndexPath:indexPath];
    
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
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        documentsPath = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"Sounds/%@", [[self.fetchedResultsController objectAtIndexPath:indexPath] audioFileURL]]];
        [fileManager removeItemAtPath:documentsPath error:&err];
        if(err)
            NSLog(@"File Manager: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
        
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        previouslyPlayedCell = nil;
        [player stop];
        
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
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self rescheduleAllLocalNotifications];
    [[self tableView] endUpdates];
}

#pragma mark - UISearchController

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    [self initializeFetchedResultsController];
    [self reloadTableView];
}

@end
