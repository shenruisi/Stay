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

NSNotificationName const _Nonnull FCSlideControllerDidDismissNotification = @"app.notification.FCSlideControllerDidDismissNotification";

@interface FCSlideController()<
 CAAnimationDelegate,
 FCBlockViewDelegate
>{
    
}


@property (nonatomic, assign) BOOL selfDismiss;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeGestureRecognizer;
@end

@implementation FCSlideController

- (instancetype)init{
    if (self = [super init]){
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

- (void)show{
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
    
    UIWindow *keyWindow = FCApp.keyWindow;
    CGSize windowSize = keyWindow.frame.size;
    if ([self blockAction]){
        [[self blockView] setFrame:CGRectMake(0, 0, keyWindow.frame.size.width, keyWindow.frame.size.height)];
        [keyWindow addSubview:self.blockView];
    }
    
    self.navView = [self modalNavigationController].view;
    
    CGFloat navViewHeight = MIN([self maxHeight],self.navView.frame.size.height);
    
    
    if ([self from] == FCPresentingFromBottom){
        [self.navView setFrame:CGRectMake((windowSize.width - self.navView.frame.size.width)/2,
                                          windowSize.height + navViewHeight,
                                          self.navView.frame.size.width,
                                          navViewHeight)];
    }
    else if ([self from] == FCPresentingFromTop){
        [self.navView setFrame:CGRectMake((windowSize.width - self.navView.frame.size.width)/2,
                                          -navViewHeight,
                                          self.navView.frame.size.width,
                                          navViewHeight)];
    }
    [[self modalNavigationController].rootModalViewController willSee];
    [[self modalNavigationController].rootModalViewController viewWillAppear];
    
    [keyWindow addSubview:self.navView];
    
    
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        if ([self from] == FCPresentingFromBottom){
            CGRect frame = self.navView.frame;
            frame.origin.y -= (frame.size.height * 2 + [self marginToFrom]);
            self.navView.frame = frame;
        }
        else if ([self from] == FCPresentingFromTop){
            CGRect frame = self.navView.frame;
            frame.origin.y = [self marginToFrom];
            self.navView.frame = frame;
        }
        
    } completion:^(BOOL finished) {
        [keyWindow bringSubviewToFront:self.navView];
    }];
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
    if ([note.name isEqualToString:UIKeyboardWillChangeFrameNotification] && !self.selfDismiss){
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
    else if ([note.name isEqualToString:UIKeyboardDidChangeFrameNotification] && self.selfDismiss){
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

- (void)dealloc{
    
}

@end
