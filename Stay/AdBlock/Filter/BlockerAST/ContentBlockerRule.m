//
//  ContentBlockerRule.m
//  Stay
//
//  Created by ris on 2023/4/20.
//

#import "ContentBlockerRule.h"

@implementation ContentBlockerTrigger

- (void)appendUrlFilter:(NSString *)str{
    NSString *existUrlFilter = self.urlFilter;
    self.urlFilter = [NSString stringWithFormat:@"%@%@",existUrlFilter ? existUrlFilter : @"",str];
}

- (BOOL)isEqual:(id)object{
    ContentBlockerTrigger *other = (ContentBlockerTrigger *)object;
    if (self == other) return YES;
    
    if (![self.urlFilter isEqualToString:other.urlFilter]) return NO;
    
    if (self.urlFilterIsCaseSensitive != other.urlFilterIsCaseSensitive) return NO;
    
    if (self.ifDomain.count != other.ifDomain.count) return NO;
    [self.ifDomain sortUsingSelector:@selector(compare:)];
    [other.ifDomain sortUsingSelector:@selector(compare:)];
    if (![self.ifDomain isEqualToArray:other.ifDomain]) return NO;
    
    if (self.unlessDomain.count != other.unlessDomain.count) return NO;
    [self.unlessDomain sortUsingSelector:@selector(compare:)];
    [other.unlessDomain sortUsingSelector:@selector(compare:)];
    if (![self.unlessDomain isEqualToArray:other.unlessDomain]) return NO;
    
    if (self.resourceType.count != other.resourceType.count) return NO;
    [self.resourceType sortUsingSelector:@selector(compare:)];
    [other.resourceType sortUsingSelector:@selector(compare:)];
    if (![self.resourceType isEqualToArray:other.resourceType]) return NO;
    
    if (self.loadType.count != other.loadType.count) return NO;
    [self.loadType sortUsingSelector:@selector(compare:)];
    [other.loadType sortUsingSelector:@selector(compare:)];
    if (![self.loadType isEqualToArray:other.loadType]) return NO;
    
    if (self.ifTopUrl.count != other.ifTopUrl.count) return NO;
    [self.ifTopUrl sortUsingSelector:@selector(compare:)];
    [other.ifTopUrl sortUsingSelector:@selector(compare:)];
    if (![self.ifTopUrl isEqualToArray:other.ifTopUrl]) return NO;
    
    if (self.unlessTopUrl.count != other.unlessTopUrl.count) return NO;
    [self.unlessTopUrl sortUsingSelector:@selector(compare:)];
    [other.unlessTopUrl sortUsingSelector:@selector(compare:)];
    if (![self.unlessTopUrl isEqualToArray:other.unlessTopUrl]) return NO;
    
    if (self.loadContext.count != other.loadContext.count) return NO;
    [self.loadContext sortUsingSelector:@selector(compare:)];
    [other.loadContext sortUsingSelector:@selector(compare:)];
    if (![self.loadContext isEqualToArray:other.loadContext]) return NO;
    
    return YES;
}

- (NSMutableArray *)ifDomain{
    if (nil == _ifDomain){
        _ifDomain = [[NSMutableArray alloc] init];
    }
    
    return _ifDomain;
}

- (NSMutableArray *)unlessDomain{
    if (nil == _unlessDomain){
        _unlessDomain = [[NSMutableArray alloc] init];
    }
    
    return _unlessDomain;
}

- (NSMutableArray *)resourceType{
    if (nil == _resourceType){
        _resourceType = [[NSMutableArray alloc] init];
    }
    
    return _resourceType;
}

- (NSMutableArray *)loadType{
    if (nil == _loadType){
        _loadType = [[NSMutableArray alloc] init];
    }
    
    return _loadType;
}

- (NSMutableArray *)ifTopUrl{
    if (nil == _ifTopUrl){
        _ifTopUrl = [[NSMutableArray alloc] init];
    }
    
    return _ifTopUrl;
}

- (NSMutableArray *)unlessTopUrl{
    if (nil == _unlessTopUrl){
        _unlessTopUrl = [[NSMutableArray alloc] init];
    }
    
    return _unlessTopUrl;
}

- (NSMutableArray *)loadContext{
    if (nil == _loadContext){
        _loadContext = [[NSMutableArray alloc] init];
    }
    
    return _loadContext;
}

