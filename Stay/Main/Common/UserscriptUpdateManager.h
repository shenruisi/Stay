//
//  UserscriptUpdateManager.h
//  Stay
//
//  Created by zly on 2022/2/7.
//

#import <Foundation/Foundation.h>
#import "UserScript.h"

NS_ASSUME_NONNULL_BEGIN

@interface UserscriptUpdateManager : NSObject
+ (instancetype)shareManager;

- (void)updateResouse;

- (NSArray *)getUserScriptRequireListByUserScript:(UserScript *)scrpit;

- (BOOL)saveRequireUrl:(UserScript *)scrpit;

- (BOOL)saveResourceUrl:(UserScript *)scrpit;

- (void)saveIcon:(UserScript *)scrpit;

@end

NS_ASSUME_NONNULL_END
