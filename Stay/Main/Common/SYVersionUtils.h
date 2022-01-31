//
//  SYVersionUtils.h
//  Stay
//
//  Created by zly on 2022/1/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SYVersionUtils : NSObject

+ (NSInteger)compareVersion:(NSString *)version1 toVersion:(NSString *)version2;

@end

NS_ASSUME_NONNULL_END
