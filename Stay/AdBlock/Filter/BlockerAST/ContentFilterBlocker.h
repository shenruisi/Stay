//
//  ContentFilterBlocker.h
//  Stay
//
//  Created by ris on 2023/4/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ContentFilterBlocker : NSObject

+ (NSMutableDictionary *)rule:(NSString *)rule isSpecialComment:(BOOL *)isSpecialComment;
@end

NS_ASSUME_NONNULL_END
