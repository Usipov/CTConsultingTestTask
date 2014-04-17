//
//  StoreThumbLoadOperation.m
//  OstrovokHotels
//
//  Created by USIPOV TIMUR on 13.02.14.
//  Copyright (c) 2014 USIPOV TIMUR. All rights reserved.
//

#import "ThumbLoadOperation.h"
#import "ThumbCache.h"

@interface ThumbLoadOperation () <NSURLConnectionDelegate> {
    ThumbRequest *_request;
    NSMutableData *_downloadedData;
    NSURLConnection *_connection;
    NSPort *_port;
}

@end

@implementation ThumbLoadOperation

-(id)initWithRequest: (ThumbRequest *)request
{
    NSParameterAssert(request);
    self = [super init];
    if (self) {
        _request = request;
    }
    return self;
}

-(void)main
{
    @autoreleasepool {        
        NSURL * url = [NSURL URLWithString: _request.downloadURL];
        NSURLRequest *request = [NSURLRequest requestWithURL: url];
        _connection = [[NSURLConnection alloc] initWithRequest: request delegate: self startImmediately: NO];
        
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        _port = [NSMachPort port];
        [runLoop addPort: _port forMode: NSDefaultRunLoopMode];
        [_connection scheduleInRunLoop: runLoop forMode: NSDefaultRunLoopMode];
        [_connection start];
        [runLoop run];
    }
}

-(void)cancel
{
    [super cancel];
    
    [_connection unscheduleFromRunLoop: [NSRunLoop currentRunLoop] forMode: NSDefaultRunLoopMode];
    [_connection cancel];
    _request.thumbView.operation = nil; //break retain loop
    [[NSRunLoop currentRunLoop] removePort: _port forMode: NSDefaultRunLoopMode];
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    _downloadedData = [NSMutableData new];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_downloadedData appendData: data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (_connection == connection) {
        NSFileManager *fileManager = [NSFileManager new];
        NSString *pathForDownloadedThumb = [[ThumbCache sharedCache] thumbPathOnRequest: _request];
        NSString *pathForContainigDirectory = [pathForDownloadedThumb stringByDeletingLastPathComponent];
        if (! [fileManager fileExistsAtPath: pathForContainigDirectory]) {
            //create a directory if required
            [fileManager createDirectoryAtPath: pathForContainigDirectory withIntermediateDirectories: YES attributes: nil error: nil];
        }
        
        if (! self.isCancelled) {
            [_downloadedData writeToFile: pathForDownloadedThumb atomically: YES];
            UIImage *image = [UIImage imageWithContentsOfFile: pathForDownloadedThumb];

            //an image may be empty
            if (image) {
                if (! self.isCancelled) {
                    [[ThumbCache sharedCache] setThumbImage: image forKey: _request.cacheKey];

                    if (_request.targetTag == _request.thumbView.tag) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            _request.thumbView.thumb = image;
                        });
                    }
                }
            }
            _request.thumbView.operation = nil; //break retain loop
            [[NSRunLoop currentRunLoop] removePort: _port forMode: NSDefaultRunLoopMode];
        }
    }
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (error.code != NSURLErrorCancelled) {
        #ifdef DEBUG
        NSLog(@"failed downloading thumb for url: %@ with error %@", _request.downloadURL, error.localizedDescription);
        #endif
        
        _request.thumbView.operation = nil;
        [[NSRunLoop currentRunLoop] removePort: _port forMode: NSDefaultRunLoopMode];
    }
}

@end
