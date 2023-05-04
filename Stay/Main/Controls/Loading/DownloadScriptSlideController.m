//
//  DownloadScriptSlideController.m
//  Stay
//
//  Created by zly on 2023/4/25.
//

#import "DownloadScriptSlideController.h"
#import "DownloadScriptModelViewController.h"

@interface DownloadScriptSlideController()

@property (nonatomic, strong) ModalNavigationController *navController;
@end

@implementation DownloadScriptSlideController
- (ModalNavigationController *)navController{
    if (nil == _navController){
        DownloadScriptModelViewController *cer = [[DownloadScriptModelViewController alloc] init];
        cer.hideNavigationBar = YES;
        cer.originMainText = self.originMainText;
        cer.iconUrl= self.iconUrl;
        _navController = [[ModalNavigationController alloc] initWithRootModalViewController:cer radius:15];
        _navController.slideController = self;
    }
    
    return _navController;
}

- (ModalNavigationController *)modalNavigationController{
    return self.navController;
}


- (void)updateMainText:(NSString *)text{
//    LoadingStatusModalViewController *cer = (LoadingStatusModalViewController *)self.navController.rootModalViewController;
//    [cer updateMainText:text];
}

- (void)updateSubText:(NSString *)text{
//    LoadingStatusModalViewController *cer = (LoadingStatusModalViewController *)self.navController.rootModalViewController;
//    [cer updateSubText:text];
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

- (BOOL)dismissable{
    return NO;
}
@end
