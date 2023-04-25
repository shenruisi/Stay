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
- (void)writeJSONToFileName:(NSString *)fileName content:(NSString *)content error:(NSError **)error;
- (void)appendJSONToFileName:(NSString *)fileName dictionary:(NSDictionary *)dictionary error:(NSError **)error;
- (void)appendTextToFileName:(NSString *)fileName content:(NSString *)content error:(NSError **)error;
- (NSURL *)ruleJSONURLOfFileName:(NSString *)fileName;
- (BOOL)existRuleJSON:(NSString *)fileName;
@end

NS_ASSUME_NONNULL_END
