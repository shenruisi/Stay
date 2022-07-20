//
//  iCloudService.h
//  Stay
//
//  Created by ris on 2022/6/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSNotificationName const _Nonnull iCloudServiceUserscriptSavedNotification;

@class UserScript,BaseRecord;
@interface iCloudService : NSObject

- (void)checkFirstInit:(void (^)(BOOL firstInit, NSError *error))completionHandler;
//- (BOOL)firstInit:(NSError * __strong *)outError;
- (void)pushUserscripts:(NSArray<UserScript *> *)userscripts
      serviceIdentifier:(NSString *)serviceIdentifier
      completionHandler:(void (^)(NSError *error))completionHandler;
- (void)pullUserscriptWithCompletionHandler:(void (^)(NSArray<UserScript *> * userscripts, NSError * error))completionHandler;
- (void)removeUserscript:(UserScript *)userscript;
- (void)addUserscript:(UserScript *)userscript;
- (void)addUserscript:(UserScript *)userscript completionHandler:(void(^)(NSError *error))completionHandler;
- (void)fetchUserscriptWithCompletionHandler:
(void (^)(NSDictionary<NSString *, UserScript *> *changedUserscripts,NSArray<NSString *> *deletedUUIDs))completionHandler;
- (dispatch_queue_t)queue;
- (void)refresh;

@property (nonatomic, assign, readonly) BOOL isLogin;
@property (nonatomic, strong, readonly) NSString *identifier;
@end

NS_ASSUME_NONNULL_END
