//
//  EasyList.h
//  Stay
//
//  Created by ris on 2023/3/27.
//

#import <Foundation/Foundation.h>
#import "EasyListRule.h"
NS_ASSUME_NONNULL_BEGIN

@interface EasyList : NSObject

- (NSArray<EasyListRule *> *)parse:(NSString *)rules;
@end

NS_ASSUME_NONNULL_END
