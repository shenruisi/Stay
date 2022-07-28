//
//  UserDefaultsExRO.h
//  Stay
//
//  Created by ris on 2022/7/28.
//

#import <Foundation/Foundation.h>
#import "FCDisk.h"

NS_ASSUME_NONNULL_BEGIN

@interface UserDefaultsExRO : FCDisk<NSSecureCoding>

@property (nonatomic, assign) BOOL pro;
@end

NS_ASSUME_NONNULL_END
