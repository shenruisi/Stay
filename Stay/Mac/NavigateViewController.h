//
//  NavigateViewController.h
//  FastClip-iOS
//
//  Created by ris on 2022/3/17.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@interface NavigateViewController : UIViewController

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController;
- (void)pushViewController:(UIViewController *)viewController;
- (void)pushViewController:(UIViewController *)viewController removeUUID:(nullable NSString *)tabUUID;
- (void)removeViewControllerWithUUID:(NSString *)tabUUID;
- (void)popViewController;
// Call - pushViewController inside.
- (void)forward;
@property (nonatomic, readonly) UIViewController *topViewController;

@end

NS_ASSUME_NONNULL_END
