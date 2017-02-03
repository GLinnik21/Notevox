//
//  NVReminder+CoreDataProperties.h
//  Notevox
//
//  Created by Глеб Линник on 03.02.17.
//  Copyright © 2017 ARobot. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#import "NVReminder+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface NVReminder (CoreDataProperties)

+ (NSFetchRequest<NVReminder *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *audioFileURL;
@property (nullable, nonatomic, copy) NSDate *creationDate;
@property (nullable, nonatomic, copy) NSDate *dateToRemind;
@property (nonatomic) BOOL isCustomSound;
@property (nonatomic) BOOL isImportant;
@property (nullable, nonatomic, copy) NSString *reminderTitle;
@property (nonatomic) int32_t repeatCalendar;

@end

NS_ASSUME_NONNULL_END
