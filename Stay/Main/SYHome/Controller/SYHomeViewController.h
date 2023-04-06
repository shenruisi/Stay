//
//  SYHomeViewController.h
//  Stay
//
//  Created by zly on 2021/11/9.
//

#import <UIKit/UIKit.h>
#import "FCRootViewController.h"


NS_ASSUME_NONNULL_BEGIN

extern NSNotificationName const _Nonnull HomeViewShouldReloadDataNotification;

@class UserScript;
@interface SYHomeViewController : FCRootViewController

- (void)import;
- (NSArray<UserScript *> *)userscripts;
- (void)iCloudSyncIfNeeded;
@end

NS_ASSUME_NONNULL_END