- (NSDictionary *)toDictionary{
    NSMutableDictionary *ret = [[NSMutableDictionary alloc] init];
    [ret setObject:self.urlFilter forKey:@"url-filter"];
    if (self.ifDomain.count > 0){
        [ret setObject:self.ifDomain forKey:@"if-domain"];
    }
    
    if (self.unlessDomain.count > 0){
        [ret setObject:self.unlessDomain forKey:@"unless-domain"];
    }
    
    if (self.resourceType.count > 0){
        [ret setObject:self.resourceType forKey:@"resource-type"];
    }
    
    if (self.loadType.count > 0){
        [ret setObject:self.loadType forKey:@"load-type"];
    }
    
    if (self.ifTopUrl.count > 0){
        [ret setObject:self.ifTopUrl forKey:@"if-top-url"];
    }
    
    if (self.unlessTopUrl.count > 0){
        [ret setObject:self.unlessTopUrl forKey:@"unless-top-url"];
    }
    
    if (self.loadContext.count > 0){
        [ret setObject:self.loadContext forKey:@"load_context"];
    }
    
    return ret;
}

@end

@implementation ContentBlockerAction

- (NSString *)type{
    if (nil == _type){
        _type = @"block";
    }
    
    return _type;
}

- (NSString *)selector{
    if (nil == _selector){
        _selector = @"";
    }
    
    return _selector;
}

- (BOOL)isEqual:(id)object{
    ContentBlockerAction *other = (ContentBlockerAction *)object;
    if (self == other) return YES;
    return [self.type isEqualToString:other.type] && [self.selector isEqualToString:other.selector];
}

- (NSDictionary *)toDictionary{
    NSMutableDictionary *ret = [[NSMutableDictionary alloc] init];
    [ret setObject:self.type forKey:@"type"];
    if (self.selector.length > 0){
        [ret setObject:self.selector forKey:@"selector"];
    }
    return ret;
}

@end

@implementation ContentBlockerRule

- (instancetype)init{
    if (self = [super init]){
        self.trigger = [[ContentBlockerTrigger alloc] init];
        self.action = [[ContentBlockerAction alloc] init];
    }
    
    return self;
}

- (NSDictionary *)toDictionary{
    return @{
        @"trigger":[self.trigger toDictionary],
        @"action":[self.action toDictionary]
    };
}

- (BOOL)isEqual:(id)object{
    ContentBlockerRule *other = (ContentBlockerRule *)object;
    if (self == other) return YES;
    return [self.trigger isEqual:other.trigger] && [self.action isEqual:other.action];
}

- (BOOL)mergeRule:(ContentBlockerRule *)other{
    if (![self.action isEqual:other.action]) return NO;
    
    //Try to Merge
    BOOL mergeDomain = !((self.trigger.ifDomain.count > 0 &&  other.trigger.unlessDomain.count > 0) || (self.trigger.unlessDomain.count > 0 && other.trigger.ifDomain.count > 0));
    
    if (!mergeDomain) return NO;
    
    if (self.trigger.ifDomain.count > 0 || other.trigger.ifDomain.count > 0){
        [self.trigger.resourceType sortUsingSelector:@selector(compare:)];
        [other.trigger.resourceType sortUsingSelector:@selector(compare:)];
        if (![self.trigger.resourceType isEqualToArray:other.trigger.resourceType]) return NO;
    }
    
    if (self.trigger.unlessDomain.count > 0 || other.trigger.unlessDomain.count > 0){
        [self.trigger.resourceType sortUsingSelector:@selector(compare:)];
        [other.trigger.resourceType sortUsingSelector:@selector(compare:)];
        if (![self.trigger.resourceType isEqualToArray:other.trigger.resourceType]) return NO;
    }
    
    self.trigger.urlFilterIsCaseSensitive = self.trigger.urlFilterIsCaseSensitive || other.trigger.urlFilterIsCaseSensitive;
    
    [self.trigger.ifDomain addObjectsFromArray:other.trigger.ifDomain];
    [self.trigger.unlessDomain addObjectsFromArray:other.trigger.unlessDomain];
    
    if (0 == self.trigger.resourceType.count || 0 == other.trigger.resourceType.count){
        [self.trigger.resourceType removeAllObjects];
    }
    else{
        for (NSString *resourceType in other.trigger.resourceType){
            if (![self.trigger.resourceType containsObject:resourceType]){
                [self.trigger.resourceType addObject:resourceType];
            }
        }
    }
    
    if (0 == self.trigger.loadType.count || 0 == other.trigger.loadType.count){
        [self.trigger.loadType removeAllObjects];
    }
    else{
        for (NSString *loadType in other.trigger.loadType){
            if (![self.trigger.loadType containsObject:loadType]){
                [self.trigger.loadType addObject:loadType];
            }
        }
    }
    
    return YES;
    
}

@end
