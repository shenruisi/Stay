//
//  InputMenu.m
//  Stay
//
//  Created by ris on 2023/4/26.
//

#import "InputMenu.h"
#import "ModalNavigationController.h"
#import "InputToolbar.h"

@interface InputMenu()

@property (nonatomic, strong) ModalNavigationController *navController;
@end

@implementation InputMenu

- (ModalNavigationController *)modalNavigationController{
    return self.navController;
}


- (ModalNavigationController *)navController{
    if (nil == _navController){
        InputToolbar *cer = [[InputToolbar alloc] init];
        _navController = [[ModalNavigationController alloc] initWithRootModalViewController:cer
                                                                            slideController:self
                                                                                     radius:0
                                                                                 boderWidth:0
                                                                                contentMode:ModalContentModeLeft
                                                                              noShadowRound:YES
                                                                                 cornerMask:0];
    }
    
    return _navController;
}

- (BOOL)blockAction{
    return NO;
}

- (CGFloat)keyboardMargin{
    return 0;
}

@end
