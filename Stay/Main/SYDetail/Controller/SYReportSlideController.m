//
//  SYReportSlideController.m
//  Stay
//
//  Created by zly on 2023/2/8.
//

#import "SYReportSlideController.h"
#import "SYReportModalViewController.h"

@interface SYReportSlideController()

@property (nonatomic, strong) ModalNavigationController *navController;
@end
@implementation SYReportSlideController

- (ModalNavigationController *)modalNavigationController{
    return self.navController;
}

- (CGFloat)marginToFrom{
    return 30;
}

- (ModalNavigationController *)navController{
    if (nil == _navController){
        SYReportModalViewController *cer = [[SYReportModalViewController alloc] init];
        cer.script = self.script;
        _navController = [[ModalNavigationController alloc] initWithRootModalViewController:cer slideController:self];
        
    }
    
    return _navController;
}

- (BOOL)blockAction{
    return YES;
}

@end
