//
//  FeedViewCell.m
//  CTConsultingTestTask
//
//  Created by Timur on 17.04.14.
//  Copyright (c) 2014 Timur. All rights reserved.
//

#import "FeedCell.h"

NSString *const FeedCellReuseID = @"general cell";
CGFloat const FeedCellHeight = 364.0f;

@implementation FeedCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)prepareForReuse
{
    [super prepareForReuse];
    
    [self.contentPreviewView removeFromSuperview];
    self.contentPreviewView = nil;
    [self.userProfilePictureView removeFromSuperview];
    self.userProfilePictureView = nil;
    self.textLabel.text = nil;
    self.detailTextLabel.text = nil;
}

-(ThumbView *)userProfilePictureView
{
    if (! _userProfilePictureView) {
        _userProfilePictureView = [[ThumbView alloc] initWithFrame: CGRectZero];
        [self addSubview: _userProfilePictureView];
    }
    return _userProfilePictureView;
}

-(ThumbView *)contentPreviewView
{
    if (! _contentPreviewView) {
        _contentPreviewView = [[ThumbView alloc] initWithFrame: CGRectZero];
        [self addSubview: _contentPreviewView];
    }
    return _contentPreviewView;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat padding = 7.0f;
    CGFloat userThumbSize = 30.0f;
    
    CGRect textLabelFrame = self.textLabel.frame;
    textLabelFrame.origin.x += 2 * padding + userThumbSize;
    textLabelFrame.size.width = CGRectGetWidth(self.bounds) - textLabelFrame.origin.x;
    textLabelFrame.origin.y = 0.0f;
    textLabelFrame.size.height = 44.0f;
    self.textLabel.frame = textLabelFrame;
    
    CGRect userThumbFrame = CGRectMake(padding, padding, userThumbSize, userThumbSize);
    self.userProfilePictureView.frame = userThumbFrame;
    
    CGRect contentThumbFrame;
    contentThumbFrame.origin.x = 0.0;
    contentThumbFrame.origin.y = CGRectGetMaxY(self.textLabel.bounds);
    contentThumbFrame.size.width = CGRectGetWidth(self.bounds);
    contentThumbFrame.size.height = FeedCellHeight - contentThumbFrame.origin.y;
    self.contentPreviewView.frame = contentThumbFrame;
    
}

@end
