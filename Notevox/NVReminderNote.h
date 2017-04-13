//
//  NVReminderNote.h
//  Notevox
//
//  Created by Gleb Linnik on 08.04.17.
//  Copyright © 2017 A&K. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NVReminderNote : NSObject

@property (nullable, nonatomic, copy) NSString *audioFileURL;
@property (nullable, nonatomic, copy) NSDate *creationDate;
@property (nullable, nonatomic, copy) NSDate *dateToRemind;
@property (nullable, nonatomic, copy) NSString *uniqueID;
@property (nonatomic) BOOL isCustomSound;
@property (nonatomic) BOOL isImportant;
@property (nullable, nonatomic, copy) NSString *reminderTitle;
@property (nonatomic) int32_t repeatCalendar;

- (instancetype _Nonnull)initWithDictionary:(NSDictionary *_Nonnull)dictionary;
- (NSDictionary *_Nullable)dictionary;
- (void)configureReminderWithDictionary:(NSDictionary *_Nonnull)reminderInfo;

@end
