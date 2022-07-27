//
//  UIView+Rotate.m
//  Stay
//
//  Created by ris on 2022/7/20.
//

#import "UIView+Rotate.h"

static NSString * kRotationAnimationKey = @"rotationanimationkey";
@implementation UIView (Rotate)

- (void)rotateWithDuration:(double)duration{
    if (nil == [self.layer animationForKey:kRotationAnimationKey]){
        CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        rotationAnimation.fromValue = @(0.0f);
        rotationAnimation.toValue = @(M_PI * 2.0f);
        rotationAnimation.duration = duration;
        rotationAnimation.repeatCount = CGFLOAT_MAX;
        [self.layer addAnimation:rotationAnimation forKey:kRotationAnimationKey];
    }
}

- (void)stopRotating{
    if (nil != [self.layer animationForKey:kRotationAnimationKey]){
        [self.layer removeAnimationForKey:kRotationAnimationKey];
    }
}

@end
