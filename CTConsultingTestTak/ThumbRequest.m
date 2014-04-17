//
//  StoreThumbRequest.m
//  OstrovokHotels
//
//  Created by USIPOV TIMUR on 13.02.14.
//  Copyright (c) 2014 USIPOV TIMUR. All rights reserved.
//

#import "ThumbRequest.h"

@interface ThumbRequest ()

@property (nonatomic, retain, readwrite) NSString *cacheKey;
@property (nonatomic, assign, readwrite) NSUInteger targetTag;
@property (nonatomic, assign, readwrite) CGSize thumbSize;
@property (nonatomic, retain, readwrite) NSString *downloadURL;
@end

@implementation ThumbRequest

@synthesize cacheKey, thumbView, targetTag, thumbSize, downloadURL;

-(id)initWithThumbDownloadURL: (NSString *)url thumbView: (ThumbView *)view thumbSize: (CGSize)size
{
    self = [super init];
    if (self) {
        self.thumbSize = size;
        self.thumbView = view;
        self.cacheKey = [NSString stringWithFormat: @"%@ %05d %05d", url, (int)size.width, (int)size.height];
        self.targetTag = self.cacheKey.hash;
        self.thumbView.tag = self.targetTag;
        self.downloadURL = url;
    }
    return self;
}

@end
