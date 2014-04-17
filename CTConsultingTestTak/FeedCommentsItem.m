//
//  FeedCommentsItem.m
//  CTConsultingTestTask
//
//  Created by Timur on 17.04.14.
//  Copyright (c) 2014 Timur. All rights reserved.
//

#import "FeedCommentsItem.h"

NSString *const FeedCommentsItemEntityName = @"FeedCommentsItem";

@implementation FeedCommentsItem

@dynamic createdTime;
@dynamic identifier;
@dynamic text;
@dynamic fromUser;

+(id)insertNewInManagedObjectContext: (NSManagedObjectContext *)context basedOnData: (NSDictionary *)data user: (User *)user orUpdateFetchedItemInstead: (FeedCommentsItem *__autoreleasing *)commentItemToUpdate
{
    NSParameterAssert(context && data && user);
    
    NSString *commentIdentifier = data[@"id"];
    
    //try to fetch an existing item
    NSFetchRequest *request = [NSFetchRequest new];
    request.entity = [NSEntityDescription entityForName: FeedCommentsItemEntityName inManagedObjectContext: context];
    request.predicate = [NSPredicate predicateWithFormat: @"identifier == %@", commentIdentifier];
    
    __autoreleasing NSError *error = nil;
    NSArray *items = [context executeFetchRequest: request error: &error];
    BOOL notFoundExistingComment = (error || items.count == 0);
    
    FeedCommentsItem *item = nil;
    if (notFoundExistingComment) {
        //create a new object
        item = [NSEntityDescription insertNewObjectForEntityForName: FeedCommentsItemEntityName inManagedObjectContext: context];
    } else {
        //will update old object
        NSParameterAssert(items.count == 1);
        item = items.firstObject;
        if (commentItemToUpdate) {
            *commentItemToUpdate = item;
        }
    }
    
    item.identifier = commentIdentifier;
    item.fromUser = user;
    item.text = data[@"text"];
    item.createdTime = data[@"created_time"];
    
    return notFoundExistingComment ? item : nil;
}

@end
