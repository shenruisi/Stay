//
//  ColorHelper.h
//  FastClip-iOS
//
//  Created by ris on 2022/3/13.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface ColorHelper : NSObject

+ (UIColor *)colorFromHex:(NSString *)hexString;
@end

NS_ASSUME_NONNULL_END
