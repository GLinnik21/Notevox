//
//  NVCoreDataManager.h
//  Notevox
//
//  Created by Linnik Gleb on 26.01.17.
//  Copyright © 2017 A&K. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "NVReminderNote.h"

@interface NVCoreDataManager : NSObject

@property (strong) NSManagedObjectContext *managedObjectContext;

+ (instancetype)sharedInstance;

- (NSArray<NVReminderNote *> *)getAllReminders;
- (NVReminderNote *)getReminderWithUUID:(NSUUID *)uuid;
- (void)updateReminderWithReminderNote:(NVReminderNote *)reminderNote;

- (void)deleteReminderWithUUID:(NSUUID *)uuid;
- (void)addNewReminderWithReminderNote:(NVReminderNote *)reminderNote;

- (void)saveState;
@end
