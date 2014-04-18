//
//  FeedRecord.h
//  CTConsultingTestTask
//
//  Created by Timur on 17.04.14.
//  Copyright (c) 2014 Timur. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

extern NSString *const FeedRecordEntityName;

typedef NS_ENUM(NSUInteger, ImageQuality) {
    ImageQualityStandard, //640x640
    ImageQualityLow,    //306x306
    ImageQualityThumb //150x150
};

typedef NS_ENUM(NSUInteger, VideoResolutionType) {
    VideoResolutionStandard,
    VideoResolutionLow,
};



@class FeedCommentsItem, User, FeedCaptionItem, ImageData, VideoData;

@interface FeedRecord : NSManagedObject

@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) id attribution;
@property (nonatomic, retain) NSNumber * commentsCount;
@property (nonatomic, retain) NSNumber * likesCount;
@property (nonatomic, retain) NSString * createdTime;
@property (nonatomic, retain) NSString * filter;
@property (nonatomic, retain) id images;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) id location;
@property (nonatomic, retain) id tags;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSNumber * userHasLiked;
@property (nonatomic, retain) id videos;
@property (nonatomic, retain) id usersInPhoto;
@property (nonatomic, retain) NSSet *comments;
@property (nonatomic, retain) NSSet *likersPreview;
@property (nonatomic, retain) User *user;
@property (nonatomic, retain) FeedCaptionItem *caption;

+(id)insertNewInManagedObjectContext: (NSManagedObjectContext *)context basedOnData: (NSDictionary *)data orUpdateFetchedItemInstead: (FeedRecord *__autoreleasing *)feedRecordToUpdate;
+(void)deleteAllInManagedObjectContext: (NSManagedObjectContext *)context;
+(NSFetchedResultsController *)fetchedResultsContollerInManagedObjectContext: (NSManagedObjectContext *)context;
-(ImageData *)imageDataForImageQuality: (ImageQuality)quality;
-(VideoData *)videoDataForVideoResolution: (VideoResolutionType)resolution;

@end

#pragma mark -

@interface FeedRecord (CoreDataGeneratedAccessors)

- (void)addCommentsObject:(FeedCommentsItem *)value;
- (void)removeCommentsObject:(FeedCommentsItem *)value;
- (void)addComments:(NSSet *)values;
- (void)removeComments:(NSSet *)values;

- (void)addLikersPreviewObject:(NSManagedObject *)value;
- (void)removeLikersPreviewObject:(NSManagedObject *)value;
- (void)addLikersPreview:(NSSet *)values;
- (void)removeLikersPreview:(NSSet *)values;

@end

#pragma mark -

@interface ImageData : NSObject

@property (nonatomic, retain) NSString *url;
@property (nonatomic, assign) CGSize size;

@end

#pragma mark -

@interface VideoData : NSObject

@property (nonatomic, retain) NSString *url;
@property (nonatomic, assign) CGSize size;

@end
