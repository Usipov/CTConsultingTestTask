//
//  StoreThumbOperationQueue.h
//  CTConsultingTestTask
//
//  Created by USIPOV TIMUR on 13.02.14.
//  Copyright (c) 2014 USIPOV TIMUR. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ThumbOperationQueue : NSObject

+ (ThumbOperationQueue *)sharedQueue;

- (void)addThumbFetchOperation:(NSOperation *)operation;

- (void)addThumbLoadOperation:(NSOperation *)operation;

- (void)cancelAllOperations;

@end
