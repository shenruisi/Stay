//
//  WelcomeSlideController.m
//  Stay
//
//  Created by ris on 2023/5/1.
//

#import "WelcomeSlideController.h"
#import "WelcomeModalViewController.h"

@interface WelcomeSlideController()

@property (nonatomic, strong) ModalNavigationController *navController;
@end

@implementation WelcomeSlideController


- (ModalNavigationController *)navController{
    if (nil == _navController){
        WelcomeModalViewController *cer = [[WelcomeModalViewController alloc] init];
        _navController = [[ModalNavigationController alloc] initWithRootModalViewController:cer
                                                                            slideController:self
                                                                                     radius:0
                                                                                 boderWidth:0
                                                                                contentMode:ModalContentModeLeft
                                                                              noShadowRound:YES
                                                                                 cornerMask:0];
        _navController.view.containerView.backgroundColor = [UIColor clearColor];
    }

    return _navController;
}

- (ModalNavigationController *)modalNavigationController{
    return self.navController;
}

- (FCPresentingFrom)from{
    return FCPresentingFromFixedOrigin;
}


- (BOOL)blockAction{
    return NO;
}

@end
