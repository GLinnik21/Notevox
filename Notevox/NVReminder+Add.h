//
//  NVReminder+Add.h
//  Notevox
//
//  Created by Глеб Линник on 21.01.17.
//  Copyright © 2017 ARobot. All rights reserved.
//

#import "NVReminder.h"

@interface NVReminder (Add)

+ (NVReminder *)addReminderFromDictionary:(NSDictionary *)reminderInfo;

@end
