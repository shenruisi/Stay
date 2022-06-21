//
//  ImageHelper.m
//  FastClip-iOS
//
//  Created by ris on 2022/3/15.
//

#import "ImageHelper.h"

@implementation ImageHelper

+ (UIImage *)sfNamed:(NSString *)name font:(UIFont *)font{
   return [self sfNamed:name font:font color:nil];
}


+ (UIImage *)sfNamed:(NSString *)name font:(UIFont *)font color:(UIColor *)color{
   UIImage *image =  [UIImage systemImageNamed:name
                             withConfiguration:[UIImageSymbolConfiguration configurationWithFont:font]];
    if (color){
        image = [image imageWithTintColor:color renderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    return image;
}

+ (NSData *)dataNamed:(NSString *)name{
    UIImage *image = [UIImage imageNamed:name];
    return UIImagePNGRepresentation(image);
}

@end
