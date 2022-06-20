//
//  MainTabBarController.h
//  Stay
//
//  Created by zly on 2021/11/9.
//

#import <UIKit/UIKit.h>
#import "UserScript.h"
NS_ASSUME_NONNULL_BEGIN

@class SYDetailViewController;
@interface MainTabBarController : UITabBarController

- (nonnull SYDetailViewController *)produceDetailViewControllerWithUserScript:(UserScript *)userScript;
@end

NS_ASSUME_NONNULL_END
