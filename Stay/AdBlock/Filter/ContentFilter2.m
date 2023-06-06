//
//  ContentFilter.m
//  Stay
//
//  Created by ris on 2023/3/23.
//

#import "ContentFilter2.h"
#import "FilterTokenParser.h"
#import "ContentFilterBlocker.h"
#import <SafariServices/SafariServices.h>
#import "ContentFilterManager.h"
#import "DataManager.h"
#import "SYVersionUtils.h"



NSNotificationName const _Nonnull ContentFilterDidUpdateNotification = @"app.notification.ContentFilterDidUpdateNotification";
NSNotificationName const _Nonnull ContentFilterDidAddOrRemoveNotification = @"app.notification.ContentFilterDidAddOrRemoveNotification";

@interface ContentFilter(){
}

@property (nonatomic, strong) NSString *resourcePath;
@property (nonatomic, strong) NSString *sharedPath;
@end

@implementation ContentFilter

- (instancetype)init{
    if (self = [super init]){
    }
    
    return self;
}

- (NSString *)fetchRules:(NSError **)error{
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.sharedPath]){
        return [[NSString alloc] initWithContentsOfFile:self.sharedPath encoding:NSUTF8StringEncoding error:error];
    }
    
    return [[NSString alloc] initWithContentsOfFile:self.resourcePath encoding:NSUTF8StringEncoding error:error];
}

- (void)checkUpdatingWithoutBuildRuleIfNeeded:(BOOL)focus completion:(nullable void(^)(NSError *error, BOOL updated))completion{
    if (self.type == ContentFilterTypeCustom || self.type == ContentFilterTypeTag) return;
    NSInteger days = 4;
    if (self.expires.length > 0){
        NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"(\\d+) days" options:0 error:nil];
        NSArray<NSTextCheckingResult *> *results = [regex matchesInString:self.expires options:0 range:NSMakeRange(0, self.expires.length)];
        if (results.count > 0){
            NSTextCheckingResult *result = results[0];
            days = [[self.expires substringWithRange:[result rangeAtIndex:1]] integerValue];
        }
    }
    
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.updateTime];
    NSInteger daysBetween = (NSInteger)(timeInterval / 86400);

    if (daysBetween >= days || focus) {
        NSLog(@"Start update ContentBlockerWithIdentifier:%@",self.contentBlockerIdentifier);
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.downloadUrl]];
        [request setHTTPMethod:@"GET"];
        [[[NSURLSession sharedSession] dataTaskWithRequest:request
                        completionHandler:^(NSData *data,
                                            NSURLResponse *response,
                                            NSError *error) {
            if (nil == error && data.length > 0){
                NSString *content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSURL *url = [NSURL fileURLWithPath:self.sharedPath];
                [content writeToURL:url atomically:YES encoding:NSUTF8StringEncoding error:&error];
                
                
                
                if (error){
                    completion(error,NO);
                    return;
                }
                
                if (content.length == 0){
                    completion(nil,NO);
                    return;
                }
                
                completion(nil,YES);
                
            }
            else{
                if (completion){
                    completion(error,NO);
                }
            }
        }] resume];
    }
    else{
        completion(nil,NO);
        NSLog(@"No need update ContentBlockerWithIdentifier:%@",self.contentBlockerIdentifier);
    }
}

- (void)checkUpdatingIfNeeded:(BOOL)focus completion:(nullable void(^)(NSError *))completion{
    if (self.type == ContentFilterTypeCustom || self.type == ContentFilterTypeTag) return;
    NSInteger days = 4;
    if (self.expires.length > 0){
        NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"(\\d+) days" options:0 error:nil];
        NSArray<NSTextCheckingResult *> *results = [regex matchesInString:self.expires options:0 range:NSMakeRange(0, self.expires.length)];
        if (results.count > 0){
            NSTextCheckingResult *result = results[0];
            days = [[self.expires substringWithRange:[result rangeAtIndex:1]] integerValue];
        }
    }
    
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.updateTime];
    NSInteger daysBetween = (NSInteger)(timeInterval / 86400);

    if (daysBetween >= days || focus) {
        NSLog(@"Start update ContentBlockerWithIdentifier:%@",self.contentBlockerIdentifier);
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.downloadUrl]];
        [request setHTTPMethod:@"GET"];
        [[[NSURLSession sharedSession] dataTaskWithRequest:request
                        completionHandler:^(NSData *data,
                                            NSURLResponse *response,
                                            NSError *error) {
            if (nil == error && data.length > 0){
                NSString *content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSURL *url = [NSURL fileURLWithPath:self.sharedPath];
                [content writeToURL:url atomically:YES encoding:NSUTF8StringEncoding error:&error];
                
                
                
                if (error){
                    completion(error);
                    return;
                }
                
                if (content.length == 0){
                    completion(nil);
                    return;
                }
                
                [self processRules:content
                  updateFilterInfo:YES
                       writeOnDisk:YES
                           restore:NO
                        completion:completion];
            }
            else{
                if (completion){
                    completion(error);
                }
            }
        }] resume];
    }
    else{
        completion(nil);
        NSLog(@"No need update ContentBlockerWithIdentifier:%@",self.contentBlockerIdentifier);
    }
}

