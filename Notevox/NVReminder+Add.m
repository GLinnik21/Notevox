//
//  NVReminder+Add.m
//  Notevox
//
//  Created by Глеб Линник on 21.01.17.
//  Copyright © 2017 ARobot. All rights reserved.
//

#import "NVReminder+Add.h"
#import "NVAppDelegate.h"

@implementation NVReminder (Add)

+ (NVReminder *)addReminderFromDictionary:(NSDictionary *)reminderInfo withContext:(NSManagedObjectContext*)context{
    
    NVReminder *reminder = [NSEntityDescription insertNewObjectForEntityForName:@"Reminder" inManagedObjectContext:context];
    
    reminder.identificator = (int16_t)[reminderInfo valueForKey:@"identificator"];
    reminder.isCustomSound = [reminderInfo valueForKey:@"isCustomSound"];
    reminder.isImportant = [reminderInfo valueForKey:@"isImportant"];
    reminder.audioFileURL = [reminderInfo valueForKey:@"audioFileURL"];
    reminder.creationDate = [reminderInfo valueForKey:@"creationDate"];
    reminder.dateToRemind = [reminderInfo valueForKey:@"dateToRemind"];
    reminder.reminderTitle = [reminderInfo valueForKey:@"reminderTitle"];
    reminder.repeatCalendar = (int32_t)[reminderInfo valueForKey:@"repeatCalendar"];
    
    return reminder;
}

@end
