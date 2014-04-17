//
//  FeedDownloader.h
//  CTConsultingTestTask
//
//  Created by Timur on 17.04.14.
//  Copyright (c) 2014 Timur. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FeedDownloader : NSObject

typedef void (^DownloaderFinishBlock) (NSArray *feeds, NSString *nextMaxID);
typedef void (^DownloaderFailBlock) (NSError *);

+(FeedDownloader *)sharedLoader;
-(void)loadFeedTilID: (NSString *)maxFeedItemID withFinishBlock: (DownloaderFinishBlock)finishBlock failBlock: (DownloaderFailBlock)failBlock;
-(void)cancel;
@end
