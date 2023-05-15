//
//  AddTruestedSiteSlideController.m
//  Stay
//
//  Created by ris on 2023/5/15.
//

#import "AddTruestedSiteSlideController.h"
#import "AddTruestedSiteModalViewController.h"

@interface AddTruestedSiteSlideController()

@property (nonatomic, strong) ModalNavigationController *navController;
@end

@implementation AddTruestedSiteSlideController


- (ModalNavigationController *)navController{
    if (nil == _navController){
        AddTruestedSiteModalViewController *cer = [[AddTruestedSiteModalViewController alloc] init];
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
