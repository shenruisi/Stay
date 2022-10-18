//
//  QuickAccess.h
//  Stay-Mac
//
//  Created by ris on 2022/6/22.
//

#import <Foundation/Foundation.h>
#import "MainTabBarController.h"
#import "SYHomeViewController.h"
#import "SYNavigationController.h"

NS_ASSUME_NONNULL_BEGIN

@interface QuickAccess : NSObject

+ (nullable UISplitViewController *)splitController;
+ (nullable MainTabBarController *)primaryController;
+ (nullable SYNavigationController *)secondaryController;
+ (nullable SYHomeViewController *)homeViewController;
+ (nullable UIViewController *)rootController;
@end

NS_ASSUME_NONNULL_END
