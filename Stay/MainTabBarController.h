//
//  MainTabBarController.h
//  Stay
//
//  Created by zly on 2021/11/9.
//

#import <UIKit/UIKit.h>
#import "UserScript.h"
#import "SYHomeViewController.h"
NS_ASSUME_NONNULL_BEGIN

@class SYDetailViewController;
@interface MainTabBarController : UITabBarController

@property (nonatomic, weak) SYHomeViewController *homeViewController;
@end

NS_ASSUME_NONNULL_END
