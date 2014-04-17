//
//  StoreThumbCache.h
//  OstrovokHotels
//
//  Created by USIPOV TIMUR on 13.02.14.
//  Copyright (c) 2014 USIPOV TIMUR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ThumbRequest.h"

@interface ThumbCache : NSObject

+(id)sharedCache;
-(id)thumbImageForRequest: (ThumbRequest *)request;
-(void)trashThumbOnRequeset: (ThumbRequest *)request;
-(NSString *)thumbPathOnRequest: (ThumbRequest *)request;
-(void)setThumbImage:(UIImage *)image forKey:(NSString *)key;
-(void)removeAllObjects;
@end
