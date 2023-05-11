//
//  TriggerBlockerAST.m
//  Stay
//
//  Created by ris on 2023/4/7.
//

#import "TriggerBlockerAST.h"

@interface TriggerBlockerAST()

@end

@implementation TriggerBlockerAST

- (void)construct:(NSArray *)args{
    [super construct:args];
    
    NSString *urlFilter = [self.parser.curToken toString];
    if (urlFilter.length >= 2
        && [urlFilter characterAtIndex:0] == '/'
        && [urlFilter characterAtIndex:urlFilter.length - 1] == '/'){
        NSRegularExpression *unsupport = [NSRegularExpression regularExpressionWithPattern:@"\\(.*\\|?\\)" options:0 error:nil];
        NSArray<NSTextCheckingResult *> *results =[unsupport matchesInString:urlFilter options:0 range:NSMakeRange(0, urlFilter.length)];
        if (results.count > 0){
            self.unsupported = YES;
            return;
        }
        
        urlFilter = [urlFilter substringWithRange:NSMakeRange(1, urlFilter.length - 2)];
        urlFilter = [urlFilter stringByReplacingOccurrencesOfString:@"\\w" withString:@"."];
        urlFilter = [urlFilter stringByReplacingOccurrencesOfString:@"\\s" withString:@"."];
        urlFilter = [urlFilter stringByReplacingOccurrencesOfString:@"\\S" withString:@"."];
        urlFilter = [urlFilter stringByReplacingOccurrencesOfString:@"\\W" withString:@"[^A-Za-z0-9_]"];
        urlFilter = [urlFilter stringByReplacingOccurrencesOfString:@"\\d" withString:@"[0-9]"];
        NSRegularExpression *replaceRegex1 = [NSRegularExpression regularExpressionWithPattern:@"\\{\\d+,\\d*\\}" options:0 error:nil];
        urlFilter = [replaceRegex1 stringByReplacingMatchesInString:urlFilter options:0 range:NSMakeRange(0, urlFilter.length) withTemplate:@"+"];
        
        NSRegularExpression *replaceRegex2 = [NSRegularExpression regularExpressionWithPattern:@"\\{\\d+\\}" options:0 error:nil];
        urlFilter = [replaceRegex2 stringByReplacingMatchesInString:urlFilter options:0 range:NSMakeRange(0, urlFilter.length) withTemplate:@"+"];
        
        NSArray<NSTextCheckingResult *> *capResults;
        do{
            NSRegularExpression *capRegex = [NSRegularExpression regularExpressionWithPattern:@"(\\[[0-9a-zA-Z\\-]+\\])\\{(\\d+)\\}" options:0 error:nil];
            capResults = [capRegex matchesInString:urlFilter options:0 range:NSMakeRange(0, urlFilter.length)];
            for (NSTextCheckingResult *result in capResults){
                NSInteger n = result.numberOfRanges;
                if (n == 3){
                    NSRange range1 = [result rangeAtIndex:1];
                    NSRange range2 = [result rangeAtIndex:2];
                    NSString *cap1 = [urlFilter substringWithRange:range1];
                    NSString *cap2 = [urlFilter substringWithRange:range2];
                    NSUInteger times = [cap2 integerValue];
                    NSMutableString *replaceStr = [[NSMutableString alloc] init];
                    for (int i = 0; i < times; i++){
                        [replaceStr appendString:cap1];
                    }
                    urlFilter = [urlFilter stringByReplacingCharactersInRange:NSMakeRange(range1.location, range1.length + range2.length + 2) withString:replaceStr];
                }
                break;
            }
            
        }while(capResults.count > 0);
        
        [self.contentBlockerRule.trigger appendUrlFilter:urlFilter];
    }
    else{
        //Add wildcard
        if ([self.contentBlockerRule.trigger.urlFilter hasSuffix:@"$"]){
            self.unsupported = YES;
            return;
        }
        
        if (self.contentBlockerRule.trigger.urlFilter.length == 0){
            if ([urlFilter containsString:@","]){
                if ([urlFilter hasSuffix:@","]){
                    self.unsupported = YES;
                    return;
                }
                NSRegularExpression *domainRegex = [NSRegularExpression regularExpressionWithPattern:@"([a-zA-Z0-9\\-]*\\.?[a-zA-Z0-9\\-]+\\.[a-zA-Z]{2,},?)+" options:0 error:nil];
                NSArray<NSTextCheckingResult *> *results = [domainRegex matchesInString:urlFilter options:0 range:NSMakeRange(0, urlFilter.length)];
                if (results.count == 1){
                    NSInteger n = results[0].numberOfRanges;
                    if (n > 0){
                        NSRange range = [results[0] rangeAtIndex:0];
                        if (NSMaxRange(range) == urlFilter.length){
                            NSArray<NSString *> *domainList = [urlFilter componentsSeparatedByString:@","];
                            BOOL unless = [self.contentBlockerRule.action.type isEqualToString:@"ignore-previous-rules"];
                            for (NSString *domain in domainList){
                                if (domain.length > 0){
                                    if (unless){
                                        [self.contentBlockerRule.trigger.unlessDomain addObject:domain];
                                    }
                                    else{
                                        [self.contentBlockerRule.trigger.ifDomain addObject:domain];
                                    }
                                }
                            }
                            self.contentBlockerRule.trigger.urlFilter = @"^https?://.*";
                            return;
                        }
                    }
                }
            }
        }
        
        [self.contentBlockerRule.trigger appendUrlFilter:[self rebuildUrlFilter:urlFilter]];
    }
}

- (NSString *)rebuildUrlFilter:(NSString *)urlFilter{
    NSString *parsedUrlFilter = [urlFilter copy];
    parsedUrlFilter = [parsedUrlFilter stringByReplacingOccurrencesOfString:@"\\d" withString:@"[0-9]"];
    parsedUrlFilter = [parsedUrlFilter stringByReplacingOccurrencesOfString:@"\?" withString:@"\\?"];
    parsedUrlFilter = [parsedUrlFilter stringByReplacingOccurrencesOfString:@"." withString:@"\\."];
    parsedUrlFilter = [parsedUrlFilter stringByReplacingOccurrencesOfString:@"*" withString:@".*"];
    //issue × х
    parsedUrlFilter = [parsedUrlFilter stringByReplacingOccurrencesOfString:@"×" withString:@"\\U00d"];
    parsedUrlFilter = [parsedUrlFilter stringByReplacingOccurrencesOfString:@"х" withString:@"\\U044"];
    return parsedUrlFilter;
}

@end
