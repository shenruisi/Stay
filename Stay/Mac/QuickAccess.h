//
//  QuickAccess.h
//  Stay-Mac
//
//  Created by ris on 2022/6/22.
//

#import <Foundation/Foundation.h>
#import "FCSplitViewController.h"
#import "NavigateCollectionController.h"
NS_ASSUME_NONNULL_BEGIN

@interface QuickAccess : NSObject

+ (nullable FCSplitViewController *)splitController;
+ (nullable UITabBarController *)primaryController;
+ (nullable NavigateCollectionController *)secondaryController;
@end

NS_ASSUME_NONNULL_END
