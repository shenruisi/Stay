//
//  SYDownloadingCircleView.m
//  Stay
//
//  Created by zly on 2023/4/28.
//

#import "SYDownloadingCircleView.h"
#import "FCStyle.h"
@interface SYDownloadingCircleView()
@property (nonatomic,strong)CALayer *animationCircle;
@end
@implementation SYDownloadingCircleView


-(void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    CGPoint center = CGPointMake(self.width * 0.5, self.height * 0.5);
    
    UIBezierPath *backPath = [UIBezierPath bezierPathWithArcCenter:center radius:self.width * 0.25 startAngle:0 endAngle:2 * M_PI clockwise:YES];
    backPath.lineWidth = 1;
    [RGB(138, 138, 138) set];
    [backPath stroke];
    
    [self.layer addSublayer:self.animationCircle];
    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    pathAnimation.calculationMode = kCAAnimationPaced;
    pathAnimation.fillMode = kCAFillModeForwards;
    pathAnimation.removedOnCompletion = NO;
    pathAnimation.duration = 1.0;
    pathAnimation.repeatCount = 10000;
    pathAnimation.path = backPath.CGPath;
    [self.animationCircle addAnimation:pathAnimation forKey:nil];
    
}
- (CALayer *)animationCircle{
    if (!_animationCircle) {
        _animationCircle = [CALayer layer];
        _animationCircle.frame = CGRectMake(0, 0, 12, 12);
        _animationCircle.cornerRadius = 6;
        _animationCircle.backgroundColor = FCStyle.accentGradient[1].CGColor;
    }
    return _animationCircle;
}

@end
