//
//  NVCoreDataManager.m
//  Notevox
//
//  Created by Linnik Gleb on 26.01.17.
//  Copyright © 2017 A&K. All rights reserved.
//

#import "NVCoreDataManager.h"
#import <UIKit/UIKit.h>
#import "NVReminder+Add.h"

@interface NVCoreDataManager ()
//@property (nonatomic, strong) UIManagedDocument *document;
@end

@implementation NVCoreDataManager

- (id)init {
    self = [super init];
    if (self) {
        [self initializeCoreData];
////UIManagedDocument for iCloud fot later use. For now will just use standart CoreData Stack implementation 
//        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
//        url = [url URLByAppendingPathComponent:@"DocumentMetadata.plist"];
//        self.document = [[UIManagedDocument alloc] initWithFileURL:url];
//        
//        if ([[NSFileManager defaultManager] fileExistsAtPath:[url path]]) {
//            [self.document openWithCompletionHandler:^(BOOL success) {
//                if (success) {
//                    [self documentIsReady];
//                } else {
//                    NSLog(@"Couldn't open file at %@", url);
//                }
//            }];
//        } else {
//            [self.document saveToURL:self.document.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
//                if (success) {
//                    [self documentIsReady];
//                } else {
//                    NSLog(@"Couldn't open create at %@", url);
//                }
//            }];
//        }
//        
//        // Set our document up for automatic migrations
//        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
//                                 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
//                                 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
//        self.document.persistentStoreOptions = options;
//        
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(objectsDidChange:)
//                                                     name:NSManagedObjectContextObjectsDidChangeNotification
//                                                   object:self.document.managedObjectContext];
//        
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(contextDidSave:)
//                                                     name:NSManagedObjectContextDidSaveNotification
//                                                   object:self.document.managedObjectContext];
    }
    return self;
}

+ (instancetype)sharedInstance {
    static dispatch_once_t token = 0;
    __strong static NVCoreDataManager *sharedObject = nil;
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&token, ^{
        sharedObject = [[self alloc] init];
    });
    return sharedObject;
}

- (void)initializeCoreData {
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

- (void)saveState {
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}

- (NSArray<NVReminder *> *)getRemindersWithPredicate:(NSPredicate *)predicate andSortDescriptors:(NSArray<NSSortDescriptor *> *)sortDescriptors{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Reminder"];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:sortDescriptors];
    NSError *error = nil;
    NSArray *reminderArray = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!reminderArray) {
        NSLog(@"Error fetching Reminder objects: %@\n%@", [error localizedDescription], [error userInfo]);
        abort();
    }
    return reminderArray;
}

- (NSArray<NVReminderNote *> *)getAllReminders {
    NSArray *managedObjects = [self getRemindersWithPredicate:nil
                                           andSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]]];
    NSMutableArray *reminderNoteObjects = [[NSMutableArray alloc] init];
    for (NVReminder *reminder in managedObjects) {
        NVReminderNote *tempReminderNote = [[NVReminderNote alloc] initWithDictionary:reminder.dictionary];
        [reminderNoteObjects addObject:tempReminderNote];
    }
    return reminderNoteObjects;
}


- (NVReminder *)getManagedObjectReminderWithUUID:(NSUUID *)uuid {
    NSArray *reminderArray = [self getRemindersWithPredicate:[NSPredicate predicateWithFormat:@"uniqueID == %@", uuid.UUIDString] andSortDescriptors:nil];
    NVReminder *reminder = nil;
    if (reminderArray.count == 1) {
        reminder = reminderArray.firstObject;
    } else if (!reminderArray.count || !reminderArray) {
        NSLog(@"%@: No UUID was found\n", [self class]);
        abort();
    } else {
        NSLog(@"%@: 2 or more reminders were found with the same UUID. How could it be?!\n", [self class]);
        abort();
    }
    return reminder;
}

- (NVReminderNote *)getReminderWithUUID:(NSUUID *)uuid {
    NVReminderNote *reminder = [[NVReminderNote alloc] initWithDictionary:[self getManagedObjectReminderWithUUID:uuid].dictionary];
    return reminder;
}

- (void)updateReminderWithReminderNote:(NVReminderNote *)reminderNote {
    NVReminder *managedObject = [self getManagedObjectReminderWithUUID:[[NSUUID alloc] initWithUUIDString:reminderNote.uniqueID]];
    [managedObject configureReminderWithDictionary:reminderNote.dictionary];
    [self saveState];
}

- (void)deleteReminderWithUUID:(NSUUID *)uuid {
    [self.managedObjectContext deleteObject:[self getManagedObjectReminderWithUUID:uuid]];
    [self saveState];
}

- (void)addNewReminderWithReminderNote:(NVReminderNote *)reminderNote {
    [NVReminder addReminderFromDictionary:reminderNote.dictionary withContext:self.managedObjectContext];
    [self saveState];
}

////For UIManagedDocument and iCloud
//- (void)documentIsReady {
//    if (self.document.documentState == UIDocumentStateNormal) {
//        self.managedObjectContext = self.document.managedObjectContext;
//    }
//}
//
//- (void)objectsDidChange:(NSNotification *)notification
//{
//#ifdef DEBUG
//    NSLog(@"NSManagedObjects did change.");
//#endif
//}
//
//- (void)contextDidSave:(NSNotification *)notification
//{
//#ifdef DEBUG
//    NSLog(@"NSManagedContext did save.");
//#endif
//}

@end
