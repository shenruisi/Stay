//
//  BlockerAST.m
//  Stay
//
//  Created by ris on 2023/4/7.
//

#import "BlockerAST.h"

@implementation BlockerAST

- (instancetype)initWithParser:(FilterTokenParser *)parser args:(NSArray *)args{
    if (self = [super init]){
        self.parser = parser;
        [self construct:args];
    }
    
    return self;
}


- (void)construct:(nullable NSArray *)args{}

- (NSMutableDictionary<NSString *, NSMutableDictionary *> *)dictionary{
    if (nil == _dictionary){
        _dictionary = [[NSMutableDictionary alloc] init];
        [_dictionary setObject:[[NSMutableDictionary alloc] init] forKey:@"trigger"];
        [_dictionary setObject:[[NSMutableDictionary alloc] init] forKey:@"action"];
    }
    
    return _dictionary;
}

- (void)setUrlFilter:(NSString *)urlFilter{
    self.dictionary[@"trigger"][@"url-filter"] = urlFilter;
}

- (NSString *)urlFilter{
    return self.dictionary[@"trigger"][@"url-filter"];
}

- (void)setUrlFilterIsCaseSensitive:(BOOL)urlFilterIsCaseSensitive{
    self.dictionary[@"trigger"][@"url-filter-is-case-sensitive"] = @(urlFilterIsCaseSensitive);
}

- (BOOL)urlFilterIsCaseSensitive{
    return self.dictionary[@"trigger"][@"url-filter-is-case-sensitive"];
}

- (void)setIfDomain:(NSMutableArray *)ifDomain{
    self.dictionary[@"trigger"][@"if-domain"] = ifDomain;
}

- (NSMutableArray *)ifDomain{
    return self.dictionary[@"trigger"][@"if-domain"];
}

- (void)setUnlessDomain:(NSMutableArray *)unlessDomain{
    self.dictionary[@"trigger"][@"unless-domain"] = unlessDomain;
}

- (NSMutableArray *)unlessDomain{
    return self.dictionary[@"trigger"][@"unless-domain"];
}

- (void)setResourceType:(NSMutableArray *)resourceType{
    self.dictionary[@"trigger"][@"resource-type"] = resourceType;
}

- (NSMutableArray *)resourceType{
    return self.dictionary[@"trigger"][@"resource-type"];
}

- (void)setLoadType:(NSMutableArray *)loadType{
    self.dictionary[@"trigger"][@"load-type"] = loadType;
}

- (NSMutableArray *)loadType{
    return self.dictionary[@"trigger"][@"load-type"];
}

- (void)setIfTopUrl:(NSMutableArray *)ifTopUrl{
    self.dictionary[@"trigger"][@"if-top-url"] = ifTopUrl;
}

- (NSMutableArray *)ifTopUrl{
    return self.dictionary[@"trigger"][@"if-top-url"];
}

- (void)setUnlessTopUrl:(NSMutableArray *)unlessTopUrl{
    self.dictionary[@"trigger"][@"unless-top-url"] = unlessTopUrl;
}

- (NSMutableArray *)unlessTopUrl{
    return self.dictionary[@"trigger"][@"unless-top-url"];
}

- (void)setLoadContext:(NSMutableArray *)loadContext{
    self.dictionary[@"trigger"][@"load-context"] = loadContext;
}

- (NSMutableArray *)loadContext{
    return self.dictionary[@"trigger"][@"load-context"];
}

@end
