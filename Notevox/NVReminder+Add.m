//
//  NVReminder+Add.m
//  Notevox
//
//  Created by Linnik Gleb on 21.01.17.
//  Copyright © 2017 A&K. All rights reserved.
//

#import "NVReminder+Add.h"
#import "NVAppDelegate.h"

@implementation NVReminder (Add)

+ (NVReminder *)addReminderFromDictionary:(NSDictionary *)reminderInfo withContext:(NSManagedObjectContext*)context {
    
    NVReminder *reminder = [NSEntityDescription insertNewObjectForEntityForName:@"Reminder" inManagedObjectContext:context];
    
    reminder.uniqueID = [reminderInfo valueForKey:@"uniqueID"];
    reminder.isCustomSound = [[reminderInfo valueForKey:@"isCustomSound"] boolValue];
    reminder.isImportant = [[reminderInfo valueForKey:@"isImportant"] boolValue];
    reminder.audioFileURL = [reminderInfo valueForKey:@"audioFileURL"];
    reminder.creationDate = [reminderInfo valueForKey:@"creationDate"];
    reminder.dateToRemind = [reminderInfo valueForKey:@"dateToRemind"];
    reminder.reminderTitle = [reminderInfo valueForKey:@"reminderTitle"];
    reminder.repeatCalendar = [[reminderInfo valueForKey:@"repeatCalendar"] intValue];
    
    return reminder;
}

- (NSDictionary *)dictionary {
    NSDictionary *tempDictionary = @{
                                     @"uniqueID" : self.uniqueID ?: [NSNull null],
                                     @"isCustomSound" : [NSNumber numberWithBool:self.isCustomSound],
                                     @"isImportant" : [NSNumber numberWithBool:self.isImportant],
                                     @"audioFileURL" : self.audioFileURL,
                                     @"creationDate" : self.creationDate,
                                     @"dateToRemind" : self.dateToRemind ?: [NSNull null],
                                     @"reminderTitle" : self.reminderTitle ?: [NSNull null],
                                     @"repeatCalendar" : [NSNumber numberWithInt:self.repeatCalendar],
                                     };
    return tempDictionary;
}

- (void)prepareForDeletion {
    NSError *err = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    documentsPath = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"Sounds/%@", self.audioFileURL]];
    [fileManager removeItemAtPath:documentsPath error:&err];
    if(err)
        NSLog(@"File Manager: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
}

@end