- (NSMutableArray<ContentBlockerRule *> *)convertRules:(NSString *)content
                                      updateFilterInfo:(BOOL)updateFilterInfo
                                               restore:(BOOL)restore{
    NSMutableArray<ContentBlockerRule *> *contentBlockerRules = [[NSMutableArray alloc] init];
    NSMutableDictionary *ruleMergeDict = [[NSMutableDictionary alloc] init];
    if (ContentFilterTypeTag == self.type || ContentFilterTypeCustom == self.type){
        ruleMergeDict = nil;
    }
    
    ContentBlockerRule *universalRule;
    NSArray<NSString *> *lines = [content componentsSeparatedByString:@"\n"];
    for (NSString *line in lines){
        NSString *newLine = [line stringByReplacingOccurrencesOfString:@"\r" withString:@""];

        if (newLine.length > 0 && newLine.length < 8192){
            BOOL isSepcialComment;
            ContentBlockerRule *contentBlockerRule = [ContentFilterBlocker rule:newLine isSpecialComment:&isSepcialComment];
//            contentBlockerRule.originRule = newLine;
            if (nil == universalRule && [contentBlockerRule.key isEqualToString:@".*[SEL]"]){
                universalRule = contentBlockerRule;
            }
            
            if (contentBlockerRule && !isSepcialComment){
                ContentBlockerRule *existContentBlockerRule = [ruleMergeDict objectForKey:contentBlockerRule.key];
                if (existContentBlockerRule){
                    if ([contentBlockerRule isEqual:existContentBlockerRule]){
                    }
                    else if ([contentBlockerRule.action.type isEqualToString:@"ignore-previous-rules"]){
                        [ruleMergeDict removeObjectForKey:contentBlockerRule.key];
                        [contentBlockerRules removeObject:existContentBlockerRule];
                    }
                    else{
                        if (![existContentBlockerRule mergeRule:contentBlockerRule]){
                            [contentBlockerRules addObject:contentBlockerRule];
                        }
                    }
                }
                else{
                    [ruleMergeDict setObject:contentBlockerRule forKey:contentBlockerRule.key];
                    if (universalRule != contentBlockerRule){
                        [contentBlockerRules addObject:contentBlockerRule];
                    }
                }
            }
            else if (isSepcialComment){
                if (updateFilterInfo && self.type != ContentFilterTypeSubscribe){
                    NSDictionary *specialComment = contentBlockerRule.specialComment;
                    if (specialComment[@"Homepage"]){
                        [[DataManager shareManager]
                         updateContentFilterHomepage:specialComment[@"Homepage"] uuid:self.uuid];
                    }
                    else if (specialComment[@"Version"]){
                        [[DataManager shareManager]
                         updateContentFilterVersion:specialComment[@"Version"] uuid:self.uuid];
                    }
                    else if (specialComment[@"Expires"]){
                        [[DataManager shareManager]
                         updateContentFilterExpires:specialComment[@"Expires"] uuid:self.uuid];
                    }
                    else if (specialComment[@"Redirect"]){
                        [[DataManager shareManager]
                         updateContentFilterRedirect:specialComment[@"Redirect"] uuid:self.uuid];
                    }
                }
            }
        }
    }
    
    if (updateFilterInfo&&!restore){
        self.updateTime = [NSDate date];
        [[DataManager shareManager]
         updateContentFilterUpdateTime:self.updateTime uuid:self.uuid];
    }
    
    if (universalRule && universalRule.action.selectors.count > 0){
        NSMutableString *selectorConnector = [[NSMutableString alloc] init];
        NSUInteger splictCount = 100;
        NSUInteger counter = 0;
        for (NSString *selector in universalRule.action.selectors){
            if (counter < splictCount){
                [selectorConnector appendFormat:@"%@, ",selector];
                counter++;
            }
            else{
                [selectorConnector appendString:selector];
                ContentBlockerRule *rule = [[ContentBlockerRule alloc] init];
                rule.trigger.urlFilter = @".*";
                rule.action.type = @"css-display-none";
                rule.action.selector = [selectorConnector copy];
                [contentBlockerRules addObject:rule];
                counter = 0;
                [selectorConnector deleteCharactersInRange:NSMakeRange(0, selectorConnector.length)];
            }
        }
        
        if (selectorConnector.length > 0){
            [selectorConnector deleteCharactersInRange:NSMakeRange(selectorConnector.length - 2, 2)];
            ContentBlockerRule *rule = [[ContentBlockerRule alloc] init];
            rule.trigger.urlFilter = @".*";
            rule.action.type = @"css-display-none";
            rule.action.selector = [selectorConnector copy];
            [contentBlockerRules addObject:rule];
        }
    }
    else if (universalRule && universalRule.action.selectors.count == 0){
        [contentBlockerRules addObject:universalRule];
    }
    
    return contentBlockerRules;
}

