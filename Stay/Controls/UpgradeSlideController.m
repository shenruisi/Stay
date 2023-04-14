//
//  UpgradeSlideController.m
//  Stay
//
//  Created by ris on 2023/4/14.
//

#import "UpgradeSlideController.h"

@implementation UpgradeSlideController

- (instancetype)initWithContentFilter:(ContentFilter *)contentFilter{
    if (self = [super init]){
        self.contentFilter = contentFilter;
    }
    
    return self;
}

- (ModalNavigationController *)navController{
    if (nil == _navController){
        ContentFilterEditModalViewController *cer = [[ContentFilterEditModalViewController alloc] init];
        cer.contentFilter = self.contentFilter;
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
