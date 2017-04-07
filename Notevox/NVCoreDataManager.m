//
//  NVCoreDataManager.m
//  Notevox
//
//  Created by Linnik Gleb on 26.01.17.
//  Copyright © 2017 A&K. All rights reserved.
//

#import "NVCoreDataManager.h"

@implementation NVCoreDataManager

- (id)init
{
    self = [super init];
    if (!self) return nil;
    
    [self initializeCoreData];
    
    return self;
}

+ (instancetype)sharedInstance{
    // structure used to test whether the block has completed or not
    static dispatch_once_t token = 0;
    
    // initialize sharedObject as nil (first call only)
    __strong static NVCoreDataManager *sharedObject = nil;
    
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&token, ^{
        sharedObject = [[self alloc] init];
    });
    
    // returns the same object each time
    return sharedObject;
}

- (void)initializeCoreData
{
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Notevox" withExtension:@"momd"];
    NSManagedObjectModel *mom = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    NSAssert(mom != nil, @"Error initializing Managed Object Model");
    
    NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [moc setPersistentStoreCoordinator:psc];
    [self setManagedObjectContext:moc];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentsURL = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *storeURL = [documentsURL URLByAppendingPathComponent:@"Notevox.sqlite"];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        NSError *error = nil;
        NSPersistentStoreCoordinator *psc = [[self managedObjectContext] persistentStoreCoordinator];
        NSPersistentStore *store = [psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:@{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES} error:&error];
        NSAssert(store != nil, @"Error initializing PSC: %@\n%@", [error localizedDescription], [error userInfo]);
    });
}

@end
