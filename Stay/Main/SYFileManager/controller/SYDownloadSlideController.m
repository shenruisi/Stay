//
//  SYDownloadSlideController.m
//  Stay
//
//  Created by ris on 2022/12/16.
//

#import "SYDownloadSlideController.h"
#import "SYDownloadModalViewController.h"

@interface SYDownloadSlideController()

@property (nonatomic, strong) ModalNavigationController *navController;
@end

@implementation SYDownloadSlideController

- (ModalNavigationController *)modalNavigationController{
    return self.navController;
}

- (CGFloat)marginToFrom{
    return 30;
}

- (ModalNavigationController *)navController{
    if (nil == _navController){
        SYDownloadModalViewController *cer = [[SYDownloadModalViewController alloc] init];
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
