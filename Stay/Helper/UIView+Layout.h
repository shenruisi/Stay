//
//  UIView+Layout.h
//  FastClip-iOS
//
//  Created by ris on 2022/11/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView(Layout)

- (CGFloat)width;
- (void)setWidth:(CGFloat)width;
- (CGFloat)height;
- (void)setHeight:(CGFloat)height;
- (CGFloat)bottom;
- (CGFloat)right;
- (CGFloat)left;
- (CGFloat)top;

@end

NS_ASSUME_NONNULL_END
