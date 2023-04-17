//
//  ContentFilterManager.h
//  Stay
//
//  Created by ris on 2023/4/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ContentFilterManager : NSObject

+ (instancetype)shared;
- (void)writeToFileName:(NSString *)fileName content:(NSString *)content;
- (NSString *)contentOfFileName:(NSString *)fileName;
- (NSURL *)contentURLOfFileName:(NSString *)fileName;
- (BOOL)existRuleJson:(NSString *)fileName;
@end

NS_ASSUME_NONNULL_END
