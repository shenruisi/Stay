//
//  SYHomeViewController.h
//  Stay
//
//  Created by zly on 2021/11/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

extern NSNotificationName const _Nonnull HomeViewShouldReloadDataNotification;

@class UserScript;
@interface SYHomeViewController : UIViewController

- (void)import;
- (NSArray<UserScript *> *)userscripts;
@end

NS_ASSUME_NONNULL_END
