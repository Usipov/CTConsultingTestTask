//
//  StoreThumbFetchOoperation.m
//  CTConsultingTestTask
//
//  Created by USIPOV TIMUR on 13.02.14.
//  Copyright (c) 2014 USIPOV TIMUR. All rights reserved.
//

#import "ThumbFetchOperation.h"
#import "ThumbLoadOperation.h"
#import "ThumbCache.h"
#import "ThumbOperationQueue.h"

#ifdef DEBUG
#define NON_PURGABLE_IMAGE_UP_TO_DATE_INTERVAL (100) //100 secs
#else
#define NON_PURGABLE_IMAGE_UP_TO_DATE_INTERVAL (7 * 86400) //7 days
#endif

@interface ThumbFetchOperation () {
    ThumbRequest *_request;
}

@end

@implementation ThumbFetchOperation

-(id)initWithRequest: (ThumbRequest *)request
{
    NSParameterAssert(request);
    self = [super init];
    if (self) {
        _request = request;
    }
    return self;
}

-(void)main
{
    @autoreleasepool {
        NSFileManager *fileManager = [NSFileManager new];
        NSString *thumbPath = [[ThumbCache sharedCache] thumbPathOnRequest: _request];

        BOOL thumbExists = [fileManager fileExistsAtPath: thumbPath];
        BOOL shouldDownloadloadThumb = ! thumbExists;
        
        if (thumbExists) {
            //fetch an image, cache it and set it
            UIImage *thumbImage = [UIImage imageWithContentsOfFile: thumbPath];
            if (thumbImage) {
                if (! self.isCancelled) {
                    [[ThumbCache sharedCache] setThumbImage: thumbImage forKey: _request.cacheKey];
                    if (_request.targetTag == _request.thumbView.tag) {
                        dispatch_async(dispatch_get_main_queue(),  ^{
                            _request.thumbView.thumb = thumbImage;
                        });
                    }
                }
            } else {
                shouldDownloadloadThumb = YES;
            }
        }
        
        if (shouldDownloadloadThumb) {
            
            //start downloading image
            ThumbLoadOperation *loadOperation = [[ThumbLoadOperation alloc] initWithRequest: _request];
            
            if (! self.isCancelled) {
                _request.thumbView.operation = loadOperation;
                [[ThumbOperationQueue sharedQueue] addThumbLoadOperation: loadOperation];
            }
        } else {
            _request.thumbView.operation = nil; //break retain loop
        }
    }
}

-(void)cancel
{
    [super cancel];
    _request.thumbView.operation = nil; //break retain loop
}

@end
