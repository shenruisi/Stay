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
@property (nonatomic, strong) NSNumber *tagStatus;
@property (nonatomic, strong) NSString *backgroundColorType;
@end

NS_ASSUME_NONNULL_END
