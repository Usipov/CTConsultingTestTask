//
//  FeedCaptionItem.h
//  CTConsultingTestTask
//
//  Created by Timur on 17.04.14.
//  Copyright (c) 2014 Timur. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "User.h"

extern NSString *const FeedCaptionItemEntityName;

@interface FeedCaptionItem : NSManagedObject

+(id)insertNewInManagedObjectContext: (NSManagedObjectContext *)context basedOnData: (NSDictionary *)data user: (User *)user orUpdateFetchedItemInstead: (FeedCaptionItem *__autoreleasing *)captionItemToUpdate;

@property (nonatomic, retain) NSString * createdTime;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) User *fromUser;

@end
