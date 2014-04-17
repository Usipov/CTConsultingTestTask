//
//  AuthentificationViewController.m
//  CTConsultingTestTask
//
//  Created by Тимур Юсипов on 17.04.14.
//  Copyright (c) 2014 Timur. All rights reserved.
//

#import "AuthentificationViewController.h"

@interface AuthentificationViewController () <UIWebViewDelegate> {
    UIWebView *_webView;
    BOOL _isAuthentificating;
    UIBarButtonItem *_refreshItem;
    BOOL _needToSignOutFirst;
}

-(void)startAuthentificating;
-(void)operate;

@end

@implementation AuthentificationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _webView = [[UIWebView alloc] initWithFrame: self.view.frame];
    _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _webView.delegate = self;
    
    self.navigationItem.title = NSLocalizedString(@"authentification", nil);
    _refreshItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemRefresh target: self action: @selector(operate)];
    
    [self.view addSubview: _webView];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    _webView.frame = self.view.frame;
    [self operate];
}

-(void)signOut
{
    _needToSignOutFirst = YES;
}

#pragma mark - extenstions

-(void)startAuthentificating
{
    if (! _isAuthentificating) {
        _isAuthentificating = YES;
        self.navigationItem.rightBarButtonItem = nil;
        
        NSString *urlBase = [NSString stringWithFormat: @"https://instagram.com/oauth/authorize/?client_id=%@&redirect_uri=%@&response_type=token", kClientID, kRedirectURI];
        NSURL *url = [NSURL URLWithString: urlBase];
        NSURLRequest *request = [NSURLRequest requestWithURL: url];
        [_webView loadRequest: request];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: YES];
    }
}


-(void)operate
{
    if (! _needToSignOutFirst) {
        //log in immediately
        [self startAuthentificating];
    } else {
        //sign out first and then sign in
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: YES];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            id data = [NSData dataWithContentsOfURL: [NSURL URLWithString: @"https://instagram.com/accounts/logout/"]];
            if (data) {
                _needToSignOutFirst = NO;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
                    [self startAuthentificating];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
                    self.navigationItem.rightBarButtonItem = _refreshItem;
                });
            }
            
        });
    }
}

#pragma mark - UIWebViewDelegate

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    _isAuthentificating = NO;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    _isAuthentificating = NO;
    self.navigationItem.rightBarButtonItem = _refreshItem;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];    
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    //catch an access token while redirecting during authentification process
    NSString *url = request.URL.absoluteString;
    NSScanner *scanner = [NSScanner scannerWithString: url];
    if ([scanner scanString: [NSString stringWithFormat: @"%@#access_token=", kRedirectURI] intoString: nil]) {
        NSString *accessToken = [url substringFromIndex: scanner.scanLocation];
        if (accessToken) {
            AuthentificationManager.sharedManager.userToken = accessToken;
            return NO;
        }
    }

    return YES;
}

@end
