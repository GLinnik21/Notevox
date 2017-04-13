//
//  NVReminder+Add.h
//  Notevox
//
//  Created by Linnik Gleb on 21.01.17.
//  Copyright © 2017 A&K. All rights reserved.
//

#import "NVReminder+CoreDataClass.h"

@interface NVReminder (Add)

+ (NVReminder *)addReminderFromDictionary:(NSDictionary *)reminderInfo withContext:(NSManagedObjectContext*)context;
- (void)configureReminderWithDictionary:(NSDictionary *)reminderInfo;
- (NSDictionary *)dictionary;
- (void)prepareForDeletion;

@end
