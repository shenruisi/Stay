//
//  UINSApplicationDelegate.h
//  FastClip-iOS
//
//  Created by ris on 2022/3/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol UINSApplicationDelegate <NSObject>

- (void)didReceiveRemoteNotification:(NSDictionary<NSString *,id> *)userInfo;
- (void)shouldHandleReopenHasVisibleWindows:(BOOL)flag;
- (void)continueUserActivity:(NSUserActivity *)userActivity;
- (void)willEnterFullScreen;
- (void)willExitFullScreen;
@end

NS_ASSUME_NONNULL_END
