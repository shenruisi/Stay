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
        NSRegularExpression *replaceRegex = [NSRegularExpression regularExpressionWithPattern:@"\\{\\d+,\\d*\\}" options:0 error:nil];
        urlFilter = [replaceRegex stringByReplacingMatchesInString:urlFilter options:0 range:NSMakeRange(0, urlFilter.length) withTemplate:@"+"];
        
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
        urlFilter = [urlFilter stringByReplacingOccurrencesOfString:@"\\d" withString:@"[0-9]"];
        urlFilter = [urlFilter stringByReplacingOccurrencesOfString:@"\?" withString:@"\\?"];
        urlFilter = [urlFilter stringByReplacingOccurrencesOfString:@"." withString:@"\\."];
        urlFilter = [urlFilter stringByReplacingOccurrencesOfString:@"*" withString:@".*"];
        //issue × х
        urlFilter = [urlFilter stringByReplacingOccurrencesOfString:@"×" withString:@"\\U00d"];
        urlFilter = [urlFilter stringByReplacingOccurrencesOfString:@"х" withString:@"\\U044"];
        
        
        [self.contentBlockerRule.trigger appendUrlFilter:urlFilter];
    }
}

@end
