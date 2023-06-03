//
//  SubscribeContentFilterManager.m
//  Stay
//
//  Created by ris on 2023/6/2.
//

#import "SubscribeContentFilterManager.h"
#import "DataManager.h"
#import "ContentFilterManager.h"
#import <SafariServices/SafariServices.h>

@interface SubscribeContentFilterManager ()

@property (nonatomic, strong) NSObject *writeLock;
@end

@implementation SubscribeContentFilterManager

static SubscribeContentFilterManager *instance = nil;
+ (instancetype)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SubscribeContentFilterManager alloc] init];
    });
    
    return instance;
}

- (void)checkUpdatingIfNeeded:(ContentFilter *)targetSubscribeContentFilter
                        focus:(BOOL)focus
                   completion:(void(^)(NSError *error, BOOL updated))completion{
    [targetSubscribeContentFilter checkUpdatingWithoutBuildRuleIfNeeded:focus completion:^(NSError *error, BOOL updated) {
        if (error){
            completion(error, NO);
            return;
        }
        
        if (updated){
            NSString *content = [targetSubscribeContentFilter fetchRules:&error];
            if (error || content.length == 0){
                completion(error,NO);
                return;
            }
            
            
            NSMutableArray *contentBlockerRules = [targetSubscribeContentFilter convertRules:content
                                                                            updateFilterInfo:YES
                                                                                     restore:NO];
             
             NSArray<ContentFilter *> *contentFilters = [[DataManager shareManager] selectContentFilters];
             for (ContentFilter *contentFilter in contentFilters){
                 if (contentFilter.type == ContentFilterTypeSubscribe
                     && contentFilter.status == 1
                     && ![contentFilter.uuid isEqualToString:targetSubscribeContentFilter.uuid]){
                     NSString *otherContent = [contentFilter fetchRules:&error];
                     if (nil == error && otherContent.length > 0){
                         [contentBlockerRules addObjectsFromArray:[contentFilter convertRules:content
                                                                             updateFilterInfo:YES
                                                                                      restore:NO]
                         ];
                     }
                 }
            }
            
            
            [self writeRules:contentBlockerRules mainSubscribeContentFilter:targetSubscribeContentFilter error:&error];
            
            if (error){
                completion(error,NO);
                return;
            }
            
            
            [SFContentBlockerManager reloadContentBlockerWithIdentifier:targetSubscribeContentFilter.contentBlockerIdentifier completionHandler:^(NSError * _Nullable error) {
                completion(error,YES);
                NSLog(@"Update&reloadContentBlockerWithIdentifier:%@ error:%@",targetSubscribeContentFilter.contentBlockerIdentifier, error);
            }];
            
        }
        else{
            completion(nil, NO);
        }
       
        
    }];
}

- (void)reload:(ContentFilter *)targetSubscribeContentFilter completion:(void(^)(NSError *error))completion{
    NSMutableArray<ContentBlockerRule *> *contentBlockerRules = [[NSMutableArray alloc] init];
    if (1 == targetSubscribeContentFilter.status){
        NSError *error;
        NSString *content = [targetSubscribeContentFilter fetchRules:&error];
        
        if (error){
            completion(error);
            return;
        }
        
        [contentBlockerRules addObjectsFromArray:[targetSubscribeContentFilter convertRules:content
                                                                           updateFilterInfo:NO
                                                                                    restore:NO]
        ];
        
        NSArray<ContentFilter *> *contentFilters = [[DataManager shareManager] selectContentFilters];
        for (ContentFilter *contentFilter in contentFilters){
            if (contentFilter.type == ContentFilterTypeSubscribe
                && contentFilter.status == 1
                && ![contentFilter.uuid isEqualToString:targetSubscribeContentFilter.uuid]){
                NSString *otherContent = [contentFilter fetchRules:&error];
                if (nil == error && otherContent.length > 0){
                    [contentBlockerRules addObjectsFromArray:[contentFilter convertRules:content
                                                                        updateFilterInfo:NO
                                                                                 restore:NO]
                    ];
                }
            }
        }
        
        [self writeRules:contentBlockerRules mainSubscribeContentFilter:targetSubscribeContentFilter error:&error];
        
        if (error){
            completion(error);
            return;
        }
        
        [SFContentBlockerManager reloadContentBlockerWithIdentifier:targetSubscribeContentFilter.contentBlockerIdentifier completionHandler:^(NSError * _Nullable error) {
            completion(error);
            NSLog(@"ReloadContentBlockerWithIdentifier:%@ error:%@",targetSubscribeContentFilter.contentBlockerIdentifier, error);
        }];
    }
}

- (void)writeRules:(NSMutableArray<ContentBlockerRule *> *)rules
mainSubscribeContentFilter:(ContentFilter *)contentFilter
             error:(NSError **)error{
    NSMutableArray *jsonRules = [[NSMutableArray alloc] init];
    for (ContentBlockerRule *rule in rules){
        [jsonRules addObject:[rule toDictionary]];
    }
   
    [jsonRules addObject:@{
        @"trigger" : @{
            @"url-filter" : @"webkit.svg"
        },
        @"action" : @{
            @"type" : @"block"
        }
    }];
    
    if (jsonRules.count > MAX_RULE_COUNT){
        jsonRules = [NSMutableArray arrayWithArray:[jsonRules subarrayWithRange:NSMakeRange(0, MAX_RULE_COUNT)]];
        *error = [[NSError alloc] initWithDomain:@"Content Filter Error" code:-500 userInfo:
            @{NSLocalizedDescriptionKey:NSLocalizedString(@"RuleMaxCountError", @"")}
        ];
    }
    
    NSArray<TrustedSite *> *trustSites = [[ContentFilterManager shared] trustedSites];
    NSMutableArray *domains = [[NSMutableArray alloc] init];
    for (TrustedSite *trustedSite in trustSites){
        [domains addObject:trustedSite.domain];
    }
    
    if (domains.count > 0){
        [jsonRules addObject:@{
            @"trigger" : @{
                @"url-filter" : @".*",
                @"if-domain" : domains
            },
            @"action" : @{
                @"type" : @"ignore-previous-rules"
            }
        }];
    }
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:jsonRules options:NSJSONWritingWithoutEscapingSlashes error:error];
    
#ifdef DEBUG
    NSLog(@"%@ rules count %ld",contentFilter.contentBlockerIdentifier,jsonRules.count);
    float sizeInMBytes = [data length] / (1024.0f * 1024.0f);
    NSLog(@"%.2f MB", sizeInMBytes);
#endif
      
    @synchronized (self.writeLock) {
        [[ContentFilterManager shared] writeJSONToFileName:contentFilter.rulePath data:data error:error];
    }
}

- (NSObject *)writeLock{
    if (nil == _writeLock){
        _writeLock = [[NSObject alloc] init];
    }
    
    return _writeLock;
}


@end
