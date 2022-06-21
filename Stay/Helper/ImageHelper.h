//
//  ImageHelper.h
//  FastClip-iOS
//
//  Created by ris on 2022/3/15.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface ImageHelper : NSObject
+ (UIImage *)sfNamed:(NSString *)name font:(UIFont *)font;
+ (UIImage *)sfNamed:(NSString *)name font:(UIFont *)font color:(UIColor *)color;
+ (NSData *)dataNamed:(NSString *)name;
@end

NS_ASSUME_NONNULL_END
