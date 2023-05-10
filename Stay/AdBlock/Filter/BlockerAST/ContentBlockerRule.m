//
//  ContentBlockerRule.m
//  Stay
//
//  Created by ris on 2023/4/20.
//

#import "ContentBlockerRule.h"

@implementation ContentBlockerTrigger

- (id)copyWithZone:(nullable NSZone *)zone{
    ContentBlockerTrigger *copied = [[[self class] allocWithZone:zone] init];
    copied.urlFilter = [self.urlFilter copy];
    copied.urlFilterIsCaseSensitive = self.urlFilterIsCaseSensitive;
    copied.ifDomain = [self.ifDomain copy];
    copied.unlessDomain = [self.unlessDomain copy];
    copied.resourceType = [self.resourceType copy];
    copied.loadType = [self.loadType copy];
    copied.ifTopUrl = [self.ifTopUrl copy];
    copied.unlessTopUrl = [self.unlessTopUrl copy];
    copied.loadContext = [self.loadContext copy];
    return copied;
}

- (void)appendUrlFilter:(NSString *)str{
    NSString *existUrlFilter = self.urlFilter;
    self.urlFilter = [NSString stringWithFormat:@"%@%@",existUrlFilter ? existUrlFilter : @"",str];
}

- (BOOL)isEqual:(id)object{
    ContentBlockerTrigger *other = (ContentBlockerTrigger *)object;
    if (self == other) return YES;
    
    if (![self.urlFilter isEqualToString:other.urlFilter]) return NO;
    
    if (self.urlFilterIsCaseSensitive != other.urlFilterIsCaseSensitive) return NO;
    
    if (![self.ifDomain isEqualToSet:other.ifDomain]) return NO;
    
    if (![self.unlessDomain isEqualToSet:other.unlessDomain]) return NO;
    
    if (![self.resourceType isEqualToSet:other.resourceType]) return NO;
    
    if (![self.loadType isEqualToSet:other.loadType]) return NO;
    
    if (![self.ifTopUrl isEqualToSet:other.ifTopUrl]) return NO;
    
    if (![self.unlessTopUrl isEqualToSet:other.unlessTopUrl]) return NO;
    
    if (![self.loadContext isEqualToSet:other.loadContext]) return NO;
    
    return YES;
}

- (NSMutableSet *)ifDomain{
    if (nil == _ifDomain){
        _ifDomain = [[NSMutableSet alloc] init];
    }
    
    return _ifDomain;
}

- (NSMutableSet *)unlessDomain{
    if (nil == _unlessDomain){
        _unlessDomain = [[NSMutableSet alloc] init];
    }
    
    return _unlessDomain;
}

- (NSMutableSet *)resourceType{
    if (nil == _resourceType){
        _resourceType = [[NSMutableSet alloc] init];
    }
    
    return _resourceType;
}

- (NSMutableSet *)loadType{
    if (nil == _loadType){
        _loadType = [[NSMutableSet alloc] init];
    }
    
    return _loadType;
}

- (NSMutableSet *)ifTopUrl{
    if (nil == _ifTopUrl){
        _ifTopUrl = [[NSMutableSet alloc] init];
    }
    
    return _ifTopUrl;
}

- (NSMutableSet *)unlessTopUrl{
    if (nil == _unlessTopUrl){
        _unlessTopUrl = [[NSMutableSet alloc] init];
    }
    
    return _unlessTopUrl;
}

- (NSMutableSet *)loadContext{
    if (nil == _loadContext){
        _loadContext = [[NSMutableSet alloc] init];
    }
    
    return _loadContext;
}

- (NSDictionary *)toDictionary{
    NSMutableDictionary *ret = [[NSMutableDictionary alloc] init];
    [ret setObject:self.urlFilter forKey:@"url-filter"];
    if (self.ifDomain.count > 0){
        [ret setObject:[self.ifDomain allObjects] forKey:@"if-domain"];
    }
    
    if (self.unlessDomain.count > 0){
        [ret setObject:[self.unlessDomain allObjects] forKey:@"unless-domain"];
    }
    
    if (self.resourceType.count > 0){
        [ret setObject:[self.resourceType allObjects] forKey:@"resource-type"];
    }
    
    if (self.loadType.count > 0){
        [ret setObject:[self.loadType allObjects] forKey:@"load-type"];
    }
    
    if (self.ifTopUrl.count > 0){
        [ret setObject:[self.ifTopUrl allObjects] forKey:@"if-top-url"];
    }
    
    if (self.unlessTopUrl.count > 0){
        [ret setObject:[self.unlessTopUrl allObjects] forKey:@"unless-top-url"];
    }
    
    if (self.loadContext.count > 0){
        [ret setObject:[self.loadContext allObjects] forKey:@"load-context"];
    }
    
    return ret;
}

@end

@implementation ContentBlockerAction

- (id)copyWithZone:(nullable NSZone *)zone{
    ContentBlockerAction *copied = [[[self class] allocWithZone:zone] init];
    copied.type = [self.type copy];
    copied.selector = [self.selector copy];
    return copied;
}

