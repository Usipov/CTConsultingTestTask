//
//  StoreThumbView.h
//  CTConsultingTestTask
//
//  Created by USIPOV TIMUR on 03.03.14.
//  Copyright (c) 2014 USIPOV TIMUR. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ThumbView : UIImageView 

@property (nonatomic, retain)    UIImage                 *thumb;
@property (atomic, retain)       NSOperation             *operation;

@end
