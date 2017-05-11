//
//  NVReminderManager.h
//  Notevox
//
//  Created by Gleb Linnik on 13.04.17.
//  Copyright © 2017 A&K. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NVReminderNote.h"

@interface NVReminderManager : NSObject

+ (instancetype)sharedInstance;

- (void)createNewReminder:(NVReminderNote *)reminderNote;
- (void)updateReminderWithReminderNote:(NVReminderNote *)reminder;
- (NSArray<NVReminderNote *> *)getAllReminders;
- (NVReminderNote *)getReminderWithUUID:(NSUUID *)uuid;
- (void)deleteReminderWithUUID:(NSUUID *)uuid;
- (void)deleteAllReminders;

@end
