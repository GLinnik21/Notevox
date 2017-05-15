//
//  NVReminderNote.m
//  Notevox
//
//  Created by Gleb Linnik on 08.04.17.
//  Copyright © 2017 A&K. All rights reserved.
//

#import "NVReminderNote.h"

@implementation NVReminderNote

- (instancetype)initWithDictionary:(NSDictionary *)reminderInfo {
    self = [super init];
    if (self) {
        self.uniqueID = [reminderInfo valueForKey:@"uniqueID"] == [NSNull null] ? nil : [reminderInfo valueForKey:@"uniqueID"];
        self.isCustomSound = [[reminderInfo valueForKey:@"isCustomSound"] boolValue];
        self.isImportant = [[reminderInfo valueForKey:@"isImportant"] boolValue];
        self.audioFileURL = [reminderInfo valueForKey:@"audioFileURL"];
        self.creationDate = [reminderInfo valueForKey:@"creationDate"];
        self.dateToRemind = [reminderInfo valueForKey:@"dateToRemind"] == [NSNull null] ? nil : [reminderInfo valueForKey:@"dateToRemind"];
        self.reminderTitle = [reminderInfo valueForKey:@"reminderTitle"] == [NSNull null] ? nil : [reminderInfo valueForKey:@"reminderTitle"];
        self.repeatCalendar = [[reminderInfo valueForKey:@"repeatCalendar"] intValue];
    }
    return self;
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

- (void)configureReminderWithDictionary:(NSDictionary *)reminderInfo {
    self.uniqueID = [reminderInfo valueForKey:@"uniqueID"];
    self.isCustomSound = [[reminderInfo valueForKey:@"isCustomSound"] boolValue];
    self.isImportant = [[reminderInfo valueForKey:@"isImportant"] boolValue];
    self.audioFileURL = [reminderInfo valueForKey:@"audioFileURL"];
    self.creationDate = [reminderInfo valueForKey:@"creationDate"];
    self.dateToRemind = [reminderInfo valueForKey:@"dateToRemind"];
    self.reminderTitle = [reminderInfo valueForKey:@"reminderTitle"];
    self.repeatCalendar = [[reminderInfo valueForKey:@"repeatCalendar"] intValue];
}

@end
