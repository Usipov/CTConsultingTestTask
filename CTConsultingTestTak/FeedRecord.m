//
//  FeedRecord.m
//  CTConsultingTestTask
//
//  Created by Timur on 17.04.14.
//  Copyright (c) 2014 Timur. All rights reserved.
//

#import "FeedRecord.h"
#import "FeedCommentsItem.h"
#import "User.h"
#import "FeedCaptionItem.h"

NSString *const FeedRecordEntityName = @"FeedRecord";
NSString *const FeedRecordCacheName = @"FeedRecordCache";

@interface FeedRecord ()

-(void)setCaptionBasedOnData: (NSDictionary *)data inManagedObjectContext: (NSManagedObjectContext *)context;
-(void)setUserBasedOnData: (NSDictionary *)data inManagedObjectContext: (NSManagedObjectContext *)context;
-(void)setCommentsBasedOnData: (NSArray *)data inManagedObjectContext: (NSManagedObjectContext *)context;
-(void)setLikersPreviewBasedOnData: (NSArray *)data inManagedObjectContext: (NSManagedObjectContext *)context;
-(User *)findUserBasedOnData: (NSDictionary *)data inManagedObjectContext: (NSManagedObjectContext *)context;

@end

@implementation FeedRecord

@dynamic identifier;
@dynamic attribution;
@dynamic commentsCount;
@dynamic likesCount;
@dynamic createdTime;
@dynamic filter;
@dynamic images;
@dynamic link;
@dynamic location;
@dynamic tags;
@dynamic type;
@dynamic userHasLiked;
@dynamic videos;
@dynamic usersInPhoto;
@dynamic comments;
@dynamic likersPreview;
@dynamic user;
@dynamic caption;

+(id)insertNewInManagedObjectContext: (NSManagedObjectContext *)context basedOnData: (NSDictionary *)data orUpdateFetchedItemInstead: (FeedRecord *__autoreleasing *)feedRecordToUpdate
{
    NSParameterAssert(data && context);
    
    NSString *identifier = data[@"id"];
    
    //try to fetch an existing item
    NSFetchRequest *request = [NSFetchRequest new];
    request.entity = [NSEntityDescription entityForName: FeedRecordEntityName inManagedObjectContext: context];
    request.predicate = [NSPredicate predicateWithFormat: @"identifier == %@", identifier];
    
    __autoreleasing NSError *error = nil;
    NSArray *items = [context executeFetchRequest: request error: &error];
    BOOL notFoundExistingRecord = (error || items.count == 0);
    
    FeedRecord *record = nil;
    if (notFoundExistingRecord) {
        //create a new object
        record = [NSEntityDescription insertNewObjectForEntityForName: FeedRecordEntityName inManagedObjectContext: context];
    } else {
        //will update old object
        NSParameterAssert(items.count == 1);
        record = items.firstObject;
        if (feedRecordToUpdate) {
            *feedRecordToUpdate = record;
        }
    }
    
    //set primitive properties
    record.attribution = data[@"attribution"];
    record.commentsCount = data[@"comments"][@"count"];
    record.createdTime = data[@"created_time"];
    record.filter = data[@"filter"];
    record.images = data[@"images"];
    record.likesCount = data[@"likes"][@"count"];
    record.link = data[@"link"];
    record.location = data[@"location"];
    record.tags = data[@"tags"];
    record.type = data[@"type"];
    record.userHasLiked = data[@"user_has_liked"];
    record.usersInPhoto = data[@"users_in_photo"];
    record.identifier = identifier;
    record.videos = data[@"videos"];
    
    //set advanced properties
    [record setCaptionBasedOnData: data[@"caption"] inManagedObjectContext: context];
    [record setCommentsBasedOnData: data[@"comments"][@"data"] inManagedObjectContext: context];
    [record setLikersPreviewBasedOnData : data[@"likes"][@"data"] inManagedObjectContext: context];
    [record setUserBasedOnData: data[@"user"] inManagedObjectContext: context];
    
    return notFoundExistingRecord ? record : nil;
}

+(void)deleteAllInManagedObjectContext: (NSManagedObjectContext *)context
{
    NSParameterAssert(context);
    
    NSFetchRequest *request = [NSFetchRequest new];
    request.entity = [NSEntityDescription entityForName: FeedRecordEntityName inManagedObjectContext: context];
    [[context executeFetchRequest: request error: nil] enumerateObjectsUsingBlock: ^(FeedRecord *record, NSUInteger idx, BOOL *stop) {
        [context deleteObject: record];
    }];
}

