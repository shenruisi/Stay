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
                        completion:completion];
            }
        }] resume];
    }
}

- (void)processRules:(NSString *)content
    updateFilterInfo:(BOOL)updateFilterInfo
         writeOnDisk:(BOOL)writeOnDisk
          completion:(void(^)(NSError *))completion{
    NSError *error;
    NSMutableArray<ContentBlockerRule *> *contentBlockerRules = [[NSMutableArray alloc] init];
    NSMutableDictionary *ruleMergeDict = [[NSMutableDictionary alloc] init];
    ContentBlockerRule *universalRule;
    NSArray<NSString *> *lines = [content componentsSeparatedByString:@"\n"];
    for (NSString *line in lines){
        if (line.length > 0){
            BOOL isSepcialComment;
            ContentBlockerRule *contentBlockerRule = [ContentFilterBlocker rule:line isSpecialComment:&isSepcialComment];
            if (nil == universalRule && [contentBlockerRule.trigger.urlFilter isEqualToString:@".*"]){
                universalRule = contentBlockerRule;
            }
            
            if (contentBlockerRule && !isSepcialComment){
                ContentBlockerRule *existContentBlockerRule = [ruleMergeDict objectForKey:contentBlockerRule.trigger.urlFilter];
                if (existContentBlockerRule){
                    if ([contentBlockerRule isEqual:existContentBlockerRule]){
                    }
                    else if ([contentBlockerRule.action.type isEqualToString:@"ignore-previous-rules"]){
                        [ruleMergeDict removeObjectForKey:contentBlockerRule.trigger.urlFilter];
                        [contentBlockerRules removeObject:existContentBlockerRule];
                    }
                    else{
                        if (![existContentBlockerRule mergeRule:contentBlockerRule]){
                            [contentBlockerRules addObject:contentBlockerRule];
                        }
                    }
                }
                else{
                    [ruleMergeDict setObject:contentBlockerRule forKey:contentBlockerRule.trigger.urlFilter];
                    if (universalRule != contentBlockerRule){
                        [contentBlockerRules addObject:contentBlockerRule];
                    }
                }
            }
            else if (isSepcialComment){
                if (updateFilterInfo){
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
    
    if (updateFilterInfo){
        [[DataManager shareManager]
         updateContentFilterUpdateTime:[NSDate date] uuid:self.uuid];
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
    
    if (writeOnDisk){
        NSMutableArray *jsonRules = [[NSMutableArray alloc] init];
        for (ContentBlockerRule *rule in contentBlockerRules){
            [jsonRules addObject:[rule toDictionary]];
        }
        
        NSString *ret = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:jsonRules options:NSJSONWritingWithoutEscapingSlashes error:&error] encoding:NSUTF8StringEncoding];
        
        if (error){
            if (completion){
                completion(error);
            }
            return;
        }

        [[ContentFilterManager shared] writeJSONToFileName:self.rulePath content:ret error:&error];
        
        if (error){
            if (completion){
                completion(error);
            }
            return;
        }
        [SFContentBlockerManager reloadContentBlockerWithIdentifier:self.contentBlockerIdentifier completionHandler:^(NSError * _Nullable error) {
            if (completion){
                completion(error);
            }
            NSLog(@"Update&reloadContentBlockerWithIdentifier:%@ error:%@",self.contentBlockerIdentifier, error);
        }];
    }
    
}

- (void)restoreRulesWithCompletion:(void(^)(NSError *))completion{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error;
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
            completion:completion];
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


+ (NSString *)stringOfType:(ContentFilterType)type{
    if (ContentFilterTypeBasic == type) return @"Basic";
    if (ContentFilterTypePrivacy == type) return @"Privacy";
    if (ContentFilterTypeRegion == type) return @"Region";
    if (ContentFilterTypeCustom == type) return @"Custom";
    if (ContentFilterTypeTag == type) return @"Tag";
    return @"";
}

@end
