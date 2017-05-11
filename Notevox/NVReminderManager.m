//
//  NVReminderManager.m
//  Notevox
//
//  Created by Gleb Linnik on 13.04.17.
//  Copyright © 2017 A&K. All rights reserved.
//

#import "NVReminderManager.h"
#import "NVCoreDataManager.h"

@interface NVReminderManager () {
    NVCoreDataManager *_sharedCoreDataManager;
}

@end

@implementation NVReminderManager

- (id)init {
    self = [super init];
    _sharedCoreDataManager = [NVCoreDataManager sharedInstance];
    return self;
}

+ (instancetype)sharedInstance {
    static dispatch_once_t token = 0;
    __strong static NVReminderManager *sharedObject = nil;
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&token, ^{
        sharedObject = [[self alloc] init];
    });
    return sharedObject;
}

- (void)createNewReminder:(NVReminderNote *)reminderNote {
    [_sharedCoreDataManager setReminderWithReminderNote:reminderNote];
}

- (void)updateReminderWithReminderNote:(NVReminderNote *)reminder {
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString: reminder.uniqueID];
    if (uuid) {
        [_sharedCoreDataManager deleteReminderWithUUID:uuid];
        [_sharedCoreDataManager addNewReminderWithDinctionary:reminder.dictionary];
        [_sharedCoreDataManager saveState];
    } else {
        NSLog(@"NVReminderManager: no or wrong UUID in reminder with title '%@'", reminder.reminderTitle);
    }
}

- (NSArray<NVReminderNote *>*)getAllReminders {
    return [_sharedCoreDataManager getAllReminders];
}

- (NVReminderNote *)getReminderWithUUID:(NSUUID *)uuid {
    return [_sharedCoreDataManager getReminderWithUUID:uuid];
}

- (void)deleteAllReminders {
    NSArray *allReminders = [_sharedCoreDataManager getAllReminders];
    for (NVReminderNote *tempReminder in allReminders) {
        NSUUID *tempUUID = [[NSUUID alloc] initWithUUIDString:tempReminder.uniqueID];
        [_sharedCoreDataManager deleteReminderWithUUID:tempUUID];
    }
    [_sharedCoreDataManager saveState];
}

- (void)deleteReminderWithUUID:(NSUUID *)uuid{
    [_sharedCoreDataManager deleteReminderWithUUID:uuid];
}

@end
