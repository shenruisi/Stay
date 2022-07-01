//
//  iCloudService.h
//  Stay
//
//  Created by ris on 2022/6/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class UserScript;
@interface iCloudService : NSObject

- (BOOL)logged;
- (NSString *)serviceIdentifier;
- (void)checkFirstInit:(void (^)(BOOL firstInit, NSError *error))completionHandler;
//- (BOOL)firstInit:(NSError * __strong *)outError;
- (void)pushUserscripts:(NSArray<UserScript *> *)userscripts
              syncStart:(void(^)(void))syncStart
      completionHandler:(void (^)(NSError *error))completionHandler;
@end

NS_ASSUME_NONNULL_END
