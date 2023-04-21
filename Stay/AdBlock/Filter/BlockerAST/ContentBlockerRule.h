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
@property (nonatomic, strong) NSMutableArray *ifDomain;
@property (nonatomic, strong) NSMutableArray *unlessDomain;
@property (nonatomic, strong) NSMutableArray *resourceType;
@property (nonatomic, strong) NSMutableArray *loadType;
@property (nonatomic, strong) NSMutableArray *ifTopUrl;
@property (nonatomic, strong) NSMutableArray *unlessTopUrl;
@property (nonatomic, strong) NSMutableArray *loadContext;

- (void)appendUrlFilter:(NSString *)str;
@end

@interface ContentBlockerAction : NSObject

@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *selector;
@end

@interface ContentBlockerRule : NSObject

@property (nonatomic, strong) ContentBlockerTrigger *trigger;
@property (nonatomic, strong) ContentBlockerAction *action;
@property (nonatomic, strong) NSMutableDictionary *specialComment;

- (BOOL)mergeRule:(ContentBlockerRule *)other;
@end

NS_ASSUME_NONNULL_END
