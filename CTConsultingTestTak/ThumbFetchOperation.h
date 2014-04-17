//
//  StoreThumbFetchOoperation.h
//  CTConsultingTestTask
//
//  Created by USIPOV TIMUR on 13.02.14.
//  Copyright (c) 2014 USIPOV TIMUR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ThumbRequest.h"

@interface ThumbFetchOperation : NSOperation

-(id)initWithRequest: (ThumbRequest *)request;

@end
