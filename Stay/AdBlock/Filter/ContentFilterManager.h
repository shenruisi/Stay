//
//  ContentFilterManager.h
//  Stay
//
//  Created by ris on 2023/4/4.
//

#import <Foundation/Foundation.h>
#import "TrustedSite.h"

NS_ASSUME_NONNULL_BEGIN

@interface ContentFilterManager : NSObject

+ (instancetype)shared;
//- (void)writeJSONToFileName:(NSString *)fileName content:(NSString *)content error:(NSError **)error;
- (void)appendJSONToFileName:(NSString *)fileName dictionary:(NSDictionary *)dictionary error:(NSError **)error;
- (void)appendJSONToFileName:(NSString *)fileName array:(NSMutableArray *)array error:(NSError **)error;
- (void)appendJSONToFileName:(NSString *)fileName trustedSite:(NSString *)trustedSite error:(NSError **)error;
- (void)removeJSONToFileName:(NSString *)fileName trustedSite:(NSString *)trustedSite error:(NSError **)error;
- (void)writeTextToFileName:(NSString *)fileName content:(NSString *)content error:(NSError **)error;
- (void)appendTextToFileName:(NSString *)fileName content:(NSString *)content error:(NSError **)error;
- (NSURL *)ruleJSONURLOfFileName:(NSString *)fileName;
- (BOOL)existRuleJSON:(NSString *)fileName;
- (NSArray *)ruleJSONArray:(NSString *)fileName error:(NSError **)error;
- (void)writeJSONToFileName:(NSString *)fileName array:(NSArray *)array error:(NSError **)error;
- (void)writeJSONToFileName:(NSString *)fileName data:(NSData *)data error:(NSError **)error;
- (NSArray<TrustedSite *> *)trustedSites;
- (void)addTrustSiteWithDomain:(NSString *)domain error:(NSError **)error;
- (BOOL)existTrustSiteWithDomain:(NSString *)domain;
- (void)deleteTrustSiteWithDomain:(NSString *)domain;
- (BOOL)ruleJSONStopped:(NSString *)fileName;
- (void)updateRuleJSON:(NSString *)fileName status:(NSUInteger)status;
- (NSString *)ruleText:(NSString *)fileName error:(NSError **)error;
@end

NS_ASSUME_NONNULL_END
