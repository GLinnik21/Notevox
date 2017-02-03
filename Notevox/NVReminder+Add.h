//
//  NVReminder+Add.h
//  Notevox
//
//  Created by Глеб Линник on 21.01.17.
//  Copyright © 2017 ARobot. All rights reserved.
//

#import "NVReminder+CoreDataClass.h"

@interface NVReminder (Add)

+ (NVReminder *)addReminderFromDictionary:(NSDictionary *)reminderInfo withContext:(NSManagedObjectContext*)context;

@end
