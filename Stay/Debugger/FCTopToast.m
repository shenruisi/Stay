//
//  FCTopToast.m
//  Stay
//
//  Created by ris on 2022/11/25.
//
#import "FCTopToast.h"

#import "FCTopToastModalViewController.h"

@interface FCTopToast()

@property (nonatomic, assign) BOOL permanent;
@property (nonatomic, strong) ModalNavigationController *topToastNavController;
@end

@implementation FCTopToast

- (instancetype)initWithPermanent:(BOOL)permanent{
    if (self = [super init]){
        self.permanent = permanent;
    }
    
    return self;
}

- (void)showWithIcon:(UIImage *)icon mainTitle:(NSString *)mainTitle secondaryTitle:(NSString *)secondaryTitle{    
    FCTopToastModalViewController *cer = (FCTopToastModalViewController *)self.topToastNavController.rootModalViewController;
    cer.icon = icon;
    cer.mainTitle = mainTitle;
    cer.secondaryTitle = secondaryTitle;
    
    if (!self.permanent){
        [super show];
        [NSTimer scheduledTimerWithTimeInterval:2 repeats:NO block:^(NSTimer * _Nonnull timer) {
            [self dismiss];
            [timer invalidate];
        }];
    }
    else{
        if (!self.isShown){
            [super show];
        }
        else{
            [cer reload];
        }
    }
}

- (FCPresentingFrom)from{
    return FCPresentingFromTop;
}

- (ModalNavigationController *)modalNavigationController{
    return self.topToastNavController;
}

- (CGFloat)marginToFrom{
    return self.parentView.safeAreaInsets.top;
}

- (ModalNavigationController *)topToastNavController{
    if (nil == _topToastNavController){
        FCTopToastModalViewController *cer = [[FCTopToastModalViewController alloc] init];
        cer.hideNavigationBar = YES;
        _topToastNavController = [[ModalNavigationController alloc] initWithRootModalViewController:cer radius:25];
        _topToastNavController.slideController = self;
    }
    
    return _topToastNavController;
}

- (BOOL)blockAction{
    return NO;
}

- (BOOL)preventShortcuts{
    return NO;
}

@end
