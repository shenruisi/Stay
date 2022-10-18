//
//  ExtensionConfig.h
//  Stay
//
//  Created by ris on 2022/10/18.
//

#import <Foundation/Foundation.h>
#import "FCDisk.h"

NS_ASSUME_NONNULL_BEGIN

@interface ExtensionConfig : FCDisk<NSSecureCoding>

@property (nonatomic, assign) BOOL showBadge;
@end

NS_ASSUME_NONNULL_END
