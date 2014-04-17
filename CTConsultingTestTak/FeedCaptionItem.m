//
//  FeedCaptionItem.m
//  CTConsultingTestTask
//
//  Created by Timur on 17.04.14.
//  Copyright (c) 2014 Timur. All rights reserved.
//

#import "FeedCaptionItem.h"

NSString *const FeedCaptionItemEntityName = @"FeedCaptionItem";

@implementation FeedCaptionItem

@dynamic createdTime;
@dynamic identifier;
@dynamic text;
@dynamic fromUser;

+(id)insertNewInManagedObjectContext: (NSManagedObjectContext *)context basedOnData: (NSDictionary *)data user: (User *)user orUpdateFetchedItemInstead: (FeedCaptionItem *__autoreleasing *)captionItemToUpdate
{
    NSParameterAssert(context && data && user);
    
    NSString *captionIdentifier = data[@"id"];
    
    //try to fetch an existing item
    NSFetchRequest *request = [NSFetchRequest new];
    request.entity = [NSEntityDescription entityForName: FeedCaptionItemEntityName inManagedObjectContext: context];
    request.predicate = [NSPredicate predicateWithFormat: @"identifier == %@", captionIdentifier];
    
    __autoreleasing NSError *error = nil;
    NSArray *items = [context executeFetchRequest: request error: &error];
    BOOL notFoundExistingCaption = (error || items.count == 0);
    
    FeedCaptionItem *item = nil;
    if (notFoundExistingCaption) {
        //create a new object
        item = [NSEntityDescription insertNewObjectForEntityForName: FeedCaptionItemEntityName inManagedObjectContext: context];
    } else {
        //will update old object
        NSParameterAssert(items.count == 1);
        item = items.firstObject;
        if (captionItemToUpdate) {
            *captionItemToUpdate = item;
        }
    }
    
    item.identifier = captionIdentifier;
    item.fromUser = user;
    item.text = data[@"text"];
    item.createdTime = data[@"created_time"];
    
    return notFoundExistingCaption ? item : nil;
}

@end
