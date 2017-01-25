//
//  NVDataController.h
//  Notevox
//
//  Created by Глеб Линник on 26.01.17.
//  Copyright © 2017 ARobot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface NVDataController : NSObject

@property (strong) NSManagedObjectContext *managedObjectContext;

- (void)initializeCoreData;

@end