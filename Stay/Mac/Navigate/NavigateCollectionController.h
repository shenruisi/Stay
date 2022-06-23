//
//  NavigateCollectionController.h
//  FastClip-iOS
//
//  Created by ris on 2022/3/17.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

extern NSNotificationName const _Nonnull NCCDidShowViewControllerNotification;

@class NavigateViewController;
@interface NavigateCollectionController : UIViewController

- (instancetype)initWithRootViewController:(NavigateViewController *)rootViewController;
- (void)pushViewController:(NavigateViewController *)viewController;
- (void)pushViewController:(NavigateViewController *)viewController removeUUID:(nullable NSString *)tabUUID;
- (void)removeViewControllerWithUUID:(NSString *)tabUUID;
- (void)popViewController;
// Call - pushViewController inside.
- (void)forward;
@property (nonatomic, readonly) NavigateViewController *topViewController;

@end



NS_ASSUME_NONNULL_END
