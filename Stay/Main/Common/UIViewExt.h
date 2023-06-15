/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

//设备的物理高度
//#define kScreenHeight MAX([UIScreen mainScreen].bounds.size.height,[UIScreen mainScreen].bounds.size.width)
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

//设备的物理宽度
//#define kScreenWidth MIN([UIScreen mainScreen].bounds.size.height,[UIScreen mainScreen].bounds.size.width)
#define kScreenWidth [UIScreen mainScreen].bounds.size.width


#define RGBA(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:a]

#define RGB(r,g,b)  [UIColor colorWithRed:(r)/255.f green:(g)/255.f blue:(b)/255.f alpha:1.f]

#define UIColorFromRGB(hexString) \
({ \
    unsigned int hexValue = 0; \
    NSScanner *scanner = [NSScanner scannerWithString:hexString]; \
    [scanner setScanLocation:1]; \
    [scanner scanHexInt:&hexValue]; \
    UIColor *color = [UIColor colorWithRed:((CGFloat)((hexValue & 0xFF0000) >> 16)) / 255.0 \
                                     green:((CGFloat)((hexValue & 0xFF00) >> 8)) / 255.0 \
                                      blue:((CGFloat)(hexValue & 0xFF)) / 255.0 \
                                     alpha:1.0]; \
    color; \
})
CGPoint CGRectGetCenter(CGRect rect);
CGRect  CGRectMoveToCenter(CGRect rect, CGPoint center);

@interface UIView (ViewFrameGeometry)
@property CGPoint origin;
@property CGSize size;

@property (readonly) CGPoint bottomLeft;
@property (readonly) CGPoint bottomRight;
@property (readonly) CGPoint topRight;

@property CGFloat height;
@property CGFloat width;

@property CGFloat top;
@property CGFloat left;

@property CGFloat bottom;
@property CGFloat right;

@property CGFloat centerX;
@property CGFloat centerY;

- (void) moveBy: (CGPoint) delta;
- (void) scaleBy: (CGFloat) scaleFactor;
- (void) fitInSize: (CGSize) aSize;

//- (void)rotateWithDuration:(double)duration;
//- (void)stopRotating;
@end
