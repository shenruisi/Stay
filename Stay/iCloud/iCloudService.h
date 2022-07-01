//
//  iCloudService.h
//  Stay
//
//  Created by ris on 2022/6/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSNotificationName const _Nonnull iCloudServiceUserscriptSavedNotification;

@class UserScript;
@interface iCloudService : NSObject

- (BOOL)logged;
- (NSString *)serviceIdentifier;
- (void)checkFirstInit:(void (^)(BOOL firstInit, NSError *error))completionHandler;
//- (BOOL)firstInit:(NSError * __strong *)outError;
- (void)pushUserscripts:(NSArray<UserScript *> *)userscripts
      completionHandler:(void (^)(NSError *error))completionHandler;
- (void)pullUserscriptWithCompletionHandler:(void (^)(NSArray<UserScript *> * userscripts, NSError * error))completionHandler;
- (void)removeUserscript:(UserScript *)userscript;
- (void)addUserscript:(UserScript *)userscript;
- (dispatch_queue_t)queue;
@end

NS_ASSUME_NONNULL_END
