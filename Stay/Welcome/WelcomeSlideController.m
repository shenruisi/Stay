//
//  WelcomeSlideController.m
//  Stay
//
//  Created by ris on 2023/5/1.
//

#import "WelcomeSlideController.h"
#import "WelcomeModalViewController.h"
#import "DeviceHelper.h"
#import "FCApp.h"

@interface WelcomeSlideController()

@property (nonatomic, strong) ModalNavigationController *navController;
@end

@implementation WelcomeSlideController


- (ModalNavigationController *)navController{
    if (nil == _navController){
        WelcomeModalViewController *cer = [[WelcomeModalViewController alloc] init];
        if (FCDeviceTypeIPad == [DeviceHelper type] || FCDeviceTypeMac == [DeviceHelper type]){
            _navController = [[ModalNavigationController alloc] initWithRootModalViewController:cer
                                                                                slideController:self
                                                                                         radius:10
                                                                                     boderWidth:1
                                                                                    contentMode:ModalContentModeLeft
                                                                                  noShadowRound:NO
                                                                                     cornerMask:kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner | kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner];
        }
        else{
            _navController = [[ModalNavigationController alloc] initWithRootModalViewController:cer
                                                                                slideController:self
                                                                                         radius:0
                                                                                     boderWidth:0
                                                                                    contentMode:ModalContentModeLeft
                                                                                  noShadowRound:YES
                                                                                     cornerMask:0];
        }
        
        _navController.view.containerView.backgroundColor = [UIColor clearColor];
    }

    return _navController;
}

- (ModalNavigationController *)modalNavigationController{
    return self.navController;
}

- (FCPresentingFrom)from{
    return FCPresentingFromFixedOrigin;
}


- (BOOL)blockAction{
    return YES;
}

- (void)touched{}

- (CGFloat)offsetX{
    if (FCDeviceTypeIPad == [DeviceHelper type] || FCDeviceTypeMac == [DeviceHelper type]){
        return (FCApp.keyWindow.size.width - 500)/2;
    }
    else{
        return 0;
    }
}

- (CGFloat)offsetY{
    if (FCDeviceTypeIPad == [DeviceHelper type] || FCDeviceTypeMac == [DeviceHelper type]){
        return (FCApp.keyWindow.size.height - 700)/2;
    }
    else{
        return 0;
    }
}

@end
