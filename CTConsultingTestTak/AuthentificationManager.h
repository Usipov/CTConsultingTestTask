//
//  AuthentificationManager.h
//  CTConsultingTestTask
//
//  Created by Тимур Юсипов on 17.04.14.
//  Copyright (c) 2014 Timur. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const AuthentificationStateDidChangeNotification;

@interface AuthentificationManager : NSObject

+(instancetype)sharedManager;

@property (nonatomic, retain) NSString *userToken;

@end
