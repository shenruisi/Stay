//
//  iCloudService.h
//  Stay
//
//  Created by ris on 2022/6/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSNotificationName const _Nonnull iCloudServiceUserscriptSavedNotification;
extern NSNotificationName const _Nonnull iCloudServiceSyncStartNotification;
extern NSNotificationName const _Nonnull iCloudServiceSyncEndNotification;

@class UserScript,BaseRecord;
@interface iCloudService : NSObject

- (void)refreshWithCompletionHandler:(void(^)(NSError *error))completionHandler;
- (void)loggedWithCompletionHandler:(void(^)(BOOL status,NSError *error))completionHandler;
- (void)serviceIdentifierWithCompletionHandler:(void(^)(NSString *identifier,NSError *error))completionHandler;
- (void)checkFirstInit:(void (^)(BOOL firstInit, NSError *error))completionHandler;
- (void)initUserscripts:(NSArray<UserScript *> *)userscripts
      completionHandler:(void (^)(NSError *error))completionHandler;
- (void)addUserscript:(UserScript *)userscript completionHandler:(void(^)(NSError *error))completionHandler;
- (void)removeUserscript:(NSString *)uuid completionHandler:(void(^)(NSError *error))completionHandler;
- (void)fetchUserscriptWithCompletionHandler:
(void (^)(NSDictionary<NSString *, UserScript *> *changedUserscripts,NSArray<NSString *> *deletedUUIDs))completionHandler;
- (dispatch_queue_t)queue;
- (void)refresh;
- (void)showError:(NSError *)error inCer:(UIViewController *)cer;
- (void)showErrorWithMessage:(NSString *)message inCer:(UIViewController *)cer;

- (void)clearToken;
- (void)clearFirstInit;

@property (nonatomic, assign, readonly) BOOL isLogin;
@property (nonatomic, strong, readonly) NSString *identifier;
@end

NS_ASSUME_NONNULL_END
