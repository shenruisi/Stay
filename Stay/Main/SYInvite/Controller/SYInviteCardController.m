//
//  SYInviteCardController.m
//  Stay
//
//  Created by zly on 2023/6/1.
//

#import "SYInviteCardController.h"
#import "SYInviteCardModelController.h"
@interface SYInviteCardController()
@property (nonatomic, strong) ModalNavigationController *navController;

@end
@implementation SYInviteCardController
- (ModalNavigationController *)navController{
    if (nil == _navController){
        SYInviteCardModelController *cer = [[SYInviteCardModelController alloc] init];
        cer.imageList = self.imageList;
        cer.color = self.color;
        cer.defaultImage = self.defaultImage;
        cer.defaultName = self.defaultName;
        cer.detail = self.detail;
        _navController = [[ModalNavigationController alloc] initWithRootModalViewController:cer radius:15];
        _navController.slideController = self;
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
    return 20;
}

- (BOOL)blockAction{
    return YES;
}

- (void)setImageList:(NSArray *)imageList {
    _imageList = imageList;
    
}

@end
