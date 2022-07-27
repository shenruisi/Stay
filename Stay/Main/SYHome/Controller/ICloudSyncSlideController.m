//
//  ICloudSyncSlideController.m
//  Stay
//
//  Created by ris on 2022/7/25.
//

#import "ICloudSyncSlideController.h"
#import "ICloudSwitchViewController.h"

@interface ICloudSyncSlideController()

@property (nonatomic, strong) ModalNavigationController *navController;
@end

@implementation ICloudSyncSlideController

- (ModalNavigationController *)navController{
    if (nil == _navController){
        ICloudSwitchViewController *cer = [[ICloudSwitchViewController alloc] init];
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
