//
//  DataStorage.m
//  FacialRecognition
//
//  Created by Kilian on 13/04/17.
//  Copyright © 2017 Kilian Michiels. All rights reserved.
//

/**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**/
/*------------------------------------------------------------------------*/
/*                                 DATABASE STUFF                         */
/*------------------------------------------------------------------------*/
/**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**//**/

#import "DataStorage.h"

@implementation DataStorage

/*
 Save the userdata in the database.
 */
+ (BOOL)addUser:(NSString *)name user_tag:(NSString *)user_tag{
    
    // Make a managable object:
    NSManagedObjectContext *context = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).persistentStoreCoordinator.viewContext;
    
    // Logging:
    NSLog(@"\n---------------------------\nCONTEXT: %@\n---------------------------\n", context);
    
    NSString * job;
    // Prepare for saving:
    if([user_tag  isEqual: @"Visitor_FR"] || [user_tag  isEqual: @"Visitor_No_FR_Name"]){
        job = @"visitor";
    }
    else if([user_tag  isEqual: @"Employee_FR"] || [user_tag  isEqual: @"Employee_No_FR_Name"]){
        job = @"employee";
    }
    
    // Do the actual saving:
    NSManagedObject *entityNameObj = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:context];
    [entityNameObj setValue:name forKey:@"name"];
    [entityNameObj setValue:job forKey:@"job"];
    @try {
        [((AppDelegate*)[[UIApplication sharedApplication] delegate]) saveContext];
        return YES;
    } @catch (NSException *exception) {
        NSLog(@"Could not save the user in the database: %@", exception);
        return NO;
    }
}

///////////////////////////////////////////////////////////////////////////

/*
 Check if the user exists in the database.
 */
+ (BOOL)checkForUserExistance:(NSString *)name{
    
    NSLog(@"Checking for username '%@' in database...", name);
    
    // Make a managable object:
    NSManagedObjectContext *context = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).persistentStoreCoordinator.viewContext;
    
    // Make a request:
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    
    // add the right parameters:
    [request setResultType:NSDictionaryResultType];
    [request setPredicate:[NSPredicate predicateWithFormat:@"name == %@", name]];
    
    NSError *error = nil;
    
    // Fetch the data:
    NSArray *result = [context executeFetchRequest:request error:&error];
    
    if ([result count] < 1) {
        NSLog(@"checkForUserExistance error: count < 1");
        return NO;
    }
    else{
        NSLog(@"Got these users back with name: %@\n%@", name, result);
        return YES;
    }
}

///////////////////////////////////////////////////////////////////////////

/*
 This function returns a dictionary with the name and job of the user if they exist in the database.
 If you want to get the job:
    NSString     *name = [intel objectForKey: @"name"];
    NSString *job = [intel objectForKey: @"job"];
 */
+ (NSDictionary*)getUserIntel:(NSString *)name{
    
    // Make an array to return:
    NSDictionary * intel;
    
    // Make a managable object:
    NSManagedObjectContext *context = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).persistentStoreCoordinator.viewContext;
    
    // Make a request:
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    // Add the right parameters:
    NSEntityDescription *entity = [NSEntityDescription  entityForName:@"User" inManagedObjectContext:context];
    [request setEntity:entity];
    [request setResultType:NSDictionaryResultType];
    [request setReturnsDistinctResults:YES];
    [request setPredicate:[NSPredicate predicateWithFormat:@"name == %@", name]];
    
    NSSortDescriptor *nameSort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [request setReturnsObjectsAsFaults:NO];
    [request setSortDescriptors:@[nameSort]];
    
    NSError *error = nil;
    
    // Fetch the data if possible:
    @try {
        NSError *error;
        NSArray *objects = [context executeFetchRequest:request error:&error];
        if (objects == nil) {
            NSLog(@"Error -- No userdata found in the DB.");
            return nil;
        }
        else{
            NSLog(@"Success -- user data fetched.");
            intel = [objects objectAtIndex: 0];
            return intel;
        }
    }@catch (NSException *exception) {
        NSLog(@"Error fetching user objects: %@\n", exception);
        return nil;
    }
}

///////////////////////////////////////////////////////////////////////////

/*
 Informative function: Show the data in the DB in the logview.
 */
+ (void)showData{
    
    NSManagedObjectContext *context = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).persistentStoreCoordinator.viewContext;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    
    NSSortDescriptor *nameSort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    
    [request setReturnsObjectsAsFaults:NO];
    
    [request setSortDescriptors:@[nameSort]];
    
    NSError *error = nil;
    @try {
        NSArray *results = [context executeFetchRequest:request error:&error];
        NSLog(@"\n--------------------------- DATA ---------------------------\n %@\n------------------------------------------------------------\n", results);
    } @catch (NSException *exception) {
        NSLog(@"Error fetching User objects: %@\n", exception);
    }
}

@end
