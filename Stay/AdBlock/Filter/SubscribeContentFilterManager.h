//
//  SubscribeContentFilterManager.h
//  Stay
//
//  Created by ris on 2023/6/2.
//

#import <Foundation/Foundation.h>
#import "ContentFilter2.h"

NS_ASSUME_NONNULL_BEGIN

@interface SubscribeContentFilterManager : NSObject

+ (instancetype)shared;

- (void)checkUpdatingIfNeeded:(ContentFilter *)targetSubscribeContentFilter
                        focus:(BOOL)focus
                   completion:(void(^)(NSError *error, BOOL updated))completion;

- (void)reload:(ContentFilter *)targetSubscribeContentFilter completion:(void(^)(NSError *error))completion;
@end

NS_ASSUME_NONNULL_END