+(NSFetchedResultsController *)fetchedResultsContollerInManagedObjectContext: (NSManagedObjectContext *)context
{
    NSParameterAssert(context);
    
    NSFetchRequest *request = [NSFetchRequest new];
    request.entity = [NSEntityDescription entityForName: FeedRecordEntityName inManagedObjectContext: context];
    request.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey: @"createdTime" ascending: NO]];
    request.fetchBatchSize = 50;
    return [[NSFetchedResultsController alloc] initWithFetchRequest: request managedObjectContext: context sectionNameKeyPath: nil cacheName: FeedRecordCacheName];
}

-(ImageData *)imageDataForImageQuality: (ImageQuality)quality
{
    NSString *key;
    
    switch (quality) {
        case ImageQualityLow:
            key = @"low_resolution";
            break;
        case ImageQualityStandard:
            key = @"standard_resolution";
            break;
        case ImageQualityThumb:
            key = @"thumbnail";
            break;
        default:
            break;
    }
    
    NSParameterAssert(key);

    ImageData *data = [ImageData new];
    data.url = self.images[key][@"url"];
    data.size = CGSizeMake([self.images[key][@"width"] floatValue],
                           [self.images[key][@"height"] floatValue]);
    
    return data;
}

-(VideoData *)videoDataForVideoResolution: (VideoResolutionType)resolution
{
    NSString *key;
    
    switch (resolution) {
        case VideoResolutionLow:
            key = @"low_resolution";
            break;
        case VideoResolutionStandard:
            key = @"standard_resolution";
            break;
        default:
            break;
    }
    
    NSParameterAssert(key);
    
    VideoData *data = [VideoData new];
    data.url = self.videos[key][@"url"];
    data.size = CGSizeMake([self.images[key][@"width"] floatValue],
                           [self.images[key][@"height"] floatValue]);
    
    return data;
}

#pragma mark - extensions

-(void)setCaptionBasedOnData: (NSDictionary *)data inManagedObjectContext: (NSManagedObjectContext *)context
{
    NSParameterAssert(data);
    User *user = [self findUserBasedOnData: data[@"from"] inManagedObjectContext: context];
    
    __autoreleasing FeedCaptionItem *oldItem = nil;
    FeedCaptionItem *newItem = [FeedCaptionItem insertNewInManagedObjectContext: context basedOnData: data user: user orUpdateFetchedItemInstead: &oldItem];
    self.caption = newItem ? newItem : oldItem;
}

-(void)setUserBasedOnData: (NSDictionary *)data inManagedObjectContext: (NSManagedObjectContext *)context
{
    NSParameterAssert(data);
    self.user = [self findUserBasedOnData: data inManagedObjectContext: context];
}

-(void)setCommentsBasedOnData: (NSArray *)data inManagedObjectContext: (NSManagedObjectContext *)context
{
    NSParameterAssert(data);

    NSMutableSet *comments = [NSMutableSet set];
    [data enumerateObjectsUsingBlock: ^(NSDictionary *commentData, NSUInteger idx, BOOL *stop) {
        User *user = [self findUserBasedOnData: commentData[@"from"] inManagedObjectContext: context];
        
        __autoreleasing FeedCommentsItem *oldItem = nil;
        FeedCommentsItem *newItem = [FeedCommentsItem insertNewInManagedObjectContext: context basedOnData: commentData user: user orUpdateFetchedItemInstead: &oldItem];
        [comments addObject: newItem ? newItem : oldItem];
    }];
    
    self.comments = comments;
}

-(void)setLikersPreviewBasedOnData: (NSArray *)data inManagedObjectContext: (NSManagedObjectContext *)context
{
    NSParameterAssert(data);
    
    NSMutableSet *likersPreview = [NSMutableSet set];
    [data enumerateObjectsUsingBlock: ^(NSDictionary *likerData, NSUInteger idx, BOOL *stop) {
        User *user = [self findUserBasedOnData: likerData inManagedObjectContext: context];
        [likersPreview addObject: user];
    }];
    
    self.likersPreview = likersPreview;
}

-(User *)findUserBasedOnData: (NSDictionary *)data inManagedObjectContext: (NSManagedObjectContext *)context
{
    NSParameterAssert(data);
    
    __autoreleasing User *fetchedUser = nil;
    User *newUser = [User insertNewInManagedObjectContext: context basedOnData: data containingExtraInfo: (data.allKeys.count > 4) orUpdateFetchedItemInstead: &fetchedUser];
    return newUser ? newUser : fetchedUser;
}

@end

#pragma mark -

@implementation ImageData

@end

#pragma mark -

@implementation VideoData

@end