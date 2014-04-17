//
//  StoreThumbRequest.h
//  CTConsultingTestTask
//
//  Created by USIPOV TIMUR on 13.02.14.
//  Copyright (c) 2014 USIPOV TIMUR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ThumbView.h"

@interface ThumbRequest : NSObject

@property (nonatomic, retain, readonly) NSString *cacheKey;
@property (nonatomic, retain, readwrite) ThumbView *thumbView;
@property (nonatomic, assign, readonly) NSUInteger targetTag;
@property (nonatomic, assign, readonly) CGSize thumbSize;
@property (nonatomic, retain, readonly) NSString *downloadURL;

-(id)initWithThumbDownloadURL: (NSString *)url thumbView: (ThumbView *)view thumbSize: (CGSize)size;

@end
