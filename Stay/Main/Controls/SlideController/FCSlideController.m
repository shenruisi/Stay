//
//  FCSlideController.m
//  FastClip-iOS
//
//  Created by ris on 2022/2/7.
//

#import "FCSlideController.h"

#import "FCApp.h"
#import "ModalViewController.h"
#import "ModalNavigationController.h"
#import "FCStyle.h"
#import "UIColor+Convert.h"

NSNotificationName const _Nonnull FCSlideControllerDidDismissNotification = @"app.notification.FCSlideControllerDidDismissNotification";

@interface FCSlideController()<
 CAAnimationDelegate,
 FCBlockViewDelegate
>{
    
}

@property (nonatomic, strong) CAShapeLayer *loadingShapeLayer;
@property (nonatomic, assign) BOOL selfDismiss;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeGestureRecognizer;
@end

@implementation FCSlideController

- (instancetype)init{
    if (self = [super init]){
        self.relayoutByKeyboard = YES;
        [self swipeGestureRecognizer];
    }
    
    return self;
}

- (UISwipeGestureRecognizer *)swipeGestureRecognizer{
    if (nil == _swipeGestureRecognizer){
        _swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self.navView action:@selector(swipeDown)];
        _swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
        
    }
    
    return _swipeGestureRecognizer;
}

- (void)swipeDown{
    if ([self dismissable]){
        [self dismiss];
    }
}

- (void)showWithAnimation:(BOOL)animation{
    self.selfDismiss = NO;
    if ([self preventShortcuts]){}
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(adjustForKeyboard:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(adjustForKeyboard:)
                                                 name:UIKeyboardDidChangeFrameNotification
                                               object:nil];
    UIView *parentView = [self parentView];
    
    CGSize parentViewSize = parentView.frame.size;
    if ([self blockAction]){
        [[self blockView] setFrame:CGRectMake(0, 0, parentView.frame.size.width, parentView.frame.size.height)];
        [parentView addSubview:self.blockView];
    }
    
    self.navView = [self modalNavigationController].view;
    
    [[self modalNavigationController].rootModalViewController willSee];
    
    CGFloat navViewHeight = MIN([self maxHeight],self.navView.frame.size.height);
    
    
    if ([self from] == FCPresentingFromBottom){
        [self.navView setFrame:CGRectMake([self offsetX] + (parentViewSize.width - [self offsetX] - self.navView.frame.size.width)/2,
                                          parentViewSize.height + navViewHeight,
                                          self.navView.frame.size.width,
                                          navViewHeight)];
        self.navView.alpha = 0;
    }
    else if ([self from] == FCPresentingFromTop){
        [self.navView setFrame:CGRectMake([self offsetX] + (parentViewSize.width - [self offsetX] - self.navView.frame.size.width)/2,
                                          -navViewHeight,
                                          self.navView.frame.size.width,
                                          navViewHeight)];
        self.navView.alpha = 0;
    }
    else if ([self from] == FCPresentingFromFixedOrigin){
        [self.navView setFrame:CGRectMake([self offsetX],[self offsetY],self.navView.frame.size.width,navViewHeight)];
    }
    
    
    [parentView addSubview:self.navView];
    
    [[self modalNavigationController].rootModalViewController viewWillAppear];
    
    if ([self from] == FCPresentingFromFixedOrigin){
        [parentView bringSubviewToFront:self.navView];
        [[self modalNavigationController].rootModalViewController viewDidAppear];
    }
    else{
        if (animation){
            [UIView animateWithDuration:0.3
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                self.navView.alpha = 1.0;
                if ([self from] == FCPresentingFromBottom){
                    CGRect frame = self.navView.frame;
                    frame.origin.y = parentViewSize.height - frame.size.height - [self marginToFrom];
                    self.navView.frame = frame;
                }
                else if ([self from] == FCPresentingFromTop){
                    CGRect frame = self.navView.frame;
                    frame.origin.y = [self marginToFrom];
                    self.navView.frame = frame;
                }
                
            } completion:^(BOOL finished) {
                [parentView bringSubviewToFront:self.navView];
                [[self modalNavigationController].rootModalViewController viewDidAppear];
               
                
            }];
        }
        else{
            self.navView.alpha = 1.0;
            if ([self from] == FCPresentingFromBottom){
                CGRect frame = self.navView.frame;
                frame.origin.y = parentViewSize.height -frame.size.height - [self marginToFrom] - self.keyboardSize.height;
                self.navView.frame = frame;
            }
            else if ([self from] == FCPresentingFromTop){
                CGRect frame = self.navView.frame;
                frame.origin.y = [self marginToFrom];
                self.navView.frame = frame;
            }
            [parentView bringSubviewToFront:self.navView];
            [[self modalNavigationController].rootModalViewController viewDidAppear];
        }
    }
}

