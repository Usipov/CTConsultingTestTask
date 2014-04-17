//
//  AppDelegate.m
//  CTConsultingTestTak
//
//  Created by Ultimatum on 16.04.14.
//  Copyright (c) 2014 Timur. All rights reserved.
//

#import "AppDelegate.h"
#import "AuthentificationManager.h"
#import "AuthentificationViewController.h"
#import "FeedViewController.h"

#define kObservedKeyPath @"userToken"

@interface AppDelegate ()
-(UIViewController *)viewControllerBasedOnAuthentificationState;
-(void)handleAuthentificationStateChange: (NSNotification *)sender;
@end

#pragma mark -

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];

    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController: [self viewControllerBasedOnAuthentificationState]];
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(handleAuthentificationStateChange:) name: AuthentificationStateDidChangeNotification object: nil];
    
    return YES;
}

-(UIViewController *)viewControllerBasedOnAuthentificationState
{
    UIViewController *vc = nil;
    
    if (AuthentificationManager.sharedManager.userToken.length) {
        vc = [[FeedViewController alloc] initWithStyle: UITableViewStylePlain];
    } else {
        AuthentificationViewController *viewController = [AuthentificationViewController new];
        if (AuthentificationManager.sharedManager.userToken) {
            [viewController signOut];
        }
        vc = viewController;
    }
    return vc;
}

-(void)handleAuthentificationStateChange: (NSNotification *)sender
{
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController: [self viewControllerBasedOnAuthentificationState]];
}

#pragma mark -

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[NSNotificationCenter defaultCenter] postNotificationName: kApplicationWillTerminateNotification object: nil userInfo: nil];
}

@end
