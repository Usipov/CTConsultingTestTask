//
//  User.h
//  CTConsultingTestTask
//
//  Created by Timur on 17.04.14.
//  Copyright (c) 2014 Timur. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

extern NSString *const UserEntityName;

@interface User : NSManagedObject

@property (nonatomic, retain) NSString * bio;
@property (nonatomic, retain) NSString * fullName;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSString * profilePicture;
@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSString * website;

+(id)insertNewInManagedObjectContext: (NSManagedObjectContext *)context basedOnData: (NSDictionary *)data containingExtraInfo: (BOOL)dataHasExtras orUpdateFetchedItemInstead: (User *__autoreleasing *)userToUpdate;

@end
