//
//  AddSubscribeSlideController.m
//  Stay
//
//  Created by ris on 2023/6/1.
//

#import "AddSubscribeSlideController.h"
#import "AddSubscribeModalViewController.h"

@interface AddSubscribeSlideController()

@property (nonatomic, strong) ModalNavigationController *navController;
@end

@implementation AddSubscribeSlideController


- (ModalNavigationController *)navController{
    if (nil == _navController){
        AddSubscribeModalViewController *cer = [[AddSubscribeModalViewController alloc] init];
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
