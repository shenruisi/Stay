//
//  CommitCodeSlideController.m
//  Stay
//
//  Created by ris on 2023/6/13.
//

#import "CommitCodeSlideController.h"
#import "CommitCodeModalViewController.h"

@interface CommitCodeSlideController()

@property (nonatomic, strong) ModalNavigationController *navController;
@property (nonatomic, strong) NSDictionary *dic;
@end

@implementation CommitCodeSlideController

- (ModalNavigationController *)navController{
    if (nil == _navController){
        CommitCodeModalViewController *cer = [[CommitCodeModalViewController alloc] init];
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
    return NO;
}

@end
