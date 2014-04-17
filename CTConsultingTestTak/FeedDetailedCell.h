//
//  FeedDetailedCell.h
//  CTConsultingTestTask
//
//  Created by Ultimatum on 17.04.14.
//  Copyright (c) 2014 Timur. All rights reserved.
//

#import "FeedCell.h"

extern NSString *const FeedDetailedCellReuseID;
extern CGFloat FeedDetailedCellPadding;

@interface FeedDetailedCell : FeedCell

@property (nonatomic, retain) UILabel *likesLabel;
@property (nonatomic, retain) UILabel *commentsLabel;

+(UIFont *)likesLabelFont;
+(UIFont *)commentsLabelFont;
+(UILineBreakMode)likesLabelLineBreakMode;
+(UILineBreakMode)commentsLabelLineBreakMode;

@end
