//
//  NVReminder+CoreDataProperties.m
//  Notevox
//
//  Created by Глеб Линник on 03.02.17.
//  Copyright © 2017 ARobot. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#import "NVReminder+CoreDataProperties.h"

@implementation NVReminder (CoreDataProperties)

+ (NSFetchRequest<NVReminder *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Reminder"];
}

@dynamic audioFileURL;
@dynamic creationDate;
@dynamic dateToRemind;
@dynamic isCustomSound;
@dynamic isImportant;
@dynamic reminderTitle;
@dynamic repeatCalendar;

@end
