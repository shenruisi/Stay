//
//  UpgradeSlideController.m
//  Stay
//
//  Created by ris on 2023/4/14.
//

#import "UpgradeSlideController.h"
#import "UpgradeModalViewController.h"

@interface UpgradeSlideController()

@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) ModalNavigationController *navController;
@end

@implementation UpgradeSlideController

- (instancetype)initWithMessage:(NSString *)message{
    if (self = [super init]){
        self.message = message;
    }

    return self;
}

- (ModalNavigationController *)navController{
    if (nil == _navController){
        UpgradeModalViewController *cer = [[UpgradeModalViewController alloc] init];
        cer.message = self.message;
        _navController = [[ModalNavigationController alloc] initWithRootModalViewController:cer slideController:self];
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
