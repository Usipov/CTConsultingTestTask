//
//  NSObject+TextSizesComputer.m
//  CTConsultingTestTask
//
//  Created by Ultimatum on 17.04.14.
//  Copyright (c) 2014 Timur. All rights reserved.
//

#import "NSObject+TextSizesComputer.h"

@implementation NSObject (TextSizesComputer)

+(CGSize)computeSizeOfText: (NSString *)text withFont: (UIFont *)font linebreakMode: (NSLineBreakMode)lineBreakMode constrainedToSize: (CGSize)size
{
    NSParameterAssert(font);
    
    CGSize res;
    if ([UIDevice currentDevice].systemVersion.floatValue >= 7.0f) {
        NSDictionary *attributesDictionary = @{NSFontAttributeName : font};
        res = [text boundingRectWithSize: size
                                 options: NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                              attributes: attributesDictionary
                                 context: nil].size;
    } else {
        res = [text sizeWithFont: font
               constrainedToSize: size
                   lineBreakMode: lineBreakMode];
    }
    
    return res;
}

@end
