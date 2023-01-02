//
//  SYChangeDocSlideController.m
//  Stay
//
//  Created by zly on 2023/1/2.
//

#import "SYChangeDocSlideController.h"
#import "SYChangeDocModelViewController.h"
@interface SYChangeDocSlideController()

@property (nonatomic, strong) ModalNavigationController *navController;
@end

@implementation SYChangeDocSlideController
- (ModalNavigationController *)modalNavigationController{
    return self.navController;
}

- (CGFloat)marginToFrom{
    return 30;
}

- (ModalNavigationController *)navController{
    if (nil == _navController){
        SYChangeDocModelViewController *cer = [[SYChangeDocModelViewController alloc] init];
        cer.dic = self.dic;
        cer.nav = self.controller;
        _navController = [[ModalNavigationController alloc] initWithRootModalViewController:cer slideController:self];
    }
    
    return _navController;
}

- (BOOL)blockAction{
    return YES;
}

@end
