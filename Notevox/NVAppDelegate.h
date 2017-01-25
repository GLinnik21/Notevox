//
//  NVAppDelegate.h
//  Notevox
//
//  Created by Глеб Линник on 19.01.17.
//  Copyright © 2017 ARobot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "NVDataController.h"

@interface NVAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NVDataController *dataController;

@end