- (void)show{
    [self showWithAnimation:YES];
}

- (void)layoutSubviews{
    UIWindow *keyWindow = FCApp.keyWindow;
    CGSize windowSize = keyWindow.frame.size;
    [[self blockView] setFrame:CGRectMake(0, 0, windowSize.width, windowSize.height)];
    
    CGFloat y = 0;
    if ([self from] == FCPresentingFromBottom){
        y = windowSize.height - self.navView.frame.size.height - [self marginToFrom];
    }
    else if ([self from] == FCPresentingFromTop){
        y = [self marginToFrom];
    }
    
    [self.navView setFrame:CGRectMake((windowSize.width - self.navView.frame.size.width)/2,  y, self.navView.frame.size.width, self.navView.frame.size.height)];
}

- (ModalNavigationController *)modalNavigationController{
    return nil;
}

- (BOOL)blockAction{
    return YES;
}

- (FCPresentingFrom)from{
    return FCPresentingFromBottom;
}

- (CGFloat)marginToFrom{
    return 0;
}

- (CGFloat)keyboardMargin{
    return 10;
}



- (void)dismiss {
    self.selfDismiss = YES;
    if ([self preventShortcuts]){}
    [FCApp.keyWindow endEditing:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
    UIWindow *keyWindow = FCApp.keyWindow;
    CGSize windowSize = keyWindow.frame.size;
    if ([self blockAction]){
        [[self blockView] removeFromSuperview];
    }
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        if ([self from] == FCPresentingFromBottom){
            [self.navView setFrame:CGRectMake(self.navView.frame.origin.x, windowSize.height + self.navView.frame.size.height, self.navView.frame.size.width, self.navView.frame.size.height)];
        }
        else if ([self from] == FCPresentingFromTop){
            [self.navView setFrame:CGRectMake(self.navView.frame.origin.x,  -self.navView.frame.size.height, self.navView.frame.size.width, self.navView.frame.size.height)];
        }
        
    } completion:^(BOOL finished) {
        [self.navView removeFromSuperview];
        [[self modalNavigationController] popToRootControllerWithDismiss];
        [[NSNotificationCenter defaultCenter] postNotificationName:FCSlideControllerDidDismissNotification
                                                            object:self];
    }];
    
}


- (BOOL)isShown {
    return self.navView && CGRectIntersectsRect(FCApp.keyWindow.frame, self.navView.frame);
}


- (void)showWithParams:(nonnull NSArray *)params {
    
}


- (FCBlockView *)blockView{
    if (nil == _blockView){
        _blockView = [[FCBlockView alloc] init];
        NSLog(@"create block %@,%@",_blockView,self);
        _blockView.delegate = self;
    }
    
    return _blockView;
}

- (void)touched{
    if ([self dismissable]){
        [self dismiss];
    }
}

