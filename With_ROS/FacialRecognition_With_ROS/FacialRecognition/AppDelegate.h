//
//  AppDelegate.h
//  FacialRecognition
//
//  Created by Kilian Michiels on 10/04/17.
//  Copyright © 2017 Kilian Michiels. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentStoreCoordinator;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;

- (void)saveContext;

@end

