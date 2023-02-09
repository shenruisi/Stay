//
//  SYSubmitScriptSlideController.m
//  Stay
//
//  Created by zly on 2023/2/7.
//

#import "SYSubmitScriptSlideController.h"
#import "SYSubmitScriptViewController.h"

@interface SYSubmitScriptSlideController()

@property (nonatomic, strong) ModalNavigationController *navController;
@end
@implementation SYSubmitScriptSlideController
- (ModalNavigationController *)modalNavigationController{
    return self.navController;
}

- (CGFloat)marginToFrom{
    return 30;
}

- (ModalNavigationController *)navController{
    if (nil == _navController){
        SYSubmitScriptViewController *cer = [[SYSubmitScriptViewController alloc] init];
        cer.script = self.script;
        cer.nav = self.controller;
        _navController = [[ModalNavigationController alloc] initWithRootModalViewController:cer slideController:self];
        
    }
    
    return _navController;
}

- (BOOL)blockAction{
    return YES;
}
@end
