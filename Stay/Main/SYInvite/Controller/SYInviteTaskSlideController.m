//
//  SYInviteTaskSlideController.m
//  Stay
//
//  Created by zly on 2023/6/13.
//

#import "SYInviteTaskSlideController.h"
#import "SYInviteTaskController.h"
@interface SYInviteTaskSlideController()
@property (nonatomic, strong) ModalNavigationController *navController;

@end
@implementation SYInviteTaskSlideController
- (ModalNavigationController *)navController{
    if (nil == _navController){
        SYInviteTaskController *cer = [[SYInviteTaskController alloc] init];
        cer.nav = self.nav;
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
    return 20;
}

- (BOOL)blockAction{
    return YES;
}
@end
