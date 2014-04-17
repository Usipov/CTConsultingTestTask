//
//  User.m
//  CTConsultingTestTask
//
//  Created by Timur on 17.04.14.
//  Copyright (c) 2014 Timur. All rights reserved.
//

#import "User.h"

NSString *const UserEntityName = @"User";

@implementation User

@dynamic bio;
@dynamic fullName;
@dynamic identifier;
@dynamic profilePicture;
@dynamic userName;
@dynamic website;

+(id)insertNewInManagedObjectContext: (NSManagedObjectContext *)context basedOnData: (NSDictionary *)data containingExtraInfo: (BOOL)dataHasExtras orUpdateFetchedItemInstead: (User *__autoreleasing *)userToUpdate;
{
    NSParameterAssert(context && data);
    
    NSString *userIdentifier = data[@"id"];
    
    //try to fetch an existing item
    NSFetchRequest *request = [NSFetchRequest new];
    request.entity = [NSEntityDescription entityForName: UserEntityName inManagedObjectContext: context];
    request.predicate = [NSPredicate predicateWithFormat: @"identifier == %@", userIdentifier];
    
    __autoreleasing NSError *error = nil;
    NSArray *items = [context executeFetchRequest: request error: &error];
    BOOL notFoundExistingUser = (error || items.count == 0);
    
    User *user = nil;
    if (notFoundExistingUser) {
        //create a new object
        user = [NSEntityDescription insertNewObjectForEntityForName: UserEntityName inManagedObjectContext: context];
    } else {
        //will update old object
        NSParameterAssert(items.count == 1);
        user = items.firstObject;
        *userToUpdate = user;
    }
    
    user.userName = data[@"username"];
    user.identifier = userIdentifier;
    user.fullName = data[@"full_name"];
    user.profilePicture = data[@"profile_picture"];
    
    if (dataHasExtras) {
        user.bio = data[@"bio"];
        user.website = data[@"website"];
    }
    
    return notFoundExistingUser ? user : nil;
}

@end
