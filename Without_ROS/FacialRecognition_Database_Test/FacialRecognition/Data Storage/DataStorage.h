//
//  DataStorage.h
//  FacialRecognition
//
//  Created by Kilian on 13/04/17.
//  Copyright © 2017 Kilian Michiels. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "User+CoreDataProperties.h"

@interface DataStorage : NSObject

+ (BOOL)addUser:(NSString*)name user_tag:(NSString*)user_tag;

+ (BOOL)checkForUserExistance:(NSString*) name;

+ (NSDictionary *)getUserIntel:(NSString*)name;

+ (void)showData;

+ (void)deleteData;
@end
