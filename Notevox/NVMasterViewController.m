//
//  NVNVMasterViewController.m
//  Notevox
//
//  Created by Linnik Gleb on 19.01.17.
//  Copyright © 2017 A&K. All rights reserved.
//

#import "NVMasterViewController.h"
#import "NVDetailViewController.h"
#import "NVCustomTableViewCell.h"
#import "NVAppDelegate.h"
#import "UIView+Shake.h"
#import "NSDate+DateTools.h"
#import "NVReminderManager.h"

@interface NVMasterViewController () {
    AVAudioRecorder *_recorder;
    AVAudioPlayer *_player;
    NVCustomTableViewCell *_previouslyPlayedCell;
}

@property (strong) NSMutableArray<NVReminderNote *> *reminders;

@end

@implementation NVMasterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = false;
    self.tableView.tableHeaderView = self.searchController.searchBar;
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted){if (!granted) self.navigationItem.rightBarButtonItem.enabled = NO;}];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateLocalArray)
                                                 name:NVReminderManagerDataChanged
                                               object:nil];
    [self updateLocalArray];
    
    UIDevice *device = [UIDevice currentDevice];
    device.proximityMonitoringEnabled = YES;
    if (device.isProximityMonitoringEnabled) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(proximityChanged)
                                                     name:UIDeviceProximityStateDidChangeNotification
                                                   object:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadTableView)
                                                 name:@"reloadData"
                                               object:nil];
    [self reloadTableView];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"reloadData"
                                                  object:nil];
}

- (void)updateLocalArray {
    self.reminders = [[NVReminderManager sharedInstance] allReminders];
}

- (NVCustomTableViewCell *)getCustomCellViewObject:(id)sender {
    NVCustomTableViewCell *tempCell = (NVCustomTableViewCell *)sender;
    while (![tempCell isKindOfClass:[NVCustomTableViewCell class]]) {
        tempCell = (NVCustomTableViewCell *)tempCell.superview;
    }
    return tempCell;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NVCustomTableViewCell *sellectedCell = [self getCustomCellViewObject:textField];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sellectedCell];
    NVReminderNote *reminder = [self.reminders objectAtIndex:indexPath.row];
    
    if (textField.text.length > 0) {
        reminder.reminderTitle = textField.text;
    } else {
        [textField setText:reminder.reminderTitle];
    }

}
//TODO: split nontification scheduling and player into different instances
- (void)rescheduleAllLocalNotifications{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    NSArray *fetchedData = self.reminders;
    NSSortDescriptor *dateToRemindSort = [NSSortDescriptor sortDescriptorWithKey:@"dateToRemind" ascending:YES];
    NSArray *sortedData = [fetchedData sortedArrayUsingDescriptors:@[dateToRemindSort]];
    NSInteger badgeNumber = 1;
    for (int i = 0; i < sortedData.count; i++) {
        NVReminder *tempReminder = [sortedData objectAtIndex:i];
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
            localNotification.applicationIconBadgeNumber = UIApplication.sharedApplication.applicationIconBadgeNumber + badgeNumber++;
            [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        }
    }
}

- (NSString *)formateDateStringfromDate:(NSDate *)date {
    NSString *dateFormatString = nil;
    if (date) {
        if (date.isToday) {
            dateFormatString = NSLocalizedString(@"today", @"");
        } else if (date.isTomorrow) {
            dateFormatString = NSLocalizedString(@"tomorrow", @"");
        } else if (date.isYesterday) {
            dateFormatString = NSLocalizedString(@"yesterday", @"");;
        } else {
            dateFormatString = [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle];
        }
        dateFormatString = [dateFormatString stringByAppendingString:[NSString stringWithFormat:@", %@", [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle]]];
    }
    return dateFormatString;
}


- (void)updateTime:(NSTimer *)timer {
    NVCustomTableViewCell *tempCell = timer.userInfo;
    NSInteger seconds = _player.currentTime;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [NSLocale currentLocale];
    dateFormatter.timeZone = [NSTimeZone defaultTimeZone];
    dateFormatter.dateFormat = @"mm:ss";
    tempCell.playingProgress.progress = _player.currentTime/_player.duration;
    tempCell.timeLabel.text = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:seconds]];
    if (!_player.isPlaying && !_previouslyPlayedCell) {
        [timer invalidate];
    }
}

