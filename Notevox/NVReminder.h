//
//  NVReminder.h
//  Notevox
//
//  Created by Глеб Линник on 21.01.17.
//  Copyright © 2017 ARobot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface NVReminder : NSManagedObject

@property (nonatomic, assign) BOOL isCustomSound;
@property (nonatomic, assign) BOOL isImportant;
@property (nonatomic, retain) NSString *audioFileURL;
@property (nonatomic) NSInteger *repeatCalendar;
@property (nonatomic, retain) NSDate *dateToRemind;
@property (nonatomic, retain) NSDate *creationDate;
@property (nonatomic, retain) NSString *reminderTitle;

@end
