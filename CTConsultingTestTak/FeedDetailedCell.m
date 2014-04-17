//
//  FeedDetailedCell.m
//  CTConsultingTestTask
//
//  Created by Ultimatum on 17.04.14.
//  Copyright (c) 2014 Timur. All rights reserved.
//

#import "FeedDetailedCell.h"
#import "NSObject+TextSizesComputer.h"

NSString *const FeedDetailedCellReuseID = @"detailed cell";
CGFloat FeedDetailedCellPadding = 15.0f;

@implementation FeedDetailedCell

+(UIFont *)likesLabelFont
{
    return [UIFont systemFontOfSize: 13.0f];
}

+(UIFont *)commentsLabelFont
{
    return [UIFont systemFontOfSize: 13.0f];
}

+(UILineBreakMode)likesLabelLineBreakMode
{
    return UILineBreakModeWordWrap;
}

+(UILineBreakMode)commentsLabelLineBreakMode
{
    return UILineBreakModeWordWrap;
}

-(UILabel *)likesLabel
{
    if (! _likesLabel) {
        _likesLabel = [[UILabel alloc] initWithFrame: CGRectZero];
        _likesLabel.font = [self.class likesLabelFont];
        _likesLabel.lineBreakMode = [self.class likesLabelLineBreakMode];
        _likesLabel.numberOfLines = 0;
        [self addSubview: _likesLabel];
    }
    return _likesLabel;
}

-(UILabel *)commentsLabel
{
    if (! _commentsLabel) {
        _commentsLabel = [[UILabel alloc] initWithFrame: CGRectZero];
        _commentsLabel.font = [self.class commentsLabelFont];
        _commentsLabel.lineBreakMode = [self.class commentsLabelLineBreakMode];
        _commentsLabel.numberOfLines = 0;
        [self addSubview: _commentsLabel];
    }
    return _commentsLabel;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize constraintSize = CGSizeMake(CGRectGetWidth(self.bounds) - FeedDetailedCellPadding, CGFLOAT_MAX);
    
    CGRect commentsLabelFrame;
    commentsLabelFrame.origin.x = FeedDetailedCellPadding;
    commentsLabelFrame.origin.y = CGRectGetMaxY(self.contentPreviewView.frame) + FeedDetailedCellPadding;
    commentsLabelFrame.size = [NSObject computeSizeOfText: self.commentsLabel.text withFont: self.commentsLabel.font linebreakMode: self.commentsLabel.lineBreakMode constrainedToSize: constraintSize];
    self.commentsLabel.frame = commentsLabelFrame;
    
    CGRect likesLabelFrame;
    likesLabelFrame.origin.x = FeedDetailedCellPadding;
    likesLabelFrame.origin.y = CGRectGetMaxY(self.commentsLabel.frame) + FeedDetailedCellPadding;
    likesLabelFrame.size = [NSObject computeSizeOfText: self.likesLabel.text withFont: self.likesLabel.font linebreakMode: self.likesLabel.lineBreakMode constrainedToSize: constraintSize];
    self.likesLabel.frame = likesLabelFrame;
    
    
}

@end
