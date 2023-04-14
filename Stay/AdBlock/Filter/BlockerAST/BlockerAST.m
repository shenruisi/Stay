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


- (void)construct:(nullable NSArray *)args{
    self.dictionary = args[0];
}

- (NSMutableDictionary<NSString *, NSMutableDictionary *> *)dictionary{
    if (nil == _dictionary){
        _dictionary = [[NSMutableDictionary alloc] init];
        [_dictionary setObject:[[NSMutableDictionary alloc] init] forKey:@"trigger"];
        [_dictionary setObject:[[NSMutableDictionary alloc] init] forKey:@"action"];
    }
    
    return _dictionary;
}

- (void)setUrlFilter:(NSString *)urlFilter{
    NSString *existUrlFilter = self.dictionary[@"trigger"][@"url-filter"];
    self.dictionary[@"trigger"][@"url-filter"] = [NSString stringWithFormat:@"%@%@",existUrlFilter ? existUrlFilter : @"",urlFilter];
}

- (void)resetUrlFilter:(NSString *)urlFilter{
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

- (void)addIfDomain:(NSString *)ifDomain{
    if (nil ==  self.dictionary[@"trigger"][@"if-domain"]){
        self.dictionary[@"trigger"][@"if-domain"] = [[NSMutableArray alloc] init];
    }
    
    [self.dictionary[@"trigger"][@"if-domain"] addObject:ifDomain];
}

- (NSMutableArray *)ifDomain{
    return self.dictionary[@"trigger"][@"if-domain"];
}

- (void)addUnlessDomain:(NSString *)unlessDomain{
    if (nil ==  self.dictionary[@"trigger"][@"unless-domain"]){
        self.dictionary[@"trigger"][@"unless-domain"] = [[NSMutableArray alloc] init];
    }
    
    [self.dictionary[@"trigger"][@"unless-domain"] addObject:unlessDomain];
}

- (NSMutableArray *)unlessDomain{
    return self.dictionary[@"trigger"][@"unless-domain"];
}

- (void)addResourceType:(NSString *)resourceType{
    if (nil ==  self.dictionary[@"trigger"][@"resource-type"]){
        self.dictionary[@"trigger"][@"resource-type"] = [[NSMutableArray alloc] init];
    }
    
    [self.dictionary[@"trigger"][@"resource-type"] addObject:resourceType];
}

- (NSMutableArray *)resourceType{
    return self.dictionary[@"trigger"][@"resource-type"];
}

- (void)addLoadType:(NSString *)loadType{
    if (nil ==  self.dictionary[@"trigger"][@"load-type"]){
        self.dictionary[@"trigger"][@"load-type"] = [[NSMutableArray alloc] init];
    }
    
    [self.dictionary[@"trigger"][@"load-type"] addObject:loadType];
}

- (NSMutableArray *)loadType{
    return self.dictionary[@"trigger"][@"load-type"];
}

- (void)addIfTopUrl:(NSString *)ifTopUrl{
    if (nil ==  self.dictionary[@"trigger"][@"if-top-url"]){
        self.dictionary[@"trigger"][@"if-top-url"] = [[NSMutableArray alloc] init];
    }
    
    [self.dictionary[@"trigger"][@"if-top-url"] addObject:ifTopUrl];
}

- (NSMutableArray *)ifTopUrl{
    return self.dictionary[@"trigger"][@"if-top-url"];
}

- (void)addUnlessTopUrl:(NSString *)unlessTopUrl{
    if (nil ==  self.dictionary[@"trigger"][@"unless-top-url"]){
        self.dictionary[@"trigger"][@"unless-top-url"] = [[NSMutableArray alloc] init];
    }
    
    [self.dictionary[@"trigger"][@"unless-top-url"] addObject:unlessTopUrl];
}

- (NSMutableArray *)unlessTopUrl{
    return self.dictionary[@"trigger"][@"unless-top-url"];
}

- (void)addLoadContext:(NSString *)loadContext{
    if (nil ==  self.dictionary[@"trigger"][@"load-context"]){
        self.dictionary[@"trigger"][@"load-context"] = [[NSMutableArray alloc] init];
    }
    
    [self.dictionary[@"trigger"][@"load-context"] addObject:loadContext];
}

- (NSMutableArray *)loadContext{
    return self.dictionary[@"trigger"][@"load-context"];
}

- (void)setType:(NSString *)type{
    self.dictionary[@"action"][@"type"] = type;
}

- (NSString *)type{
    return self.dictionary[@"action"][@"type"];
}

- (void)setSelector:(NSString *)selector{
    self.dictionary[@"action"][@"selector"] = selector;
}

- (NSString *)selector{
    return self.dictionary[@"action"][@"selector"];
}

@end
