//
//  StoreThumbOperationQueue.m
//  OstrovokHotels
//
//  Created by USIPOV TIMUR on 13.02.14.
//  Copyright (c) 2014 USIPOV TIMUR. All rights reserved.
//

#import "ThumbOperationQueue.h"
#import "ThumbFetchOperation.h"
#import "ThumbLoadOperation.h"

@interface ThumbOperationQueue () {
    NSOperationQueue *_fetchQueue;
    NSOperationQueue *_loadQueue;
}

@end

@implementation ThumbOperationQueue

- (id)init
{
    self = [super init];
	if (self) {
		_fetchQueue = [NSOperationQueue new];
		[_fetchQueue setName: @"ThumbFetchQueue"];
        
		_loadQueue = [NSOperationQueue new];
		[_loadQueue setName: @"ThumbLoadQueue"];
        
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(cancelAllOperations) name: kApplicationWillTerminateNotification object: nil];
	}
	return self;
}

+ (ThumbOperationQueue *)sharedQueue
{
    static ThumbOperationQueue *queue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = [self new];
    });
    return queue;
}

- (void)addThumbFetchOperation:(NSOperation *)operation
{
    if ([operation isKindOfClass: [ThumbFetchOperation self]]) {
        [_fetchQueue addOperation: operation];
    }
}

- (void)addThumbLoadOperation:(NSOperation *)operation
{
    if ([operation isKindOfClass: [ThumbLoadOperation self]]) {
        [_loadQueue addOperation: operation];
    }
}

- (void)cancelAllOperations
{
    [_fetchQueue cancelAllOperations];
    [_loadQueue cancelAllOperations];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

@end
