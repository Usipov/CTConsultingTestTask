//
//  StoreThumbCache.m
//  OstrovokHotels
//
//  Created by USIPOV TIMUR on 13.02.14.
//  Copyright (c) 2014 USIPOV TIMUR. All rights reserved.
//

#import "ThumbCache.h"
#import "ThumbFetchOperation.h"
#import "ThumbOperationQueue.h"

#ifdef DEBUG
#define IMAGE_UP_TO_DATE_INTERVAL 100 //a time period during which an image is treated as an up-to-date
#else
#define IMAGE_UP_TO_DATE_INTERVAL 3600 //a time period during which an image is treated as an up-to-date
#endif

#define THUMBS_DIRECTORY_NAME @"Thumbs"

@interface ThumbCache () {
    NSCache *_thumbCache;
}

-(void)purgeOutOfDateThumbs;
-(NSString *)thumbsContainingDirectory;

@end

@implementation ThumbCache

-(id)init
{
    self = [super init];
    if (self) {
        _thumbCache = [NSCache new];
        [_thumbCache setName: @"ThumbCache"];
        [_thumbCache setTotalCostLimit: 2097152];
        [self purgeOutOfDateThumbs];
    }
    return self;
}

+(id)sharedCache
{
    static ThumbCache *cache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [self new];
    });
    return cache;
}

-(UIImage *)thumbImageForRequest: (ThumbRequest *)request
{
    NSParameterAssert(request);
    id obj = nil;

    @synchronized(_thumbCache) { //mutex lock
        obj = [_thumbCache objectForKey: request.cacheKey];
        if (! obj) {            
            //prepare a fetch operation
            ThumbFetchOperation *fetchOperation = [[ThumbFetchOperation alloc] initWithRequest: request];
            request.thumbView.operation = fetchOperation;
            
            //start an operation
            [[ThumbOperationQueue sharedQueue] addThumbFetchOperation: fetchOperation];
        }
    }
    
    return obj;
}

-(void)trashThumbOnRequeset: (ThumbRequest *)request
{
    NSParameterAssert(request);
 
    @synchronized(_thumbCache) { //mutex lock
        [_thumbCache removeObjectForKey: request.cacheKey];
        NSFileManager *fm = [NSFileManager new];
        [fm removeItemAtPath: [self thumbPathOnRequest: request] error: nil];
    }
}

-(NSString *)thumbPathOnRequest: (ThumbRequest *)request
{
    NSString *directoryPath = [self thumbsContainingDirectory];
    NSString *thumbName = [[[[request.downloadURL
                             stringByReplacingOccurrencesOfString: @"/" withString: @"-"]
                             stringByReplacingOccurrencesOfString: @"/" withString: @"-"]
                             stringByReplacingOccurrencesOfString: @":" withString: @"_"]
                             stringByDeletingPathExtension];
    NSString *thumbFileName = [NSString stringWithFormat: @"%@__%05d__%05d.png", thumbName, (int)request.thumbSize.width, (int)request.thumbSize.height];
    return [directoryPath stringByAppendingPathComponent: thumbFileName];
}

-(void)setThumbImage:(UIImage *)image forKey:(NSString *)key
{
    NSParameterAssert(image && key);
    @synchronized(_thumbCache) {
        [_thumbCache setObject: image forKey: key];
    }
}

-(void)removeAllObjects
{
    @synchronized(_thumbCache) {
        [_thumbCache removeAllObjects];
    }
}

#pragma mark - privates

-(void)purgeOutOfDateThumbs
{
    NSString *directoryPath = [self thumbsContainingDirectory];

    NSMutableSet *filePathsToPurge = [NSMutableSet new];
    NSFileManager *fm = [NSFileManager new];
    
    //seek for out-of-date thumb files
    [[fm contentsOfDirectoryAtPath: directoryPath error: nil] enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *thumbFileName = (NSString *)obj;
        NSString *thumbFilePath = [directoryPath stringByAppendingPathComponent: thumbFileName];
        
        NSDictionary *fileAttributes = [fm attributesOfItemAtPath: thumbFilePath error: nil];
        NSDate *creationDate = [fileAttributes fileCreationDate];
        if (abs(creationDate.timeIntervalSinceNow) > IMAGE_UP_TO_DATE_INTERVAL) {
            //will purge file
            [filePathsToPurge addObject: thumbFilePath];
        }
    }];
    
    //purge files
    [filePathsToPurge enumerateObjectsUsingBlock: ^(id obj, BOOL *stop) {
        NSString *filePath = (NSString *)obj;
        [fm removeItemAtPath: filePath error: nil];
    }];
}

-(NSString *)thumbsContainingDirectory
{
    NSString *directoryName = THUMBS_DIRECTORY_NAME;
    NSString *cachesDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex: 0];
    NSString *directoryPath = [cachesDir stringByAppendingPathComponent: directoryName];

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSFileManager *fm = [NSFileManager new];
        if (! [fm fileExistsAtPath: directoryPath]) {
            [fm createDirectoryAtPath: directoryPath withIntermediateDirectories: YES attributes: nil error: nil];
        }
    });
    
    return directoryPath;
}

@end
