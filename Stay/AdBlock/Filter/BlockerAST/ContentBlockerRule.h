//
//  ContentBlockerRule.h
//  Stay
//
//  Created by ris on 2023/4/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ContentBlockerTrigger : NSObject

@property (nonatomic, strong) NSString *urlFilter;
@property (nonatomic, assign) BOOL urlFilterIsCaseSensitive;
@property (nonatomic, strong) NSMutableSet *ifDomain;
@property (nonatomic, strong) NSMutableSet *unlessDomain;
@property (nonatomic, strong) NSMutableSet *resourceType;
@property (nonatomic, strong) NSMutableSet *loadType;
@property (nonatomic, strong) NSMutableSet *ifTopUrl;
@property (nonatomic, strong) NSMutableSet *unlessTopUrl;
@property (nonatomic, strong) NSMutableSet *loadContext;

- (void)appendUrlFilter:(NSString *)str;
- (NSDictionary *)toDictionary;
@end

@interface ContentBlockerAction : NSObject

@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *selector;

- (NSDictionary *)toDictionary;
@end

@interface ContentBlockerRule : NSObject

@property (nonatomic, strong) ContentBlockerTrigger *trigger;
@property (nonatomic, strong) ContentBlockerAction *action;
@property (nonatomic, strong) NSMutableDictionary *specialComment;

- (BOOL)mergeRule:(ContentBlockerRule *)other;
- (NSDictionary *)toDictionary;
@end

NS_ASSUME_NONNULL_END
