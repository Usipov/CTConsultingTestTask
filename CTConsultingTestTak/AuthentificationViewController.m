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
}

-(void)startAuthentificating;

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
    
    [self.view addSubview: _webView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    
        [self startAuthentificating];
}

#pragma mark - extenstions

-(void)startAuthentificating
{
    if (! _isAuthentificating) {
        _isAuthentificating = YES;
        
        NSString *urlBase = [NSString stringWithFormat: @"https://instagram.com/oauth/authorize/?client_id=%@&redirect_uri=%@&response_type=token", kClientID, kRedirectURI];
        NSURL *url = [NSURL URLWithString: urlBase];
        NSURLRequest *request = [NSURLRequest requestWithURL: url];
        [_webView loadRequest: request];
    }
}

#pragma mark - UIWebViewDelegate

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    
    
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    
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
