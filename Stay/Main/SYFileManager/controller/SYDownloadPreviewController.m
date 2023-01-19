//
//  SYDownloadPreviewController.m
//  Stay
//
//  Created by zly on 2023/1/19.
//

#import "SYDownloadPreviewController.h"
#import "SYDownloadPreviewModalViewController.h"

@interface SYDownloadPreviewController()
@property (nonatomic, strong) ModalNavigationController *navController;

@end
@implementation SYDownloadPreviewController
- (ModalNavigationController *)modalNavigationController{
    return self.navController;
}

- (CGFloat)marginToFrom{
    return 30;
}

- (ModalNavigationController *)navController{
    if (nil == _navController){
        SYDownloadPreviewModalViewController *cer = [[SYDownloadPreviewModalViewController alloc] init];
        _navController = [[ModalNavigationController alloc] initWithRootModalViewController:cer slideController:self];
    }
    
    return _navController;
}

- (BOOL)blockAction{
    return YES;
}

- (BOOL)dismissable{
    return NO;
}

@end
