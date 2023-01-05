//
//  UIColor+Convert.m
//  FastClip-iOS
//
//  Created by ris on 2022/12/6.
//

#import "UIColor+Convert.h"

@implementation UIColor(Convert)

- (UIColor *)rgba2rgb:(UIColor *)backgroundColor{
    CGFloat selfR,selfG,selfB,selfA;
    [self getRed:&selfR green:&selfG blue:&selfB alpha:&selfA];
    CGFloat bgR,bgG,bgB,bgA;
    [backgroundColor getRed:&bgR green:&bgG blue:&bgB alpha:&bgA];
    return [UIColor colorWithRed:(1-selfA) * bgR + selfA * selfR
                           green:(1-selfA) * bgG + selfA * selfG
                            blue:(1-selfA) * bgB + selfA * selfB
                           alpha:1.0];
}

@end
