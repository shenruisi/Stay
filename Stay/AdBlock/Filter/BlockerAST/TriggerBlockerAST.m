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
        urlFilter = [urlFilter stringByReplacingOccurrencesOfString:@"\\d" withString:@"[0-9]"];
        NSRegularExpression *regexReplace1 = [NSRegularExpression regularExpressionWithPattern:@"\\{\\d+,\\d*\\}" options:0 error:nil];
        urlFilter = [regexReplace1 stringByReplacingMatchesInString:urlFilter options:0 range:NSMakeRange(0, urlFilter.length) withTemplate:@"+"];
        [self.contentBlockerRule.trigger appendUrlFilter:urlFilter];
    }
    else{
        //Add wildcard
        if ([self.contentBlockerRule.trigger.urlFilter hasSuffix:@"$"]){
            self.unsupported = YES;
            return;
        }
        urlFilter = [urlFilter stringByReplacingOccurrencesOfString:@"\?" withString:@"\\?"];
        urlFilter = [urlFilter stringByReplacingOccurrencesOfString:@"." withString:@"\\."];

        [self.contentBlockerRule.trigger appendUrlFilter:urlFilter];
    }
}

@end