- (void)adjustForKeyboard:(NSNotification *)note{
    NSDictionary *info = [note userInfo];
    CGRect endRect  = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
//    NSLog(@"endRect %@, %@, %@",NSStringFromCGRect(endRect),NSStringFromCGRect([[info objectForKey:UIKeyboardBoundsUserInfoKey] CGRectValue]),[FCApp.keyWindow convertRect:endRect fromWindow:nil]);
    if ([note.name isEqualToString:UIKeyboardWillChangeFrameNotification] && !self.selfDismiss){
        self.keyboardSize = endRect.size;
        if (self.relayoutByKeyboard){
            CGFloat newOriginY =  endRect.origin.y -  [self keyboardMargin] - self.navView.frame.size.height;
            BOOL dismissKeyboardFirst = endRect.origin.y >= FCApp.keyWindow.frame.size.height;
            if (dismissKeyboardFirst){
                newOriginY =  FCApp.keyWindow.frame.size.height - self.navView.frame.size.height - [self marginToFrom];
            }
            
            [UIView animateWithDuration:0.3
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                if ([self from] == FCPresentingFromBottom){
                    self.navView.frame = CGRectMake(self.navView.frame.origin.x, newOriginY, self.navView.frame.size.width, self.navView.frame.size.height);
                }
                
            } completion:^(BOOL finished) {
            }];
        }
    }
    else if ([note.name isEqualToString:UIKeyboardDidChangeFrameNotification] && self.selfDismiss){
        self.keyboardSize = endRect.size;
        if (self.relayoutByKeyboard){
            CGFloat newOriginY =  endRect.origin.y -  [self marginToFrom] - self.navView.frame.size.height;
            [UIView animateWithDuration:0.3
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                if ([self from] == FCPresentingFromBottom){
                    self.navView.frame = CGRectMake(self.navView.frame.origin.x, newOriginY, self.navView.frame.size.width, self.navView.frame.size.height);
                }
                
            } completion:^(BOOL finished) {
            }];
        }
    }
}

- (void)startLoading{
    if (self.loadingShapeLayer){
        [self.loadingShapeLayer removeFromSuperlayer];
    }
    
    self.loadingShapeLayer = [self createLoadingShapeLayer];
    [self.navView.containerView.layer addSublayer:self.loadingShapeLayer];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];
    animation.duration = 2.0;
    animation.toValue = (__bridge id _Nullable)([self createLoadingPath:10].CGPath);
    animation.autoreverses = YES;
    animation.repeatCount = HUGE_VALF;
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.duration = 2.0;
    opacityAnimation.fromValue = @(0); // 初始透明度
    opacityAnimation.toValue = @(1); // 目标透明度
    opacityAnimation.autoreverses = YES;
    opacityAnimation.repeatCount = HUGE_VALF;
    
    [self.loadingShapeLayer addAnimation:animation forKey:@"pathAnimation"];
//    [self.loadingShapeLayer addAnimation:opacityAnimation forKey:@"opacityAnimation"];
}

- (void)stopLoading{
    [self.loadingShapeLayer removeAllAnimations];
    [self.loadingShapeLayer removeFromSuperlayer];
    self.loadingShapeLayer = nil;
}

- (UIBezierPath *)createLoadingPath:(CGFloat)height{
    CGRect bounds = CGRectMake(0, 0, self.navView.size.width, height);
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, bounds.size.height / 2)];
    [path addQuadCurveToPoint:CGPointMake(bounds.size.width, bounds.size.height / 2) controlPoint:CGPointMake(bounds.size.width / 2,  bounds.size.height)];
    [path addLineToPoint:CGPointMake(bounds.size.width, 0)];
    [path addLineToPoint:CGPointMake(0, 0)];
    [path closePath];
    return path;
}

- (CAShapeLayer *)createLoadingShapeLayer{
    CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
    NSArray<UIColor *> *colors = FCStyle.accentGradient;
    shapeLayer.fillColor = [[FCStyle.accent colorWithAlphaComponent:0.1] rgba2rgb:FCStyle.popup].CGColor;
    //colors[1].CGColor;
//    shapeLayer.strokeColor = [UIColor blueColor].CGColor;
//    shapeLayer.lineWidth = 2.0;
//    shapeLayer.mask = gradientLayer;
    
    shapeLayer.path = [self createLoadingPath:0].CGPath;
    
    return shapeLayer;
}

- (BOOL)disableRoundShadow{
    return NO;
}

- (BOOL)preventShortcuts{
    return YES;
}

- (BOOL)dismissable{
    return YES;
}

- (CGFloat)maxHeight{
    return CGFLOAT_MAX;
}

- (UIView *)parentView{
    if (self.specificParentView){
        return self.specificParentView;
    }
    else{
        return FCApp.keyWindow;
    }
}

- (CGFloat)offsetX{
    return 0;
}

- (CGFloat)offsetY{
    return 0;
}

- (void)dealloc{
    
}

@end
