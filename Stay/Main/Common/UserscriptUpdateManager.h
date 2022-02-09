//
//  UserscriptUpdateManager.h
//  Stay
//
//  Created by zly on 2022/2/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UserscriptUpdateManager : NSObject
+ (instancetype)shareManager;

- (void)updateResouse;

@end

NS_ASSUME_NONNULL_END
