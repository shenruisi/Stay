//
//  SYTextInputViewController.m
//  Stay
//
//  Created by zly on 2022/7/6.
//

#import "SYTextInputViewController.h"
#import "SYTextInputModelViewController.h"

@interface SYTextInputViewController ()
@property (nonatomic, strong) ModalNavigationController *navController;

@end

@implementation SYTextInputViewController

- (ModalNavigationController *)navController {
    if (nil == _navController){
        SYTextInputModelViewController *cer = [[SYTextInputModelViewController alloc] init];
        cer.hideNavigationBar = NO;
        cer.navigationBar.showCancel = YES;
        cer.notificationName = self.notificationName;
        _navController = [[ModalNavigationController alloc] initWithRootModalViewController:cer radius:15];
        _navController.slideController = self;
    }
    
    return _navController;
}


- (ModalNavigationController *)modalNavigationController{
    return self.navController;
}


- (void)updateNotificationName:(NSString *)text{
    SYTextInputModelViewController *cer = (SYTextInputModelViewController *)self.navController.rootModalViewController;
    [cer updateNotificationName:text];
}

- (BOOL)blockAction{
    return YES;
}

- (BOOL)dismissable{
    return YES;
}

- (FCPresentingFrom)from{
    return FCPresentingFromBottom;
}

- (CGFloat)marginToFrom{
    return 18;
}

@end
