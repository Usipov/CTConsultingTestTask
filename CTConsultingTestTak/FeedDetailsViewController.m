//
//  FeedDetailsViewController.m
//  CTConsultingTestTask
//
//  Created by Timur on 17.04.14.
//  Copyright (c) 2014 Timur. All rights reserved.
//

#import "FeedDetailsViewController.h"
#import "CoreDataManager.h"
#import "ThumbCache.h"
#import "FeedDetailedCell.h"
#import "NSObject+TextSizesComputer.h"

@interface FeedDetailsViewController () {
    NSMutableString *_likesString;
    NSMutableString *_commentsString;
}

@end

@implementation FeedDetailsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"details", nil);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

-(void)setFeedItem:(FeedRecord *)feedItem
{
    _feedItem = feedItem;
    
    _likesString = [NSMutableString stringWithFormat: NSLocalizedString(@"likes", nil), feedItem.likesCount.integerValue];
    [feedItem.likersPreview enumerateObjectsUsingBlock: ^(User *user, BOOL *stop) {
        [_likesString appendFormat: @"%@ ,", user.userName];
    }];
    [_likesString replaceCharactersInRange: NSMakeRange(_likesString.length - 2, 2) withString: @""]; //remove last @" ,"
    
    _commentsString = [NSMutableString stringWithFormat: @"%@: %@\n", feedItem.user.userName, feedItem.caption.text];
    [_commentsString appendFormat: NSLocalizedString(@"comments", nil), feedItem.commentsCount.integerValue];
    [feedItem.comments enumerateObjectsUsingBlock: ^(FeedCommentsItem *comment, BOOL *stop) {
        [_commentsString appendFormat: @"%@: %@\n", comment.fromUser.userName, comment.text];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FeedDetailedCell *cell = [tableView dequeueReusableCellWithIdentifier: FeedDetailedCellReuseID];
    if (! cell) {
        cell = [[FeedDetailedCell alloc] initWithStyle: UITableViewCellStyleSubtitle reuseIdentifier: FeedDetailedCellReuseID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.textLabel.text = _feedItem.user.userName;
    
    //user profile image
    ThumbRequest *request = [[ThumbRequest alloc] initWithThumbDownloadURL: _feedItem.user.profilePicture thumbView: cell.userProfilePictureView thumbSize: CGSizeMake(30.0, 30.0f)];
    cell.userProfilePictureView.thumb = [[ThumbCache sharedCache] thumbImageForRequest: request];
    
    //content image
    ImageData *imageData = [_feedItem imageDataForImageQuality: ImageQualityStandard];
    request = [[ThumbRequest alloc] initWithThumbDownloadURL: imageData.url thumbView: cell.contentPreviewView thumbSize: CGSizeMake(320.0f, 320.0f)];
    cell.contentPreviewView.thumb = [[ThumbCache sharedCache] thumbImageForRequest: request];
    
    //likers
    cell.likesLabel.text = _likesString;
    
    //comments
    cell.commentsLabel.text = _commentsString;
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize constraintSize = CGSizeMake(320.0f - FeedDetailedCellPadding, CGFLOAT_MAX);
    
    CGFloat height = FeedCellHeight; //base height
    height += FeedDetailedCellPadding;
    height += [NSObject computeSizeOfText: _likesString withFont: [FeedDetailedCell likesLabelFont] linebreakMode: [FeedDetailedCell likesLabelLineBreakMode] constrainedToSize: constraintSize].height;
    height += FeedDetailedCellPadding;
    height += [NSObject computeSizeOfText: _commentsString withFont: [FeedDetailedCell commentsLabelFont] linebreakMode: [FeedDetailedCell commentsLabelLineBreakMode] constrainedToSize: constraintSize].height;
    height += FeedDetailedCellPadding;
    return height;
}

@end
