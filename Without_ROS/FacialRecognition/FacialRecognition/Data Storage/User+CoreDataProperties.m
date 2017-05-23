//
//  User+CoreDataProperties.m
//  
//
//  Created by Emilie on 13/04/17.
//
//

#import "User+CoreDataProperties.h"

@implementation User (CoreDataProperties)

+ (NSFetchRequest<User *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"User"];
}

@dynamic job;
@dynamic name;

@end
