//
//  ContentBlockerRule.h
//  Stay
//
//  Created by ris on 2023/4/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ContentBlockerTrigger : NSObject<NSCopying>

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

@interface ContentBlockerAction : NSObject<NSCopying>

@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *selector;
@property (nonatomic, strong) NSMutableSet *selectors;

- (NSDictionary *)toDictionary;
@end

@interface ContentBlockerRule : NSObject<NSCopying>

@property (nonatomic, strong) ContentBlockerTrigger *trigger;
@property (nonatomic, strong) ContentBlockerAction *action;
@property (nonatomic, strong) NSMutableDictionary *specialComment;
@property (nonatomic, strong) NSString *originRule;

- (BOOL)mergeRule:(ContentBlockerRule *)other;
- (NSDictionary *)toDictionary;
- (NSString *)key;
- (BOOL)canUrlFilterWildcard;
@end

NS_ASSUME_NONNULL_END