//
//  ActivateChanged.h
//  Stay
//
//  Created by ris on 2022/5/31.
//

#import "FCDisk.h"

NS_ASSUME_NONNULL_BEGIN

@interface ActivateChanged : FCDisk

@property (nonatomic, strong) NSDictionary<NSString *,NSNumber *> *content;
@end

NS_ASSUME_NONNULL_END
