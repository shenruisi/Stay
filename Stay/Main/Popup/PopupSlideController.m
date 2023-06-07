//
//  PopupSlideController.m
//  Stay
//
//  Created by ris on 2023/5/31.
//

#import "PopupSlideController.h"
#import "PopupModalViewController.h"

@interface PopupSlideController()

@property (nonatomic, strong) ModalNavigationController *navController;
@property (nonatomic, strong) NSDictionary *dic;
@end

@implementation PopupSlideController

- (instancetype)initWithDic:(NSDictionary *)dic{
    if (self = [super init]){
        self.dic = dic;
    }

    return self;
}


- (ModalNavigationController *)navController{
    if (nil == _navController){
        PopupModalViewController *cer = [[PopupModalViewController alloc] init];
        cer.dic = self.dic;
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
