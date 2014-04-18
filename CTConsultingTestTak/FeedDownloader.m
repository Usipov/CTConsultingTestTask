//
//  FeedDownloader.m
//  CTConsultingTestTask
//
//  Created by Timur on 17.04.14.
//  Copyright (c) 2014 Timur. All rights reserved.
//

#import "FeedDownloader.h"
#import "AuthentificationManager.h"

@interface FeedDownloader () {
    NSString *_downloadUrl;
    NSURLConnection *_connection;
    NSMutableData *_recievedData;
}

@property (nonatomic, copy) DownloaderFinishBlock finishBlock;
@property (nonatomic, copy) DownloaderFailBlock failBlock;

@end

@implementation FeedDownloader

+(FeedDownloader *)sharedLoader
{
    static FeedDownloader *st_downloader;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        st_downloader = [self new];
    });
    return st_downloader;
}

-(void)loadFeedTilID: (NSString *)maxFeedItemID withFinishBlock: (DownloaderFinishBlock )finishBlock failBlock: (DownloaderFailBlock)failBlock
{
    if (! _connection) {
        self.finishBlock = finishBlock;
        self.failBlock = failBlock;
        
        if (maxFeedItemID) {
            _downloadUrl = [NSString stringWithFormat: @"https://api.instagram.com/v1/users/self/feed?access_token=%@&count=5&max_id=%@", AuthentificationManager.sharedManager.userToken, maxFeedItemID];
        } else {
            _downloadUrl = [NSString stringWithFormat: @"https://api.instagram.com/v1/users/self/feed?access_token=%@&count=5", AuthentificationManager.sharedManager.userToken];
        }
        
        NSURL *url = [NSURL URLWithString: _downloadUrl];
        NSURLRequest *request = [NSURLRequest requestWithURL: url];
        _connection = [NSURLConnection connectionWithRequest: request delegate: self];
    }
}

-(void)cancel
{
    [_connection cancel];
    _connection = nil;
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if (connection == _connection) {
        _recievedData = [NSMutableData new];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (connection == _connection) {
        [_recievedData appendData: data];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (connection == _connection) {
        //parse json data
        if (NSClassFromString(@"NSJSONSerialization")) {
            __autoreleasing NSError *error = nil;
            id object = [NSJSONSerialization JSONObjectWithData: _recievedData options: 0 error: &error];
            if (error) {
                //tell a caller about a mistake
                if (self.failBlock) {
                    self.failBlock(error);
                }
            } else {
                //continue parsing
                if([object isKindOfClass: [NSDictionary class]]) {
                    NSDictionary *feeds = (NSDictionary *)object;
                    
                    //get a url for next page
                    NSArray *feedsList = feeds[@"data"];
                    NSString *nextMaxID = feeds[@"pagination"][@"next_max_id"];
                    //tell a caller about download complete
                    if (self.finishBlock) {
                        self.finishBlock(feedsList, nextMaxID);
                    }
                }
            }
        }  else {
            //parsing for iOS 4 is not implemented within a test task
            if (self.failBlock) {
                NSDictionary *errorInfo = @{
                                            NSLocalizedDescriptionKey : NSLocalizedString(@"ErorrDescriptionWhileParsing", nil),
                                            NSLocalizedFailureReasonErrorKey : NSLocalizedString(@"ErrorFailureReasonWhileParsing", nil)
                                            };
                
                NSError *error = [NSError errorWithDomain: kErrorDomain code: 0 userInfo: errorInfo];
                
                self.failBlock(error);
            }
        }
    }
    
    _connection = nil;
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (connection == _connection) {
#ifdef DEBUG
        NSLog(@"error in %s", __FUNCTION__);
        NSLog(@"%@", error);
        NSLog(@"%@", connection.currentRequest.URL);
#endif
        if (self.failBlock) {
            self.failBlock(error);
        }
    }
}

@end
