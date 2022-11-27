//
//  ColorHelper.m
//  FastClip-iOS
//
//  Created by ris on 2022/3/13.
//

#import "ColorHelper.h"

@implementation ColorHelper

+ (UIColor *)colorFromHex:(NSString *)hexString{
    NSUInteger hex = [self _intFromHexString:hexString];
    if (6 == hexString.length){
        return [UIColor colorWithRed:((hex >> 16) & 0xFF)/255.0
                               green:((hex >> 8) & 0xFF)/255.0
                                blue:(hex & 0xFF)/255.0
                               alpha:1.0];
    }
    else if (8 == hexString.length){
        return [UIColor colorWithRed:((hex >> 24) & 0xFF)/255.0
                               green:((hex >> 16) & 0xFF)/255.0
                                blue:((hex >> 8) & 0xFF)/255.0
                               alpha:(hex & 0xFF)/255.0];
    }
    
    return nil;
}

+ (NSUInteger)_intFromHexString:(NSString *)hexStr {
    unsigned int hexInt = 0;

    NSScanner *scanner = [NSScanner scannerWithString:hexStr];

    [scanner scanHexInt:&hexInt];

    return hexInt;
}


@end
