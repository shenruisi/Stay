//
//  LoadingSlideController.m
//  Stay
//
//  Created by ris on 2022/5/23.
//

#import "LoadingSlideController.h"
#import "LoadingStatusModalViewController.h"

@interface LoadingSlideController()

@property (nonatomic, strong) ModalNavigationController *navController;
@end

@implementation LoadingSlideController

- (ModalNavigationController *)navController{
    if (nil == _navController){
        LoadingStatusModalViewController *cer = [[LoadingStatusModalViewController alloc] init];
        cer.hideNavigationBar = YES;
        cer.originMainText = self.originMainText;
        cer.originSubText = self.originSubText;
        _navController = [[ModalNavigationController alloc] initWithRootModalViewController:cer radius:15];
        _navController.slideController = self;
    }
    
    return _navController;
}

- (ModalNavigationController *)modalNavigationController{
    return self.navController;
}


- (void)updateMainText:(NSString *)text{
    LoadingStatusModalViewController *cer = (LoadingStatusModalViewController *)self.navController.rootModalViewController;
    [cer updateMainText:text];
}

- (void)updateSubText:(NSString *)text{
    LoadingStatusModalViewController *cer = (LoadingStatusModalViewController *)self.navController.rootModalViewController;
    [cer updateSubText:text];
}

- (FCPresentingFrom)from{
    return FCPresentingFromBottom;
}

- (CGFloat)marginToFrom{
    return 80;
}

- (BOOL)blockAction{
    return YES;
}

- (BOOL)dismissable{
    return NO;
}


@end
