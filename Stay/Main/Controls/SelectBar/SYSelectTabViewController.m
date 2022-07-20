//
//  SYSelectTabViewController.m
//  Stay
//
//  Created by zly on 2022/6/9.
//

#import "SYSelectTabViewController.h"
#import "SYSelectBarModalViewController.h"

@interface SYSelectTabViewController ()


@property (nonatomic, strong) ModalNavigationController *navController;

@end

@implementation SYSelectTabViewController

- (ModalNavigationController *)navController {
    if (nil == _navController){
        SYSelectBarModalViewController *cer = [[SYSelectBarModalViewController alloc] init];
        cer.hideNavigationBar = YES;
        cer.url = self.url;
        cer.content = self.content;
        cer.needDelete = self.needDelete;
        _navController = [[ModalNavigationController alloc] initWithRootModalViewController:cer radius:15];
        _navController.slideController = self;
    }
    
    return _navController;
}


- (ModalNavigationController *)modalNavigationController{
    return self.navController;
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