- (NSMutableSet *)selectors{
    if (nil == _selectors){
        _selectors = [[NSMutableSet alloc] init];
    }
    
    return _selectors;
}

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

- (id)copyWithZone:(nullable NSZone *)zone{
    ContentBlockerRule *copied = [[[self class] allocWithZone:zone] init];
    copied.trigger = [self.trigger copy];
    copied.action = [self.action copy];
    return copied;
}

- (instancetype)init{
    if (self = [super init]){
        self.trigger = [[ContentBlockerTrigger alloc] init];
        self.action = [[ContentBlockerAction alloc] init];
    }
    
    return self;
}

- (NSDictionary *)toDictionary{
    if (self.originRule){
        return @{
            @"trigger":[self.trigger toDictionary],
            @"action":[self.action toDictionary],
            @"origin_rule":self.originRule
        };
    }
    else{
        return @{
            @"trigger":[self.trigger toDictionary],
            @"action":[self.action toDictionary]
        };
    }
    
}

- (BOOL)isEqual:(id)object{
    ContentBlockerRule *other = (ContentBlockerRule *)object;
    if (self == other) return YES;
    return [self.trigger isEqual:other.trigger] && [self.action isEqual:other.action];
}

- (NSString *)key{
    return [NSString stringWithFormat:@"%@%@",self.trigger.urlFilter, self.action.selector.length > 0 ? @"[SEL]":@""];
}

- (BOOL)mergeRule:(ContentBlockerRule *)other{
    if (![self.action.type isEqualToString:other.action.type]) return NO;
    if (self.action.selector.length > 0 && other.action.selector.length > 0){
        [self.action.selectors addObject:other.action.selector];
//        self.action.selector = [NSString stringWithFormat:@"%@, %@",self.action.selector,other.action.selector];
    }
    
    //Try to Merge
    BOOL mergeDomain = !((self.trigger.ifDomain.count > 0 &&  other.trigger.unlessDomain.count > 0) || (self.trigger.unlessDomain.count > 0 && other.trigger.ifDomain.count > 0));
    
    if (!mergeDomain) return NO;
    
    if ([self.trigger.ifDomain isEqualToSet:other.trigger.ifDomain]
        && [self.trigger.unlessDomain isEqualToSet:other.trigger.unlessDomain]){
        if (self.trigger.resourceType.count > 0 && other.trigger.resourceType.count > 0){
            self.trigger.resourceType = [NSMutableSet setWithSet:[self.trigger.resourceType setByAddingObjectsFromSet:other.trigger.resourceType]];
        }
        else{
            self.trigger.resourceType = [[NSMutableSet alloc] init];
        }
        
        if (self.trigger.loadType.count > 0 && other.trigger.loadType.count > 0){
            self.trigger.loadType =  [NSMutableSet setWithSet:[self.trigger.loadType setByAddingObjectsFromSet:other.trigger.loadType]];
        }
        else{
            self.trigger.loadType = [[NSMutableSet alloc] init];
        }
        self.trigger.urlFilterIsCaseSensitive = self.trigger.urlFilterIsCaseSensitive || other.trigger.urlFilterIsCaseSensitive;
        return YES;
    }
    
    //Trigger is large
//    if ((self.trigger.resourceType.count == 0 || [other.trigger.resourceType isSubsetOfSet:self.trigger.resourceType]) && (self.trigger.loadType.count == 0 || [other.trigger.resourceType isSubsetOfSet:self.trigger.resourceType])){
//        self.trigger.ifDomain =  [NSMutableSet setWithSet:[self.trigger.ifDomain setByAddingObjectsFromSet:other.trigger.ifDomain]];
//        self.trigger.unlessDomain =  [NSMutableSet setWithSet:[self.trigger.unlessDomain setByAddingObjectsFromSet:other.trigger.unlessDomain]];
//        self.trigger.urlFilterIsCaseSensitive = self.trigger.urlFilterIsCaseSensitive || other.trigger.urlFilterIsCaseSensitive;
//        return YES;
//    }
//    
//    if ((other.trigger.resourceType.count == 0 || [self.trigger.resourceType isSubsetOfSet:other.trigger.resourceType]) && (other.trigger.loadType.count == 0 || [self.trigger.resourceType isSubsetOfSet:other.trigger.resourceType])){
//        self.trigger.ifDomain =  [NSMutableSet setWithSet:[self.trigger.ifDomain setByAddingObjectsFromSet:other.trigger.ifDomain]];
//        self.trigger.unlessDomain =  [NSMutableSet setWithSet:[self.trigger.unlessDomain setByAddingObjectsFromSet:other.trigger.unlessDomain]];
//        self.trigger.urlFilterIsCaseSensitive = self.trigger.urlFilterIsCaseSensitive || other.trigger.urlFilterIsCaseSensitive;
//        return YES;
//    }
    
    return NO;
}

- (BOOL)canUrlFilterWildcard{
    if (self.action.selector.length > 0) return YES;
    if (self.trigger.ifDomain.count > 0) return YES;
    if (self.trigger.unlessDomain.count > 0) return YES;
    return NO;
}

@end
