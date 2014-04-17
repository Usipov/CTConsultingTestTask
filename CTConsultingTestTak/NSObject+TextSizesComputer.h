//
//  NSObject+TextSizesComputer.h
//  CTConsultingTestTask
//
//  Created by Ultimatum on 17.04.14.
//  Copyright (c) 2014 Timur. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (TextSizesComputer)

+(CGSize)computeSizeOfText: (NSString *)text withFont: (UIFont *)font linebreakMode: (NSLineBreakMode)lineBreakMode constrainedToSize: (CGSize)size;

@end
