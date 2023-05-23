//
//  FCTabBarController.h
//  Stay
//
//  Created by ris on 2023/3/14.
//

#import <UIKit/UIKit.h>
#import "FCTabBarItem.h"
#import "FCTabBar.h"
NS_ASSUME_NONNULL_BEGIN

extern NSNotificationName const _Nonnull FCUITabBarControllerShouldHideTabBar;
extern NSNotificationName const _Nonnull FCUITabBarControllerShouldShowTabBar;

@interface FCTabBarController : UITabBarController

@property(nullable, nonatomic,copy) NSArray<FCTabBarItem *> *tabBarItems;
@property (nonatomic, strong) FCTabBar *fcTabBar;
@end

NS_ASSUME_NONNULL_END