-(void)playButtonClicked:(UIButton*)sender {
    static NSTimer *timer = nil;
    
    NVCustomTableViewCell *tempCell = [self getCustomCellViewObject:sender];
    
    if (_player.isPlaying && [_previouslyPlayedCell.playButton isEqual:sender]) {
        //Pause the same cell
        [sender setImage:[UIImage imageNamed:@"playButton"] forState:UIControlStateNormal];
        [_player pause];
    } else if (!_player.isPlaying && [_previouslyPlayedCell.playButton isEqual:sender]) {
        //Play the same cell
        [sender setImage:[UIImage imageNamed:@"pauseButton"] forState:UIControlStateNormal];
        tempCell.taskTextView.hidden = YES;
        tempCell.playingProgress.hidden = NO;
        [_player play];
    } else {
        //Play new cell
        [_player stop];
        [timer invalidate];
        timer = nil;
        
        tempCell.taskTextView.hidden = YES;
        tempCell.playingProgress.hidden = NO;
        timer = [NSTimer scheduledTimerWithTimeInterval:1.0/60.0 target:self selector:@selector(updateTime:) userInfo:tempCell repeats:YES];
        
        if (_previouslyPlayedCell) {
            [self.tableView reloadRowsAtIndexPaths:@[[self.tableView indexPathForCell:_previouslyPlayedCell]] withRowAnimation:UITableViewRowAnimationNone];
        }
        _previouslyPlayedCell = tempCell;
        
        NVReminderNote *reminder = [self.reminders objectAtIndex:sender.tag];
        
        NSString *fileURLString = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        fileURLString = [fileURLString stringByAppendingPathComponent:[NSString stringWithFormat:@"Sounds/%@", reminder.audioFileURL]];
        NSURL *fileURL = [NSURL fileURLWithPath:fileURLString];
        
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
        
        _player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
        [_player setDelegate:self];
        [_player play];
        
        [sender setImage:[UIImage imageNamed:@"pauseButton"] forState:UIControlStateNormal];
    }
}

- (void)proximityChanged {
    if ([UIDevice currentDevice].proximityState) {
        [self startRecording:nil];
    } else {
        [self stopRecording:nil];
    }
}

- (IBAction)startRecording:(id)sender {
    if (_player.isPlaying) {
        [_player stop];
        [self.tableView reloadRowsAtIndexPaths:@[[self.tableView indexPathForCell:_previouslyPlayedCell]] withRowAnimation:UITableViewRowAnimationNone];
        _previouslyPlayedCell = nil;
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
    _recorder = [[ AVAudioRecorder alloc] initWithURL:url settings:recordSetting error:&err];
    if(!_recorder){
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
    [_recorder setDelegate:self];
    [_recorder prepareToRecord];
    _recorder.meteringEnabled = YES;
 
    // start recording
    self.navigationController.navigationBar.topItem.title = NSLocalizedString(@"recording", @"");
    [_recorder recordForDuration:(NSTimeInterval) 30];
}

- (IBAction)stopRecording:(id)sender {
    [_recorder stop];
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
    AVURLAsset *audioAsset = [AVURLAsset URLAssetWithURL:_recorder.url options:nil];
    CMTime audioDuration = audioAsset.duration;
    Float64 audioDurationSeconds = CMTimeGetSeconds(audioDuration);
    
    if (audioDurationSeconds > 0.5) {
        [self insertNewObject: _recorder.url.lastPathComponent];
    } else {
        [self.navigationController.navigationBar.subviews enumerateObjectsUsingBlock:^(UIView* obj, NSUInteger idx, BOOL *stop) {
            [obj shake:7 withDelta:4.0 speed:0.1];
        }];
        [_recorder deleteRecording];
    }
}

- (IBAction)cancelRecording:(id)sender {
    [_recorder stop];
    [_recorder deleteRecording];
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
}


- (void)insertNewObject:(id)sender {
    NVReminderNote *newReminder = [[NVReminderNote alloc] init];
    
    newReminder.uniqueID = [[[NSUUID alloc] init] UUIDString];
    newReminder.reminderTitle = [NSString stringWithFormat:NSLocalizedString(@"untitled", @"")];
    newReminder.dateToRemind = nil;
    newReminder.creationDate = [NSDate date];
    newReminder.audioFileURL = sender;
    
    [[NVReminderManager sharedInstance] createNewReminder:newReminder];
    [[self tableView] insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
}

#pragma mark - AVAudioRecorderDelegate

- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag{
    NSLog(@"Stoped recording, %i", flag);
    self.navigationController.navigationBar.topItem.title = NSLocalizedString(@"reminders", @"");
}

#pragma mark - AVAudioPlayerDelegate

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    [self.tableView reloadRowsAtIndexPaths:@[[self.tableView indexPathForCell:_previouslyPlayedCell]] withRowAnimation:UITableViewRowAnimationNone];
    _previouslyPlayedCell = nil;
}

#pragma mark - Segues


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        NVReminderNote *reminder = [self.reminders objectAtIndex:indexPath.row];
        NVDetailViewController *controller = (NVDetailViewController *)[[segue destinationViewController] topViewController];
        [controller setReminder:reminder];
    }
}
#pragma mark - MGSwipeTableCellDelegate

