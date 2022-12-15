//
//  SYProgress.h
//  Stay
//
//  Created by zly on 2022/12/10.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SYProgress : UIView
@property (nonatomic ,assign) CGFloat progress;

- (instancetype)initWithFrame:(CGRect)frame BgViewBgColor:(UIColor *)bgViewBgColor BgViewBorderColor:(UIColor *)bgViewBorderColor ProgressViewColor:(UIColor *)progressViewColor;

@end

NS_ASSUME_NONNULL_END
