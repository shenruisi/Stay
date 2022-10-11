//
//  SYNavigationController.h
//  Stay
//
//  Created by ris on 2022/10/9.
//

#import <UIKit/UIKit.h>
#import "SYDetailViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface SYNavigationController : UINavigationController

- (void)popViewController;
- (void)pushViewController:(UIViewController *)viewController;
- (nonnull SYDetailViewController *)produceDetailViewControllerWithUserScript:(UserScript *)userScript;
@end

NS_ASSUME_NONNULL_END
