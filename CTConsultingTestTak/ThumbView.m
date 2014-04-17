//
//  StoreThumbView.m
//  CTConsultingTestTask
//
//  Created by USIPOV TIMUR on 03.03.14.
//  Copyright (c) 2014 USIPOV TIMUR. All rights reserved.
//

#import "ThumbView.h"

@implementation ThumbView

@synthesize operation;
@synthesize thumb = _thumb;

-(void)dealloc
{
    [self.operation cancel];
    self.operation = nil;
    self.thumb = nil;
}

-(void)setThumb:(UIImage *)thumb
{
    if (_thumb != thumb) {
        self.contentMode = UIViewContentModeScaleAspectFill;
        _thumb = thumb;
        self.image = thumb;
    }
}

@end
