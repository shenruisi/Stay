//
//  ImportSlideController.m
//  Stay
//
//  Created by ris on 2022/6/27.
//

#import "ImportSlideController.h"
#import "ImportMenuModalViewController.h"

@interface ImportSlideController()

@property (nonatomic, strong) ModalNavigationController *navController;
@end

@implementation ImportSlideController

- (ModalNavigationController *)navController{
    if (nil == _navController){
        ImportMenuModalViewController *cer = [[ImportMenuModalViewController alloc] init];
        cer.hideNavigationBar = YES;
        _navController = [[ModalNavigationController alloc] initWithRootModalViewController:cer radius:15];
        _navController.slideController = self;
    }
    
    return _navController;
}

- (ModalNavigationController *)modalNavigationController{
    return self.navController;
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


@end
