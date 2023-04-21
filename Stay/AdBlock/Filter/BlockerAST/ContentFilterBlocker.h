//
//  ContentFilterBlocker.h
//  Stay
//
//  Created by ris on 2023/4/7.
//

#import <Foundation/Foundation.h>
#import "ContentBlockerRule.h"

NS_ASSUME_NONNULL_BEGIN

@interface ContentFilterBlocker : NSObject

+ (ContentBlockerRule *)rule:(NSString *)rule isSpecialComment:(BOOL *)isSpecialComment;
+ (NSMutableDictionary *)dict;
@end

NS_ASSUME_NONNULL_END
