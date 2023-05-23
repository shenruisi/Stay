//
//  AddTrustedSiteSlideController.m
//  Stay
//
//  Created by ris on 2023/5/15.
//

#import "AddTrustedSiteSlideController.h"
#import "AddTrustedSiteModalViewController.h"

@interface AddTrustedSiteSlideController()

@property (nonatomic, strong) ModalNavigationController *navController;
@end

@implementation AddTrustedSiteSlideController


- (ModalNavigationController *)navController{
    if (nil == _navController){
        AddTrustedSiteModalViewController *cer = [[AddTrustedSiteModalViewController alloc] init];
        _navController = [[ModalNavigationController alloc] initWithRootModalViewController:cer slideController:self];
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
    return 30;
}

- (BOOL)blockAction{
    return YES;
}

@end
