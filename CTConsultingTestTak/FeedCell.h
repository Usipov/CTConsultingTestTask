//
//  FeedViewCell.h
//  CTConsultingTestTask
//
//  Created by Timur on 17.04.14.
//  Copyright (c) 2014 Timur. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ThumbView.h"

extern NSString *const FeedCellReuseID;
extern CGFloat const FeedCellHeight;

@interface FeedCell : UITableViewCell

@property (nonatomic, retain) ThumbView *userProfilePictureView;
@property (nonatomic, retain) ThumbView *contentPreviewView;

@end