- (void)processRules:(NSString *)content
    updateFilterInfo:(BOOL)updateFilterInfo
         writeOnDisk:(BOOL)writeOnDisk
             restore:(BOOL)restore
          completion:(void(^)(NSError *))completion{
    dispatch_async(dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_DEFAULT),^{
        NSError *error;
        NSMutableArray *contentBlockerRules = [self convertRules:content
                                                updateFilterInfo:updateFilterInfo
                                                         restore:restore];
        
        if (writeOnDisk){
            NSMutableArray *jsonRules = [[NSMutableArray alloc] init];
            for (ContentBlockerRule *rule in contentBlockerRules){
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
            
            NSError *maxRuleCountError;
            if (jsonRules.count > MAX_RULE_COUNT){
//                int start = 15725;
//                int end = 15750;
//                int length = end - start;
                
                jsonRules = [NSMutableArray arrayWithArray:[jsonRules subarrayWithRange:NSMakeRange(0, MAX_RULE_COUNT)]];
                maxRuleCountError = [[NSError alloc] initWithDomain:@"Content Filter Error" code:-500 userInfo:
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
            
            NSData *data = [NSJSONSerialization dataWithJSONObject:jsonRules options:NSJSONWritingWithoutEscapingSlashes error:&error];
#ifdef DEBUG
            NSLog(@"%@ rules count %ld",self.contentBlockerIdentifier,jsonRules.count);
            float sizeInMBytes = [data length] / (1024.0f * 1024.0f);
            NSLog(@"%.2f MB", sizeInMBytes);
#endif
            
            if (error){
                if (completion){
                    completion(error);
                }
                return;
            }

            [[ContentFilterManager shared] writeJSONToFileName:self.rulePath data:data error:&error];
            
            if (error){
                if (completion){
                    completion(error);
                }
                return;
            }
            
            [SFContentBlockerManager reloadContentBlockerWithIdentifier:self.contentBlockerIdentifier completionHandler:^(NSError * _Nullable error) {
                if (completion){
                    if (maxRuleCountError){
                        completion(maxRuleCountError);
                    }
                    else{
                        completion(error);
                    }
                    
                }
                NSLog(@"Update&reloadContentBlockerWithIdentifier:%@ error:%@",self.contentBlockerIdentifier, error);
            }];
        }
    });
}

- (void)stopRulesWithCompletion:(void(^)(NSError *error))completion{
    
}

- (void)restoreRulesWithCompletion:(void(^)(NSError *))completion{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error;
        [[NSFileManager defaultManager] removeItemAtPath:self.sharedPath error:&error];
        if (error){
            completion(error);
            return;
        }
        NSString *content = [[NSString alloc] initWithContentsOfFile:self.resourcePath encoding:NSUTF8StringEncoding error:&error];
        if (error){
            completion(error);
            return;
        }
        
        if (content.length == 0){
            completion(nil);
            return;
        }
        
        [self processRules:content
          updateFilterInfo:YES
               writeOnDisk:YES
                   restore:YES
                completion:completion];
    });
}

- (void)reloadContentBlockerWithCompletion:(void(^)(NSError *error))completion{
    NSError *error;
    NSString *content = [self fetchRules:&error];
    
    if (error){
        completion(error);
        return;
    }
    [self processRules:content
      updateFilterInfo:NO
           writeOnDisk:YES
               restore:NO
            completion:completion];
}

- (void)reloadContentBlockerWihtoutRebuild{
    [SFContentBlockerManager reloadContentBlockerWithIdentifier:self.contentBlockerIdentifier completionHandler:^(NSError * _Nullable error) {
        NSLog(@"Update&reloadContentBlockerWithIdentifier:%@ error:%@",self.contentBlockerIdentifier, error);
    }];
}

- (BOOL)active{
    return self.status == 1;
}

- (NSString *)resourcePath{
    return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:self.path];
}

- (NSString *)sharedPath{
    NSString *textPath = [[[[NSFileManager defaultManager]
                   containerURLForSecurityApplicationGroupIdentifier:
                       @"group.com.dajiu.stay.pro"] path] stringByAppendingPathComponent:@".ContentFilterText"];
    return [textPath stringByAppendingPathComponent:self.path];
}

- (void)clear{
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.sharedPath]){
        NSError *error;
        [[NSFileManager defaultManager] removeItemAtPath:self.sharedPath error:&error];
        NSLog(@"remove file: %@, error: %@",self.sharedPath,error);
    }
}


+ (NSString *)stringOfType:(ContentFilterType)type{
    if (ContentFilterTypeBasic == type) return @"Basic";
    if (ContentFilterTypePrivacy == type) return @"Privacy";
    if (ContentFilterTypeRegion == type) return @"Region";
    if (ContentFilterTypeCustom == type) return @"Custom";
    if (ContentFilterTypeTag == type) return @"Tag";
    if (ContentFilterTypeSubscribe == type) return @"Subscribe";
    return @"";
}

@end
