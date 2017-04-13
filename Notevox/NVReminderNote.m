//
//  NVReminderNote.m
//  Notevox
//
//  Created by Gleb Linnik on 08.04.17.
//  Copyright © 2017 A&K. All rights reserved.
//

#import "NVReminderNote.h"

@implementation NVReminderNote

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.uniqueID = [dictionary valueForKey:@"uniqueID"];
        self.isCustomSound = [[dictionary valueForKey:@"isCustomSound"] boolValue];
        self.isImportant = [[dictionary valueForKey:@"isImportant"] boolValue];
        self.audioFileURL = [dictionary valueForKey:@"audioFileURL"];
        self.creationDate = [dictionary valueForKey:@"creationDate"];
        self.dateToRemind = [dictionary valueForKey:@"dateToRemind"];
        self.reminderTitle = [dictionary valueForKey:@"reminderTitle"];
        self.repeatCalendar = [[dictionary valueForKey:@"repeatCalendar"] intValue];
    }
    return self;
}

- (NSDictionary *)dictionary {
    NSDictionary *tempDictionary = @{
                                     @"uniqueID" : self.uniqueID,
                                     @"isCustomSound" : [NSNumber numberWithBool:self.isCustomSound],
                                     @"isImportant" : [NSNumber numberWithBool:self.isImportant],
                                     @"audioFileURL" : self.audioFileURL,
                                     @"creationDate" : self.creationDate,
                                     @"dateToRemind" : self.dateToRemind,
                                     @"reminderTitle" : self.reminderTitle,
                                     @"repeatCalendar" : [NSNumber numberWithInt:self.repeatCalendar],
                                     };
    return tempDictionary;
}


@end
