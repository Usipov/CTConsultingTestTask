//
//  AuthentificationManager.m
//  CTConsultingTestTask
//
//  Created by Тимур Юсипов on 17.04.14.
//  Copyright (c) 2014 Timur. All rights reserved.
//

#import "AuthentificationManager.h"

NSString *const AuthentificationTokenKey = @"AuthentificationTokenKey";
NSString *const AuthentificationStateDidChangeNotification = @"AuthentificationStateDidChangeNotification";

#pragma mark -

@implementation AuthentificationManager

+(instancetype)sharedManager
{
    static AuthentificationManager *st_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        st_manager = [self new];
    });
    return st_manager;
}

-(id)init
{
    self = [super init];
    if (self) {
        _userToken = [[NSUserDefaults standardUserDefaults] valueForKey: AuthentificationTokenKey];
    }
    return self;
}

-(void)setUserToken:(NSString *)userToken
{
    _userToken = userToken;
    
    [[NSUserDefaults standardUserDefaults] setObject: userToken forKey: AuthentificationTokenKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName: AuthentificationStateDidChangeNotification object: nil];
}


@end