- (BOOL)swipeTableCell:(nonnull MGSwipeTableCell*) cell tappedButtonAtIndex:(NSInteger) index direction:(MGSwipeDirection)direction fromExpansion:(BOOL) fromExpansion {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NVReminderNote *reminder = [self.reminders objectAtIndex:indexPath.row];
    if (reminder.isImportant) {
        reminder.isImportant = NO;
    } else {
        reminder.isImportant = YES;
    }
    return YES;
}

#pragma mark - Table View

- (void)reloadTableView {
    [self.tableView reloadData];
}

- (void)configureCell:(NVCustomTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NVReminderNote *reminder = [self.reminders objectAtIndex:indexPath.row];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [NSLocale currentLocale];
    dateFormatter.timeZone = [NSTimeZone defaultTimeZone];
    
    NSString *fileURLString = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    fileURLString = [fileURLString stringByAppendingPathComponent:[NSString stringWithFormat:@"Sounds/%@", reminder.audioFileURL]];
    NSURL *fileURL = [NSURL fileURLWithPath:fileURLString];

    AVURLAsset *audioAsset = [AVURLAsset URLAssetWithURL:fileURL options:nil];
    CMTime audioDuration = audioAsset.duration;
    NSInteger audioDurationSeconds = CMTimeGetSeconds(audioDuration);
    
    cell.taskTextView.text = reminder.reminderTitle;
    cell.taskTextView.textColor = reminder.isImportant ? [UIColor orangeColor] : [UIColor blackColor];
    
    cell.dateLabel.text = [self formateDateStringfromDate:reminder.dateToRemind];
    cell.creationLabel.text = reminder.creationDate.timeAgoSinceNow;
    dateFormatter.dateFormat = @"mm:ss";
    cell.timeLabel.text = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:audioDurationSeconds]];
    cell.playButton.tag = indexPath.row;
    [cell.playButton addTarget:self action:@selector(playButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cell.playButton setImage:[UIImage imageNamed:@"playButton"] forState:UIControlStateNormal];
    cell.taskTextView.hidden = NO;
    cell.playingProgress.hidden = YES;
    
    if ([reminder.dateToRemind isEarlierThanOrEqualTo:[NSDate date]])
        cell.dateLabel.textColor = [UIColor redColor];
    else
        cell.dateLabel.textColor = [UIColor darkGrayColor];;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[NVReminderManager sharedInstance] numberOfReminders];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NVCustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReminderCell" forIndexPath:indexPath];
    
    //configure left buttons
    MGSwipeButton *importantButton = [MGSwipeButton buttonWithTitle:@"" icon:[UIImage imageNamed:@"importantButton"] backgroundColor:[UIColor orangeColor]];
    [importantButton iconTintColor:[UIColor whiteColor]];
    cell.leftButtons = @[importantButton];
    cell.leftSwipeSettings.transition = MGSwipeStateSwippingLeftToRight;
    cell.leftExpansion.buttonIndex = 0;
    cell.delegate = self;
    
    // Set up the cell content
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[NVReminderManager sharedInstance] deleteReminderWithUUID:[[NSUUID alloc] initWithUUIDString:[[self.reminders objectAtIndex:indexPath.row] uniqueID]]];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
    }
}

#pragma mark - UISearchControllerDelegate

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    [_player stop];
    [self reloadTableView];
}

@end
